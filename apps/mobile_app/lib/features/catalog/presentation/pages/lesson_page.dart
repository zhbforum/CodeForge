import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/course_path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _normalizeMd(String s) => s
    .replaceAll('\r\n', '\n')
    .replaceAll(r'\r\n', '\n')
    .replaceAll(r'\n', '\n');

class LessonHeader {
  LessonHeader({required this.id, required this.title, required this.order});
  final String id;
  final String title;
  final int order;
}

class LessonSlide {
  LessonSlide({
    required this.id,
    required this.contentType,
    required this.content,
    required this.order,
  });
  final String id;
  final String contentType;
  final Map<String, dynamic> content;
  final int order;
}

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final quizSelectedProvider = StateProvider.family.autoDispose<int?, String>(
  (ref, slideId) => null,
);

final quizRevealedProvider = StateProvider.family.autoDispose<bool, String>(
  (ref, slideId) => false,
);

final quizWrongIndexProvider = StateProvider.family.autoDispose<int?, String>(
  (ref, slideId) => null,
);

final lessonHeaderProvider = FutureProvider.family
    .autoDispose<LessonHeader, String>((ref, lessonId) async {
      final client = ref.read(supabaseProvider);
      final idKey = int.tryParse(lessonId) ?? lessonId;
      final row = await client
          .from('lessons')
          .select('id,title,"order"')
          .eq('id', idKey)
          .single();

      final m = Map<String, dynamic>.from(row as Map);
      return LessonHeader(
        id: (m['id'] is num) ? (m['id'] as num).toString() : m['id'].toString(),
        title: (m['title'] as String?) ?? 'Lesson',
        order: (m['order'] as num?)?.toInt() ?? 1,
      );
    });

final lessonSlidesProvider = FutureProvider.family
    .autoDispose<List<LessonSlide>, String>((ref, lessonId) async {
      final client = ref.read(supabaseProvider);
      final idKey = int.tryParse(lessonId) ?? lessonId;

      final rows = await client
          .from('lesson_slides')
          .select('id,lesson_id,"order",content_type,content')
          .eq('lesson_id', idKey)
          .order('order', ascending: true);

      final list = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (m) => LessonSlide(
              id: (m['id'] is num)
                  ? (m['id'] as num).toString()
                  : m['id'].toString(),
              contentType: m['content_type'] as String,
              content: Map<String, dynamic>.from(m['content'] as Map),
              order: (m['order'] as num?)?.toInt() ?? 1,
            ),
          )
          .toList();

      return list;
    });

final currentOrderProvider = StateProvider.family.autoDispose<int, String>(
  (ref, lessonId) => 1,
);

typedef LessonKey = ({String courseId, String lessonId});

final lessonCompletedProvider = FutureProvider.family
    .autoDispose<bool, LessonKey>((ref, key) async {
      final store = ref.read(progressStoreProvider);
      final map = await store.getLessonCompletion(key.courseId);
      return map[key.lessonId] ?? false;
    });

class LessonPage extends ConsumerWidget {
  const LessonPage({required this.courseId, required this.lessonId, super.key});

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = ref.watch(lessonHeaderProvider(lessonId));
    final slides = ref.watch(lessonSlidesProvider(lessonId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          header.maybeWhen(data: (h) => h.title, orElse: () => 'Lesson'),
        ),
      ),
      body: _buildBody(context, ref, header, slides),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<LessonHeader> header,
    AsyncValue<List<LessonSlide>> slides,
  ) {
    if (header.isLoading || slides.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (header.hasError) {
      return Center(child: Text('Error: ${header.error}'));
    }
    if (slides.hasError) {
      return Center(child: Text('Error: ${slides.error}'));
    }

    final data = slides.value!;
    if (data.isEmpty) {
      return const Center(child: Text('No slides yet'));
    }

    final byOrder = <int, List<LessonSlide>>{};
    for (final s in data) {
      byOrder.putIfAbsent(s.order, () => []).add(s);
    }
    for (final list in byOrder.values) {
      list.sort((a, b) {
        final ai = int.tryParse(a.id) ?? 0;
        final bi = int.tryParse(b.id) ?? 0;
        return ai.compareTo(bi);
      });
    }

    final orders = byOrder.keys.toList()..sort();
    final minOrder = orders.first;
    final maxOrder = orders.last;

    final currentOrder = ref.watch(currentOrderProvider(lessonId));
    final clamped = currentOrder.clamp(minOrder, maxOrder);
    if (clamped != currentOrder) {
      ref.read(currentOrderProvider(lessonId).notifier).state = clamped;
    }

    final currentSlides = byOrder[clamped] ?? const <LessonSlide>[];
    final isLastStep = clamped == maxOrder;

    final completedAsync = ref.watch(
      lessonCompletedProvider((courseId: courseId, lessonId: lessonId)),
    );

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          final curr = ref.read(currentOrderProvider(lessonId));
          if (curr > minOrder) {
            ref.read(currentOrderProvider(lessonId).notifier).state = curr - 1;
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          final curr = ref.read(currentOrderProvider(lessonId));
          if (curr < maxOrder) {
            ref.read(currentOrderProvider(lessonId).notifier).state = curr + 1;
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            _TopProgressBar(current: clamped, min: minOrder, max: maxOrder),

            if (maxOrder > minOrder)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: clamped > minOrder
                          ? () =>
                                ref
                                        .read(
                                          currentOrderProvider(
                                            lessonId,
                                          ).notifier,
                                        )
                                        .state =
                                    clamped - 1
                          : null,
                      tooltip: 'Previous',
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: clamped < maxOrder
                          ? () =>
                                ref
                                        .read(
                                          currentOrderProvider(
                                            lessonId,
                                          ).notifier,
                                        )
                                        .state =
                                    clamped + 1
                          : null,
                      tooltip: 'Next',
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SafeArea(
                top: false,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentSlides.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _SlideCard(slide: currentSlides[i]),
                ),
              ),
            ),

            if (isLastStep)
              completedAsync.when(
                data: (isCompleted) => _FinishBar(
                  isCompleted: isCompleted,
                  onFinish: isCompleted
                      ? null
                      : () async {
                          final store = ref.read(progressStoreProvider);
                          await store.setLessonCompleted(
                            courseId: courseId,
                            lessonId: lessonId,
                            completed: true,
                          );
                          ref
                            ..invalidate(
                              lessonCompletedProvider((
                                courseId: courseId,
                                lessonId: lessonId,
                              )),
                            )
                            ..invalidate(coursePathProvider(courseId));
                          if (!context.mounted) return;
                          context.go('/home/course/$courseId');
                        },
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopProgressBar extends StatelessWidget {
  const _TopProgressBar({
    required this.current,
    required this.min,
    required this.max,
  });
  final int current;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final total = (max - min + 1).clamp(1, 9999);
    final value = ((current - min + 1) / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: value),
          const SizedBox(height: 8),
          Text(
            'Step $current of $max',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.slide});
  final LessonSlide slide;

  @override
  Widget build(BuildContext context) {
    switch (slide.contentType) {
      case 'text':
        {
          final title = slide.content['title'] as String? ?? '';
          final alignStr = slide.content['align'] as String?;
          final cross = switch (alignStr) {
            'center' => CrossAxisAlignment.center,
            'end' => CrossAxisAlignment.end,
            _ => CrossAxisAlignment.start,
          };
          final isCenter = alignStr == 'center';

          final blocks =
              (slide.content['blocks'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList() ??
              const <Map<String, dynamic>>[];

          final raw =
              slide.content['markdown'] as String? ??
              slide.content['text'] as String? ??
              '';

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: cross,
                children: [
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: isCenter
                            ? TextAlign.center
                            : TextAlign.start,
                      ),
                    ),
                  Align(
                    alignment: isCenter
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (blocks.isEmpty)
                            _MarkdownParagraph(_normalizeMd(raw))
                          else
                            ...blocks.map((b) => _BlockRenderer(block: b)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

      case 'image':
        return _ImageCard(content: slide.content);

      case 'code':
        {
          final lang = slide.content['lang'] as String? ?? 'text';
          final code = slide.content['code'] as String? ?? '';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText('[$lang]\n$code'),
            ),
          );
        }

      case 'quiz':
        return _QuizCard(slide: slide);

      default:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Unsupported slide: ${slide.contentType}'),
          ),
        );
    }
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.content});
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final url = content['url'] as String? ?? '';
    final alt = content['alt'] as String? ?? '';
    final mime = content['mime'] as String?;
    final fitStr = (content['fit'] as String?) ?? 'cover';
    final fit = switch (fitStr) {
      'contain' => BoxFit.contain,
      'fill' => BoxFit.fill,
      'cover' => BoxFit.cover,
      _ => BoxFit.cover,
    };

    final base64Data = content['bytes'] as String?;
    Uint8List? bytes;
    if (base64Data != null && base64Data.isNotEmpty) {
      try {
        bytes = base64Decode(base64Data);
      } catch (_) {}
    }

    final isSvg =
        (mime == 'image/svg+xml') || url.toLowerCase().endsWith('.svg');

    Widget imageWidget;
    if (bytes != null) {
      imageWidget = isSvg
          ? SvgPicture.memory(bytes, fit: fit)
          : Image.memory(bytes, fit: fit);
    } else {
      if (url.isEmpty) return const SizedBox.shrink();
      imageWidget = isSvg
          ? SvgPicture.network(url, fit: fit)
          : Image.network(url, fit: fit);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          if (alt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(alt, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

class _FinishBar extends StatelessWidget {
  const _FinishBar({required this.isCompleted, this.onFinish});
  final bool isCompleted;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (isCompleted) ...[
              const Icon(Icons.check_circle, size: 20),
              const SizedBox(width: 8),
              const Text('Lesson is completed'),
            ] else ...[
              const Text('You are on the last step'),
              const Spacer(),
              FilledButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.flag),
                label: const Text('Finish lesson'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends ConsumerWidget {
  const _QuizCard({required this.slide});
  final LessonSlide slide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = slide.content['question'] as String? ?? '';
    final answers = (slide.content['answers'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    final correctIndex = (slide.content['correctIndex'] as num?)?.toInt();
    final explanation = slide.content['explanation'] as String?;

    final selected = ref.watch(quizSelectedProvider(slide.id));
    final revealed = ref.watch(quizRevealedProvider(slide.id));
    final wrongIndex = ref.watch(quizWrongIndexProvider(slide.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (q.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(q, style: Theme.of(context).textTheme.titleMedium),
              ),

            for (int i = 0; i < answers.length; i++)
              _AnswerOptionTile(
                index: i,
                text: answers[i],
                selectedIndex: selected,
                correctIndex: correctIndex,
                revealed: revealed,
                wrongIndex: wrongIndex,
                onSelect: revealed
                    ? null
                    : () {
                        ref
                                .read(quizSelectedProvider(slide.id).notifier)
                                .state =
                            i;
                        ref
                                .read(quizWrongIndexProvider(slide.id).notifier)
                                .state =
                            null;
                      },
              ),

            const SizedBox(height: 8),

            Row(
              children: [
                FilledButton(
                  onPressed: (selected == null)
                      ? null
                      : () {
                          if (selected == correctIndex) {
                            ref
                                    .read(
                                      quizRevealedProvider(slide.id).notifier,
                                    )
                                    .state =
                                true;
                            ref
                                    .read(
                                      quizWrongIndexProvider(slide.id).notifier,
                                    )
                                    .state =
                                null;
                          } else {
                            ref
                                    .read(
                                      quizWrongIndexProvider(slide.id).notifier,
                                    )
                                    .state =
                                selected;
                          }
                        },
                  child: const Text('Check answer'),
                ),
                const SizedBox(width: 12),
                if (revealed)
                  TextButton(
                    onPressed: () {
                      ref.read(quizSelectedProvider(slide.id).notifier).state =
                          null;
                      ref.read(quizRevealedProvider(slide.id).notifier).state =
                          false;
                      ref
                              .read(quizWrongIndexProvider(slide.id).notifier)
                              .state =
                          null;
                    },
                    child: const Text('Try again'),
                  ),
              ],
            ),

            if (!revealed && wrongIndex != null) ...[
              const SizedBox(height: 12),
              const _WrongTryAgainBanner(),
            ],

            if (revealed) ...[
              const SizedBox(height: 12),
              _ResultBanner(correct: true, explanation: explanation),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({
    required this.index,
    required this.text,
    required this.selectedIndex,
    required this.correctIndex,
    required this.revealed,
    required this.wrongIndex,
    required this.onSelect,
  });

  final int index;
  final String text;
  final int? selectedIndex;
  final int? correctIndex;
  final bool revealed;
  final int? wrongIndex;
  final VoidCallback? onSelect;

  bool get _isSelected => selectedIndex == index;
  bool get _isCorrect => correctIndex == index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const Color greenBorder = Colors.green;
    final greenBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.green.withValues(alpha: 0.25)
        : Colors.green.withValues(alpha: 0.12);

    final isMarkedWrong =
        wrongIndex != null && wrongIndex == index && !revealed;

    late Color bg;
    late Color border;
    IconData? leadIcon;
    var opacity = 1.0;

    if (revealed && _isCorrect) {
      bg = greenBg;
      border = greenBorder;
      leadIcon = Icons.check_circle_rounded;
    } else if (isMarkedWrong) {
      bg = cs.errorContainer;
      border = cs.error;
      leadIcon = Icons.close_rounded;
    } else if (!revealed && _isSelected) {
      bg = cs.primaryContainer;
      border = cs.primary;
    } else if (revealed) {
      bg = Colors.transparent;
      border = cs.outlineVariant;
      opacity = 0.6;
    } else {
      bg = Colors.transparent;
      border = cs.outlineVariant;
    }

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border, width: 1.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                if (leadIcon != null) ...[
                  Icon(leadIcon, size: 20),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 10),
                _AnswerIndexBadge(
                  number: index + 1,
                  revealed: revealed,
                  isCorrect: revealed && _isCorrect,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerIndexBadge extends StatelessWidget {
  const _AnswerIndexBadge({
    required this.number,
    required this.revealed,
    required this.isCorrect,
  });

  final int number;
  final bool revealed;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isCorrect
        ? Colors.green
        : (revealed ? cs.surfaceContainerHighest : cs.surfaceContainerHighest);
    final fg = isCorrect
        ? Colors.white
        : Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}

class _WrongTryAgainBanner extends StatelessWidget {
  const _WrongTryAgainBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close_rounded, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wrong', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  "Try again. Don't give up!",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.correct, this.explanation});
  final bool correct;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = correct
        ? (Theme.of(context).brightness == Brightness.dark
              ? Colors.green.withValues(alpha: 0.25)
              : Colors.green.withValues(alpha: 0.12))
        : cs.errorContainer;

    final icon = correct ? Icons.check_circle : Icons.close_rounded;
    final title = correct ? 'Correct!' : 'Not quite';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (explanation != null && explanation!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    explanation!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockRenderer extends StatelessWidget {
  const _BlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final type = (block['type'] as String?)?.toLowerCase() ?? 'paragraph';
    switch (type) {
      case 'hero':
        return _HeroBlock(
          asset: block['asset'] as String?,
          url: block['url'] as String?,
          height: (block['height'] as num?)?.toDouble() ?? 160,
          align: (block['align'] as String?) ?? 'center',
          caption: block['caption'] as String?,
        );
      case 'callout':
        return _CalloutBlock(
          text: (block['text'] as String?) ?? '',
          flavor: (block['flavor'] as String?) ?? 'info',
        );
      case 'list':
        return _ListBlock(
          items: (block['items'] as List? ?? const [])
              .map((e) => e.toString())
              .toList(),
          numbered: (block['style'] as String?) == 'number',
        );
      case 'quote':
        return _QuoteBlock(text: (block['text'] as String?) ?? '');
      case 'code':
        return _CodeBlock(
          lang: (block['lang'] as String?) ?? 'text',
          code: (block['code'] as String?) ?? '',
        );
      case 'paragraph':
      default:
        return _MarkdownParagraph(
          _normalizeMd((block['text'] as String?) ?? ''),
        );
    }
  }
}

class _MarkdownParagraph extends StatelessWidget {
  const _MarkdownParagraph(this.md);
  final String md;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MarkdownBody(
        data: md,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: const TextStyle(fontSize: 16, height: 1.5),
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.35,
          ),
          codeblockDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(width: 4, color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({
    required this.height,
    required this.align,
    this.asset,
    this.url,
    this.caption,
  });
  final String? asset;
  final String? url;
  final double height;
  final String align;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final w = (asset != null && asset!.toLowerCase().endsWith('.svg'))
        ? SvgPicture.asset(asset!, height: height)
        : (asset != null)
        ? Image.asset(asset!, height: height)
        : (url != null && url!.toLowerCase().endsWith('.svg'))
        ? SvgPicture.network(url!, height: height)
        : (url != null)
        ? Image.network(url!, height: height)
        : const SizedBox.shrink();

    final alignment = switch (align) {
      'start' => Alignment.centerLeft,
      'end' => Alignment.centerRight,
      _ => Alignment.center,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Align(alignment: alignment, child: w),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                caption!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _CalloutBlock extends StatelessWidget {
  const _CalloutBlock({required this.text, required this.flavor});
  final String text;
  final String flavor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    (Color bg, IconData icon) byFlavor(String f) {
      switch (f) {
        case 'tip':
          return (cs.primaryContainer, Icons.lightbulb);
        case 'warn':
          return (cs.errorContainer, Icons.warning_amber_rounded);
        case 'success':
          return (cs.tertiaryContainer, Icons.check_circle);
        default:
          return (cs.secondaryContainer, Icons.info);
      }
    }

    final pair = byFlavor(flavor);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pair.$1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(pair.$2, size: 20),
          const SizedBox(width: 10),
          Expanded(child: _MarkdownParagraph(text)),
        ],
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({required this.items, required this.numbered});
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    numbered ? '${i + 1}.' : '• ',
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: _MarkdownParagraph(items[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 4, color: Theme.of(context).dividerColor),
        ),
      ),
      child: _MarkdownParagraph(text),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.lang, required this.code});
  final String lang;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText('[$lang]\n$code'),
      ),
    );
  }
}

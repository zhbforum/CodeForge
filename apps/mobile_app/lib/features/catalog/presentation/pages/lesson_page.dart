import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    return Column(
      children: [
        _OrderNavBar(
          current: clamped,
          min: minOrder,
          max: maxOrder,
          onPrev: clamped > minOrder
              ? () => ref.read(currentOrderProvider(lessonId).notifier).state =
                    clamped - 1
              : null,
          onNext: clamped < maxOrder
              ? () => ref.read(currentOrderProvider(lessonId).notifier).state =
                    clamped + 1
              : null,
        ),
        const Divider(height: 1),
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
      ],
    );
  }
}

class _OrderNavBar extends StatelessWidget {
  const _OrderNavBar({
    required this.current,
    required this.min,
    required this.max,
    this.onPrev,
    this.onNext,
  });

  final int current;
  final int min;
  final int max;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: cs.surfaceContainerHighest,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            tooltip: 'Назад',
          ),
          const SizedBox(width: 8),
          Text('Шаг $current из $max'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            tooltip: 'Далее',
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
          final raw =
              slide.content['markdown'] as String? ??
              slide.content['text'] as String? ??
              '';
          final md = _normalizeMd(raw);

          final alignStr = slide.content['align'] as String?;
          final cross = switch (alignStr) {
            'center' => CrossAxisAlignment.center,
            'end' => CrossAxisAlignment.end,
            _ => CrossAxisAlignment.start,
          };
          final isCenter = alignStr == 'center';

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: cross,
                children: [
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
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
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: MarkdownBody(
                        data: md,
                        selectable: true,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              h1: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              h2: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                              h3: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                              p: const TextStyle(fontSize: 16, height: 1.4),
                              strong: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              listBullet: const TextStyle(fontSize: 16),
                              code: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                height: 1.35,
                              ),
                              codeblockDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              blockquoteDecoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    width: 4,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                            ),
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
        {
          final q = slide.content['question'] as String? ?? '';
          final answers =
              (slide.content['answers'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const <String>[];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (q.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        q,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  for (final a in answers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $a'),
                    ),
                ],
              ),
            ),
          );
        }

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

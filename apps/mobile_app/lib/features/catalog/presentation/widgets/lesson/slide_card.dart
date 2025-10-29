import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/quiz_card.dart';

String normalizeMd(String s) => s
    .replaceAll('\r\n', '\n')
    .replaceAll(r'\r\n', '\n')
    .replaceAll(r'\n', '\n');

class SlideCard extends StatelessWidget {
  const SlideCard({required this.slide, super.key});
  final LessonSlide slide;

  @override
  Widget build(BuildContext context) {
    switch (slide.contentType) {
      case 'text':
        return _TextCard(content: slide.content);
      case 'image':
        return _ImageCard(content: slide.content);
      case 'code':
        return _CodeCard(content: slide.content);
      case 'quiz':
        return QuizCard(slide: slide);
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

class _TextCard extends StatelessWidget {
  const _TextCard({required this.content});
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final title = content['title'] as String? ?? '';
    final alignStr = content['align'] as String?;
    final cross = switch (alignStr) {
      'center' => CrossAxisAlignment.center,
      'end' => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    };
    final isCenter = alignStr == 'center';

    final blocks =
        (content['blocks'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        const <Map<String, dynamic>>[];

    final raw =
        content['markdown'] as String? ?? content['text'] as String? ?? '';

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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: isCenter ? TextAlign.center : TextAlign.start,
                ),
              ),
            Align(
              alignment: isCenter ? Alignment.center : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (blocks.isEmpty)
                      _MarkdownParagraph(normalizeMd(raw))
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

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.content});
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final lang = content['lang'] as String? ?? 'text';
    final code = content['code'] as String? ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText('[$lang]\n$code'),
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
        return _InlineCodeBlock(
          lang: (block['lang'] as String?) ?? 'text',
          code: (block['code'] as String?) ?? '',
        );
      case 'paragraph':
      default:
        return _MarkdownParagraph(
          normalizeMd((block['text'] as String?) ?? ''),
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

class _InlineCodeBlock extends StatelessWidget {
  const _InlineCodeBlock({required this.lang, required this.code});
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

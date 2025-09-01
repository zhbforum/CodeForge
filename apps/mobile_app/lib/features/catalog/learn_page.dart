import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/features/catalog/controllers/learn_controller.dart';
import 'package:mobile_app/features/catalog/widgets/track_card.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTracks = ref.watch(tracksProvider);
    const selectedId =
        TrackId.fullstack; // TODO(zhforum): in future take it from settings/profile 

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: asyncTracks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load tracks: $e')),
        data: (tracks) => LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            final crossAxisCount = w < 420
                ? 1
                : w < 900
                ? 2
                : w < 1400
                ? 3
                : 4;

            final childAspectRatio = w < 420
                ? 2.6
                : w < 900
                ? 1.45
                : 2.2;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: tracks.length,
                  itemBuilder: (_, i) {
                    final t = tracks[i];
                    final isDesktop = w >= 1200;
                    return TrackCard(
                      track: t,
                      highlighted: t.id == selectedId,
                      dense: isDesktop,
                      onTap: () => context.go('/home/track/${t.id.name}'),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

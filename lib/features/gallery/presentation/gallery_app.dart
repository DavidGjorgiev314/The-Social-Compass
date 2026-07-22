import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/asset_photo.dart';
import '../../../models/photo_request.dart';
import '../../game/application/game_controller.dart';
import '../../phone_shell/application/shell_controller.dart';
import '../../phone_shell/presentation/widgets/app_frame.dart';
import '../data/gallery_content.dart';
import '../domain/gallery_photo.dart';

class GalleryApp extends ConsumerWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = buildGallery();
    final request =
        ref.watch(gameControllerProvider.select((s) => s.asData?.value.pendingPhoto));

    return AppFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          if (request != null) _RequestBanner(request: request),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.sm),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) => _PhotoTile(
                photo: photos[i],
                onTap: () => _onTapPhoto(context, ref, photos[i], request),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: const [
          Text(
            'Gallery',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Spacer(),
          Icon(Icons.collections_rounded, color: AppColors.mint),
        ],
      ),
    );
  }

  Future<void> _onTapPhoto(
    BuildContext context,
    WidgetRef ref,
    GalleryPhoto photo,
    PhotoRequest? request,
  ) async {
    Haptics.tap();
    if (request == null) {
      _showViewer(context, photo);
      return;
    }
    final send = await _confirmSend(context, photo, request);
    if (send != true) return;

    await ref.read(gameControllerProvider.notifier).sendPhotoFromGallery(
          photo.asset,
          isPrivate: photo.isPrivate,
          caption: photo.caption,
        );
    // Return to the phone; the reply lands as a notification banner shortly.
    ref.read(shellControllerProvider.notifier).closeApp();
  }

  void _showViewer(BuildContext context, GalleryPhoto photo) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AspectRatio(
            aspectRatio: 1,
            child: resilientAsset(
              photo.asset,
              cacheWidth: 1080,
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: photo.gradient),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmSend(
    BuildContext context,
    GalleryPhoto photo,
    PhotoRequest request,
  ) {
    final warn = request.riskyOnly && photo.isPrivate;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.osSurfaceHigh,
        title: Text(
          'Send to ${request.senderName}?',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 1,
                child: resilientAsset(
                  photo.asset,
                  cacheWidth: 720,
                  fallback: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: photo.gradient),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              warn
                  ? 'This is a personal photo of you, and you barely know this '
                      'person. Once you send it, you can\'t take it back.'
                  : 'Send “${photo.label}” to ${request.senderName}?',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Send',
              style: TextStyle(
                color: warn ? AppColors.danger : AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestBanner extends StatelessWidget {
  const _RequestBanner({required this.request});

  final PhotoRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_camera_back_rounded,
              color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${request.prompt}\nTap a photo to send it — or press home to go back.',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.onTap});

  final GalleryPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          resilientAsset(
            photo.asset,
            cacheWidth: 360,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: photo.gradient),
              ),
            ),
          ),
          if (photo.isPrivate)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.lock_rounded, size: 14, color: Colors.white),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                photo.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

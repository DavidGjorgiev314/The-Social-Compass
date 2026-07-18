import 'package:flutter/material.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/haptics/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/asset_photo.dart';
import '../../data/ambient_content.dart';
import '../../domain/pixelgram_models.dart';
import 'pixel_avatar.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late final List<FeedPost> _posts = buildAmbientFeed();

  void _toggleLike(FeedPost post) {
    Haptics.light();
    AudioService.instance.play(Sfx.like);
    setState(() {
      post.liked = !post.liked;
      post.likes += post.liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _storiesRow(),
        const Divider(height: 1, color: AppColors.hairline),
        for (final post in _posts) _PostCard(post: post, onLike: () => _toggleLike(post)),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _storiesRow() {
    final accounts = [
      Accounts.maya,
      Accounts.devon,
      Accounts.nadia,
      Accounts.ava,
      Accounts.tyler,
      Accounts.leo,
    ];
    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: accounts.length,
        itemBuilder: (context, i) {
          final a = accounts[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              children: [
                PixelAvatar(avatar: a.avatar, radius: 28, ring: true),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: 64,
                  child: Text(
                    a.name.split(' ').first,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onLike});

  final FeedPost post;
  final VoidCallback onLike;

  Widget _image(FeedPost post) {
    final gradient = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: post.imageGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
    if (post.imageAsset == null) return gradient;
    return resilientAsset(
      post.imageAsset!,
      width: double.infinity,
      cacheWidth: 1080,
      fallback: gradient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              PixelAvatar(avatar: post.author.avatar, radius: 17),
              const SizedBox(width: AppSpacing.sm),
              Text(
                post.author.handle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
              if (post.author.verified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified_rounded, size: 14, color: AppColors.accent),
              ],
              const Spacer(),
              const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
        AspectRatio(aspectRatio: 1, child: _image(post)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(
                  post.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: post.liked ? AppColors.danger : AppColors.textPrimary,
                ),
              ),
              const IconButton(
                onPressed: null,
                icon: Icon(Icons.mode_comment_outlined, color: AppColors.textPrimary),
              ),
              const IconButton(
                onPressed: null,
                icon: Icon(Icons.send_outlined, color: AppColors.textPrimary),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border_rounded, color: AppColors.textPrimary),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${post.likes} likes',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${post.author.handle} ',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: post.caption,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View all ${post.comments} comments',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 2),
              Text(
                '${post.timeAgo} ago',
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/haptics/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../chat/presentation/chat_screen.dart';
import '../../../game/application/game_controller.dart';
import '../../../narrative/application/story_beats.dart';
import '../../../narrative/data/story_graph.dart';
import '../../../narrative/presentation/story_chat_screen.dart';
import '../../data/ambient_content.dart';
import '../../domain/pixelgram_models.dart';
import 'pixel_avatar.dart';

class InboxView extends ConsumerWidget {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = buildAmbientInbox();
    final direct = all.where((c) => !c.isRequest).toList();
    final requests = all.where((c) => c.isRequest).toList();
    final game = ref.watch(gameControllerProvider).asData?.value;
    final showStory = game != null && game.profile.completed;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      children: [
        if (showStory) _StoryTile(currentNodeId: game.currentNodeId),
        if (requests.isNotEmpty) _RequestsRow(requests: requests),
        for (final c in direct) _ConversationTile(conversation: c),
      ],
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.currentNodeId});

  final String currentNodeId;

  @override
  Widget build(BuildContext context) {
    final node = storyNode(currentNodeId);
    final title = node != null ? channelName(node.conversationId) : 'Pixelgram';

    return Column(
      children: [
        ListTile(
          onTap: () {
            Haptics.tap();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StoryChatScreen()),
            );
          },
          leading: const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.accentSecondary,
            child: Icon(Icons.forum_rounded, color: Colors.white),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accentSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: AppColors.accentSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          subtitle: const Text(
            'Tap to continue your week',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.hairline),
      ],
    );
  }
}

void _openConversation(BuildContext context, InboxConversation c) {
  Haptics.tap();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        title: c.account.name,
        script: c.script,
        seed: c.history,
        accent: c.account.avatar.color,
      ),
    ),
  );
}

class _RequestsRow extends StatelessWidget {
  const _RequestsRow({required this.requests});

  final List<InboxConversation> requests;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () => _openConversation(context, requests.first),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.osSurfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Icon(Icons.mail_outline_rounded, color: AppColors.accent),
          ),
          title: const Text(
            'Message requests',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            '${requests.length} new — ${requests.first.account.name} and others',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.accent, fontSize: 13),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ),
        const Divider(height: 1, color: AppColors.hairline),
      ],
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final InboxConversation conversation;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final unreadStyle = c.unread > 0;
    return ListTile(
      onTap: () => _openConversation(context, c),
      leading: PixelAvatar(avatar: c.account.avatar, radius: 26),
      title: Text(
        c.account.name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        c.previewText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unreadStyle ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: unreadStyle ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            c.timeAgo,
            style: TextStyle(
              color: unreadStyle ? AppColors.accent : AppColors.textTertiary,
              fontSize: 11.5,
              fontWeight: unreadStyle ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          if (c.unread > 0)
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${c.unread}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/haptics/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/round_photo.dart';
import '../../../chat/presentation/chat_screen.dart';
import '../../../../models/game_state.dart';
import '../../../game/application/game_controller.dart';
import '../../../narrative/application/story_beats.dart';
import '../../../narrative/data/story_graph.dart';
import '../../../narrative/presentation/conversation_screen.dart';
import '../../data/ambient_content.dart';
import '../../domain/pixelgram_models.dart';
import 'pixel_avatar.dart';

class InboxView extends ConsumerWidget {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider).asData?.value;
    final ambient = buildAmbientInbox();
    final direct = ambient.where((c) => !c.isRequest).toList();
    final requests = ambient.where((c) => c.isRequest).toList();

    final storyThreads = _storyThreads(game);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      children: [
        for (final t in storyThreads) _StoryThreadTile(thread: t),
        if (storyThreads.isNotEmpty)
          const Divider(height: 1, color: AppColors.hairline),
        if (requests.isNotEmpty)
          _RequestsRow(requests: requests, game: game),
        for (final c in direct)
          _ConversationTile(conversation: c, game: game),
      ],
    );
  }

  List<_ThreadInfo> _storyThreads(GameState? game) {
    if (game == null) return const [];
    final currentConv = storyNode(game.currentNodeId)?.conversationId;
    final infos = <_ThreadInfo>[];
    game.threads.forEach((conv, messages) {
      if (messages.isEmpty) return;
      infos.add(_ThreadInfo(
        conversationId: conv,
        preview: messages.last.text,
        unread: game.isUnread(conv),
        isCurrent: conv == currentConv,
      ));
    });
    infos.sort((a, b) {
      if (a.isCurrent != b.isCurrent) return a.isCurrent ? -1 : 1;
      if (a.unread != b.unread) return a.unread ? -1 : 1;
      return 0;
    });
    return infos;
  }
}

class _ThreadInfo {
  const _ThreadInfo({
    required this.conversationId,
    required this.preview,
    required this.unread,
    required this.isCurrent,
  });

  final String conversationId;
  final String preview;
  final bool unread;
  final bool isCurrent;
}

class _StoryThreadTile extends StatelessWidget {
  const _StoryThreadTile({required this.thread});

  final _ThreadInfo thread;

  @override
  Widget build(BuildContext context) {
    final avatar = channelAvatar(thread.conversationId);
    return ListTile(
      onTap: () {
        Haptics.tap();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ConversationScreen(conversationId: thread.conversationId),
          ),
        );
      },
      leading: RoundPhoto(
        asset: avatar.asset,
        color: avatar.color,
        initial: avatar.initial,
        radius: 26,
      ),
      title: Text(
        channelName(thread.conversationId),
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        thread.preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: thread.unread ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: thread.unread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: thread.unread
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

void _openAmbient(BuildContext context, WidgetRef ref, InboxConversation c) {
  Haptics.tap();
  ref.read(gameControllerProvider.notifier).openConversation(c.id);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        title: c.account.name,
        script: c.script,
        seed: c.history,
        accent: c.account.avatar.color,
        avatarAsset: c.account.avatar.asset,
      ),
    ),
  );
}

bool _ambientUnread(GameState? game, InboxConversation c) {
  final stored = game?.unread[c.id];
  if (stored != null) return stored;
  return c.unread > 0;
}

class _RequestsRow extends ConsumerWidget {
  const _RequestsRow({required this.requests, required this.game});

  final List<InboxConversation> requests;
  final GameState? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = requests.any((r) => _ambientUnread(game, r));
    return Column(
      children: [
        ListTile(
          onTap: () => _openAmbient(context, ref, requests.first),
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
            '${requests.first.account.name} and others',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unread ? AppColors.accent : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ),
        const Divider(height: 1, color: AppColors.hairline),
      ],
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation, required this.game});

  final InboxConversation conversation;
  final GameState? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = conversation;
    final unread = _ambientUnread(game, c);
    return ListTile(
      onTap: () => _openAmbient(context, ref, c),
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
          color: unread ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            c.timeAgo,
            style: TextStyle(
              color: unread ? AppColors.accent : AppColors.textTertiary,
              fontSize: 11.5,
              fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          if (unread)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}

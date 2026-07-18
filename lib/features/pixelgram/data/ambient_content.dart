import 'package:flutter/material.dart';

import '../../chat/domain/chat_models.dart';
import '../domain/pixelgram_models.dart';

class Accounts {
  Accounts._();

  static const maya = SocialAccount(
    handle: 'maya.chen',
    name: 'Maya Chen',
    avatar: Avatar(color: Color(0xFFFF6FA5), initial: 'M'),
  );
  static const devon = SocialAccount(
    handle: 'devonbrooks',
    name: 'Devon Brooks',
    avatar: Avatar(color: Color(0xFF4C8DFF), initial: 'D'),
    verified: true,
  );
  static const nadia = SocialAccount(
    handle: 'nadia.draws',
    name: 'Nadia Rahman',
    avatar: Avatar(color: Color(0xFF43E0B8), initial: 'N'),
  );
  static const tyler = SocialAccount(
    handle: 'tyler.vance',
    name: 'Tyler Vance',
    avatar: Avatar(color: Color(0xFFFFC15E), initial: 'T'),
  );
  static const kai = SocialAccount(
    handle: 'kai_from_home',
    name: 'Kai',
    avatar: Avatar(color: Color(0xFF9B8CFF), initial: 'K'),
  );
  static const mom = SocialAccount(
    handle: 'mom',
    name: 'Mom',
    avatar: Avatar(color: Color(0xFFFF8A5B), initial: 'M'),
  );
  static const campus = SocialAccount(
    handle: 'northgate.campus',
    name: 'Northgate Campus',
    avatar: Avatar(color: Color(0xFF2C9C8A), initial: 'N'),
    verified: true,
  );
  static const ava = SocialAccount(
    handle: 'ava.rivers',
    name: 'Ava Rivers',
    avatar: Avatar(color: Color(0xFFE0972C), initial: 'A'),
  );
  static const leo = SocialAccount(
    handle: 'leo.dfw',
    name: 'Leo Diaz',
    avatar: Avatar(color: Color(0xFF5AC8FA), initial: 'L'),
  );
}

List<FeedPost> buildAmbientFeed() => [
      FeedPost(
        id: 'p1',
        author: Accounts.devon,
        caption: 'season opener saturday. we are NOT losing this one 🏀🔥',
        imageGradient: const [Color(0xFF4C8DFF), Color(0xFF2C5AB0)],
        likes: 342,
        comments: 57,
        timeAgo: '25m',
      ),
      FeedPost(
        id: 'p2',
        author: Accounts.nadia,
        caption: 'stayed up way too late finishing this one 🎨 be nice lol',
        imageGradient: const [Color(0xFF43E0B8), Color(0xFF8E7BFF)],
        likes: 96,
        comments: 12,
        timeAgo: '1h',
      ),
      FeedPost(
        id: 'p3',
        author: Accounts.campus,
        caption: 'Club Fair is this Friday in the Main Hall, 11am–3pm. Come find your people!',
        imageGradient: const [Color(0xFF2C9C8A), Color(0xFF1F6E8C)],
        likes: 210,
        comments: 8,
        timeAgo: '2h',
      ),
      FeedPost(
        id: 'p4',
        author: Accounts.ava,
        caption: 'campus coffee > everything. this is not up for debate ☕',
        imageGradient: const [Color(0xFFFFD36E), Color(0xFFFF9F45)],
        likes: 128,
        comments: 19,
        timeAgo: '3h',
      ),
      FeedPost(
        id: 'p5',
        author: Accounts.maya,
        caption: 'first week down 😮‍💨 met some cool new people already',
        imageGradient: const [Color(0xFFFF9A8B), Color(0xFFFF6B9A)],
        likes: 154,
        comments: 23,
        timeAgo: '5h',
      ),
      FeedPost(
        id: 'p6',
        author: Accounts.leo,
        caption: 'skate spot behind the library is unreal at sunset 🛹',
        imageGradient: const [Color(0xFF5AC8FA), Color(0xFF3E7BFA)],
        likes: 88,
        comments: 6,
        timeAgo: '7h',
      ),
    ];

ChatMessage _msg(int i, String text, String senderId, String senderName,
        bool fromPlayer) =>
    ChatMessage(
      id: 'h$i',
      text: text,
      senderId: senderId,
      senderName: senderName,
      fromPlayer: fromPlayer,
    );

List<InboxConversation> buildAmbientInbox() => [
      InboxConversation(
        id: 'c_kai',
        account: Accounts.kai,
        previewText: 'miss you already man, how\'s the new place??',
        timeAgo: '2h',
        history: [
          _msg(0, 'yooo how\'s the new school', 'kai', 'Kai', false),
          _msg(1, 'honestly kind of overwhelming lol', 'player', 'You', true),
          _msg(2, 'you\'ll be running the place in a week, trust', 'kai', 'Kai', false),
          _msg(3, 'miss you already man, how\'s the new place??', 'kai', 'Kai', false),
        ],
      ),
      InboxConversation(
        id: 'c_tyler',
        account: Accounts.tyler,
        previewText: 'yo you in the econ group project?',
        timeAgo: '4h',
        unread: 1,
        history: [
          _msg(0, 'yo you in the econ group project?', 'tyler', 'Tyler', false),
        ],
      ),
      InboxConversation(
        id: 'c_mom',
        account: Accounts.mom,
        previewText: 'Did you eat something proper today?',
        timeAgo: '6h',
        history: [
          _msg(0, 'How was your first day sweetheart?', 'mom', 'Mom', false),
          _msg(1, 'it was good! made a couple friends', 'player', 'You', true),
          _msg(2, 'That\'s wonderful ❤️', 'mom', 'Mom', false),
          _msg(3, 'Did you eat something proper today?', 'mom', 'Mom', false),
        ],
      ),
      InboxConversation(
        id: 'c_ava',
        account: Accounts.ava,
        previewText: 'we should get coffee sometime!',
        timeAgo: '1d',
        history: [
          _msg(0, 'saw you in the library, you\'re new right?', 'ava', 'Ava', false),
          _msg(1, 'yeah just transferred in', 'player', 'You', true),
          _msg(2, 'we should get coffee sometime!', 'ava', 'Ava', false),
        ],
      ),
      InboxConversation(
        id: 'c_leo',
        account: Accounts.leo,
        previewText: 'wants to send you a message',
        timeAgo: '1d',
        isRequest: true,
        history: [
          _msg(0, 'hey! saw you followed the skate club page, you skate?',
              'leo', 'Leo', false),
        ],
      ),
    ];

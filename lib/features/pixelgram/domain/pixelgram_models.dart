import 'package:flutter/material.dart';

import '../../chat/domain/chat_models.dart';

class Avatar {
  const Avatar({required this.color, required this.initial, this.asset});

  final Color color;
  final String initial;
  final String? asset;
}

class SocialAccount {
  const SocialAccount({
    required this.handle,
    required this.name,
    required this.avatar,
    this.verified = false,
  });

  final String handle;
  final String name;
  final Avatar avatar;
  final bool verified;
}

class FeedPost {
  FeedPost({
    required this.id,
    required this.author,
    required this.caption,
    required this.imageGradient,
    this.imageAsset,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.liked = false,
  });

  final String id;
  final SocialAccount author;
  final String caption;
  final List<Color> imageGradient;
  final String? imageAsset;
  final int comments;
  final String timeAgo;
  int likes;
  bool liked;
}

class InboxConversation {
  const InboxConversation({
    required this.id,
    required this.account,
    required this.previewText,
    required this.timeAgo,
    this.unread = 0,
    this.isRequest = false,
    this.storyline = false,
    this.history = const [],
    this.script = const [],
  });

  final String id;
  final SocialAccount account;
  final String previewText;
  final String timeAgo;
  final int unread;
  final bool isRequest;
  final bool storyline;
  final List<ChatMessage> history;
  final List<ChatBeat> script;
}

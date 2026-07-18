import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/chat_models.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.options = const [],
    this.composerText = '',
    this.npcTypingName,
    this.playerTyping = false,
    this.awaitingChoice = false,
    this.complete = false,
  });

  final List<ChatMessage> messages;
  final List<ReplyOption> options;
  final String composerText;
  final String? npcTypingName;
  final bool playerTyping;
  final bool awaitingChoice;
  final bool complete;

  bool get npcTyping => npcTypingName != null;

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ReplyOption>? options,
    String? composerText,
    Object? npcTypingName = _sentinel,
    bool? playerTyping,
    bool? awaitingChoice,
    bool? complete,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      options: options ?? this.options,
      composerText: composerText ?? this.composerText,
      npcTypingName: npcTypingName == _sentinel
          ? this.npcTypingName
          : npcTypingName as String?,
      playerTyping: playerTyping ?? this.playerTyping,
      awaitingChoice: awaitingChoice ?? this.awaitingChoice,
      complete: complete ?? this.complete,
    );
  }

  static const Object _sentinel = Object();
}

class ChatController extends ChangeNotifier {
  ChatController({
    required List<ChatBeat> script,
    List<ChatMessage> seed = const [],
    this.onChoiceSelected,
  })  : _script = [...script],
        _state = ChatState(messages: seed);

  final List<ChatBeat> _script;
  final void Function(ReplyOption option)? onChoiceSelected;

  final Random _random = Random();
  int _index = 0;
  bool _started = false;
  bool _disposed = false;
  Timer? _typeTimer;
  String _pendingText = '';
  int _typedChars = 0;

  ChatState _state;
  ChatState get state => _state;

  void _set(ChatState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _typeTimer?.cancel();
    super.dispose();
  }

  void start() {
    if (_started) return;
    _started = true;
    _advance();
  }

  void enqueue(List<ChatBeat> beats) {
    final wasDrained = _index >= _script.length;
    _script.addAll(beats);
    if (_started && wasDrained && !_state.awaitingChoice && !_state.playerTyping) {
      _set(_state.copyWith(complete: false));
      _advance();
    }
  }

  Future<void> _advance() async {
    if (_disposed) return;
    if (_index >= _script.length) {
      _set(_state.copyWith(complete: true));
      return;
    }

    final beat = _script[_index];
    _index++;

    switch (beat) {
      case NpcLine():
        await _playNpcLine(beat);
      case PlayerChoice():
        _set(_state.copyWith(options: beat.options, awaitingChoice: true));
      case SystemLine():
        _playSystemLine(beat);
    }
  }

  void _playSystemLine(SystemLine line) {
    _set(_state.copyWith(
      messages: [
        ..._state.messages,
        ChatMessage(
          id: 'm${_state.messages.length}',
          text: line.text,
          senderId: 'system',
          senderName: line.text,
          fromPlayer: false,
          system: true,
        ),
      ],
    ));
    _advance();
  }

  Future<void> _playNpcLine(NpcLine line) async {
    await Future.delayed(Duration(milliseconds: 350 + _random.nextInt(650)));
    if (_disposed) return;

    _set(_state.copyWith(npcTypingName: line.senderName));
    await Future.delayed(Duration(milliseconds: 700 + _random.nextInt(1100)));
    if (_disposed) return;

    _set(_state.copyWith(
      npcTypingName: null,
      messages: [
        ..._state.messages,
        ChatMessage(
          id: 'm${_state.messages.length}',
          text: line.text,
          senderId: line.senderId,
          senderName: line.senderName,
          fromPlayer: false,
        ),
      ],
    ));

    await Future.delayed(const Duration(milliseconds: 250));
    if (_disposed) return;
    _advance();
  }

  void choose(ReplyOption option) {
    if (_state.playerTyping) return;
    onChoiceSelected?.call(option);
    _pendingText = option.text;
    _typedChars = 0;
    _set(_state.copyWith(
      options: const [],
      awaitingChoice: false,
      playerTyping: true,
      composerText: '',
    ));
    _scheduleNextChar();
  }

  void _scheduleNextChar() {
    _typeTimer = Timer(Duration(milliseconds: 40 + _random.nextInt(30)), () {
      if (_disposed) return;
      _typedChars++;
      if (_typedChars >= _pendingText.length) {
        _set(_state.copyWith(composerText: _pendingText));
        _finishTyping();
      } else {
        _set(_state.copyWith(composerText: _pendingText.substring(0, _typedChars)));
        _scheduleNextChar();
      }
    });
  }

  void skipTyping() {
    if (!_state.playerTyping) return;
    _typeTimer?.cancel();
    _typedChars = _pendingText.length;
    _set(_state.copyWith(composerText: _pendingText));
    _finishTyping();
  }

  Future<void> _finishTyping() async {
    await Future.delayed(const Duration(milliseconds: 320));
    if (_disposed) return;
    _set(_state.copyWith(
      playerTyping: false,
      composerText: '',
      messages: [
        ..._state.messages,
        ChatMessage(
          id: 'm${_state.messages.length}',
          text: _pendingText,
          senderId: 'player',
          senderName: 'You',
          fromPlayer: true,
        ),
      ],
    ));
    _pendingText = '';
    await Future.delayed(const Duration(milliseconds: 300));
    if (_disposed) return;
    _advance();
  }
}

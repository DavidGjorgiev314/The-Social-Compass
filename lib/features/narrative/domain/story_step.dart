sealed class StoryStep {
  const StoryStep();
}

class StoryArrived extends StoryStep {
  const StoryArrived(this.conversationId, {required this.sameConversation});
  final String conversationId;
  final bool sameConversation;
}

class StoryLockout extends StoryStep {
  const StoryLockout(this.seconds, this.nextNodeId);
  final int seconds;
  final String nextNodeId;
}

class StoryEnded extends StoryStep {
  const StoryEnded();
}

class StoryPaused extends StoryStep {
  const StoryPaused();
}

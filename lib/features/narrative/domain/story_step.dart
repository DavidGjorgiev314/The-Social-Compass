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

/// The player chose to send a photo: leave the chat and open the Gallery.
class StoryOpenGallery extends StoryStep {
  const StoryOpenGallery(this.conversationId);
  final String conversationId;
}

class StoryPaused extends StoryStep {
  const StoryPaused();
}

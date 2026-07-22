import '../../../models/game_state.dart';
import 'story_models.dart';

class Ending {
  const Ending({
    required this.id,
    required this.title,
    required this.description,
    required this.condition,
    this.isOverride = false,
    this.priority = 0,
  });

  final String id;
  final String title;
  final String description;
  final StoryCondition condition;
  final bool isOverride;
  final int priority;
}

class StoryFlags {
  StoryFlags._();

  static const defendedNadia = 'defended_nadia';
  static const phishedBadly = 'phished_badly';
  static const accountCompromised = 'account_compromised';
  static const creeperEscalated = 'creeper_escalated';
  static const madeAmends = 'made_amends';
  static const ignoredAll = 'ignored_all';
  static const joinedClique = 'joined_clique';
  static const reportedDevon = 'reported_devon';

  // Expanded storylines
  static const helpedNadia = 'helped_nadia';
  static const befriendedAva = 'befriended_ava';
  static const befriendedLeo = 'befriended_leo';
  static const turnedTyler = 'turned_tyler';
  static const neglectedKai = 'neglected_kai';
  static const toldAdult = 'told_adult';
  static const sharedPrivateWithStranger = 'shared_private_with_stranger';
  static const handledSextortion = 'handled_sextortion';
  static const blockedStranger = 'blocked_stranger';
  static const caughtImpostor = 'caught_impostor';
  static const clubFeature = 'club_feature';
}

const List<Ending> kEndings = [
  Ending(
    id: 'compromised',
    title: 'Compromised',
    description:
        'One careless tap handed over your account. Your friends got spammed, '
        'your name got dragged, and the week ended cleaning up a mess that '
        'was never really yours to begin with.',
    isOverride: true,
    priority: 100,
    condition: StoryCondition(flags: {StoryFlags.accountCompromised: true}),
  ),
  Ending(
    id: 'exploited',
    title: 'It Got Out',
    description:
        'A photo you sent to someone you barely knew became a leash. The '
        'threats, the silence, the dread of who\'d seen it — none of it was '
        'your fault, but you carried it alone when you didn\'t have to. The '
        'moment you tell a trusted adult is the moment it starts to end.',
    isOverride: true,
    priority: 95,
    condition: StoryCondition(
      flags: {
        StoryFlags.sharedPrivateWithStranger: true,
        StoryFlags.handledSextortion: false,
      },
    ),
  ),
  Ending(
    id: 'in_too_deep',
    title: 'In Too Deep',
    description:
        'What started as flattery from a stranger became something you '
        'couldn\'t control. Some doors are easier to open than to close.',
    isOverride: true,
    priority: 90,
    condition: StoryCondition(
      flags: {StoryFlags.creeperEscalated: true},
      maxAwareness: 45,
    ),
  ),
  Ending(
    id: 'the_digital_compass',
    title: 'The Digital Compass',
    description:
        'You stayed sharp, stayed kind, and stood up when it counted. You '
        'end the week with real friends who trust you and a clear sense of '
        'where your line is.',
    priority: 80,
    condition: StoryCondition(
      flags: {StoryFlags.defendedNadia: true, StoryFlags.phishedBadly: false},
      minTrust: 70,
      minAwareness: 70,
    ),
  ),
  Ending(
    id: 'found_your_people',
    title: 'Found Your People',
    description:
        'You didn\'t chase the loudest crowd. You showed up for Nadia, backed '
        'Ava\'s club, kept Kai close, and pulled Tyler out of Devon\'s orbit. '
        'A week in and you already know exactly who\'s worth your time.',
    priority: 76,
    condition: StoryCondition(
      flags: {StoryFlags.befriendedAva: true, StoryFlags.helpedNadia: true},
      minTrust: 55,
    ),
  ),
  Ending(
    id: 'outcast_conscience',
    title: 'The Outcast with a Conscience',
    description:
        'You did the right thing and it cost you the popular crowd. But the '
        'few who stayed are the ones who actually matter.',
    priority: 70,
    condition: StoryCondition(
      flags: {StoryFlags.defendedNadia: true},
      minTrust: 70,
      maxFriendship: 35,
    ),
  ),
  Ending(
    id: 'popular_but_hollow',
    title: 'Popular but Hollow',
    description:
        'Everyone knows your name. Nobody would call you when it mattered. '
        'You climbed by stepping on someone who needed a friend.',
    priority: 60,
    condition: StoryCondition(minFriendship: 70, maxTrust: 35),
  ),
  Ending(
    id: 'redemption',
    title: 'Turning It Around',
    description:
        'You started on the wrong side of it. But you owned it, made amends, '
        'and proved people can change mid-story.',
    priority: 50,
    condition: StoryCondition(flags: {StoryFlags.madeAmends: true}),
  ),
  Ending(
    id: 'ghost',
    title: 'Ghost',
    description:
        'You kept your head down and your profile locked. Nobody hurt you, '
        'nobody reached you either. A safe, quiet, lonely week.',
    priority: 40,
    condition: StoryCondition(maxFriendship: 25, minAwareness: 60),
  ),
  Ending(
    id: 'the_bystander',
    title: 'The Bystander',
    description:
        'You saw it all and chose to look away every time. Nothing touched '
        'you. That\'s exactly the problem.',
    priority: 10,
    condition: StoryCondition(),
  ),
];

Ending resolveEnding(GameState state, {List<Ending> endings = kEndings}) {
  final sorted = [...endings]..sort((a, b) => b.priority.compareTo(a.priority));
  for (final ending in sorted.where((e) => e.isOverride)) {
    if (ending.condition.matches(state)) return ending;
  }
  for (final ending in sorted.where((e) => !e.isOverride)) {
    if (ending.condition.matches(state)) return ending;
  }
  return sorted.last;
}

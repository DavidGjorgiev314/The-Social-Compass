import '../../game/application/game_controller.dart';
import '../domain/ending.dart';
import '../domain/story_models.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// THE DIGITAL COMPASS — branching, multi-storyline week.
///
/// The art-bullying thread (Nadia / Devon) is only ONE strand. Woven through
/// it: a stranger fishing for photos (Jordan then Riley), recurring phishing,
/// Maya's leaked-DM subplot, Ava's art club, Leo the skater, Tyler who can be
/// turned, Kai back home, and Mom. Choices set per-character relationships and
/// flags that reroute every later strand — a butterfly effect. Pivotal choices
/// drop a "will remember that" beat via [StoryChoice.memory].
/// ─────────────────────────────────────────────────────────────────────────
class Senders {
  Senders._();
  static const maya = ('maya', 'Maya');
  static const devon = ('devon', 'Devon');
  static const nadia = ('nadia', 'Nadia');
  static const tyler = ('tyler', 'Tyler');
  static const jordan = ('jordan', 'Jordan');
  static const ava = ('ava', 'Ava');
  static const leo = ('leo', 'Leo');
  static const kai = ('kai', 'Kai');
  static const mom = ('mom', 'Mom');
  static const riley = ('riley', 'Riley');
  static const scam = ('campus_rewards', 'Campus Rewards');
  static const security = ('pixelgram_security', 'Pixelgram Security');
  static const impostor = ('maya_chenn', 'maya_chenn');
}

// Local flag keys (relationship + scam bookkeeping).
const _fPhishedBadly = StoryFlags.phishedBadly;
const _fCreeperContact = 'creeper_contact';

StoryLine _line((String, String) sender, String text) =>
    StoryLine(senderId: sender.$1, senderName: sender.$2, text: text);

final Map<String, StoryNode> kStoryGraph = {
  // ═══════════════════════════ DAY 1 ═══════════════════════════
  'D1_START': StoryNode(
    id: 'D1_START',
    day: 1,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'hey!! so glad you made it into the group 🙌'),
      _line(Senders.maya, 'first week is a lot. i basically adopted you now, deal with it 😌'),
      _line(Senders.maya, 'quick heads up — the class group chat gets... wild lol'),
    ],
    choices: const [
      StoryChoice(
        id: 'warm',
        text: 'haha thanks for looking out 🙂 good to know',
        nextNodeId: 'D1_MAYA_2',
        delta: StatDelta(friendship: 8, trust: 4),
        rel: {'maya': 10},
      ),
      StoryChoice(
        id: 'guarded',
        text: 'wild how? should i be worried?',
        nextNodeId: 'D1_MAYA_2',
        delta: StatDelta(awareness: 5),
        rel: {'maya': 3},
      ),
      StoryChoice(
        id: 'cool',
        text: 'i can handle a group chat lol',
        nextNodeId: 'D1_MAYA_2',
        delta: StatDelta(friendship: 3),
        rel: {'maya': -2},
      ),
    ],
  ),
  'D1_MAYA_2': StoryNode(
    id: 'D1_MAYA_2',
    day: 1,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'so devon basically runs it. funny, loud, kind of mean sometimes'),
      _line(Senders.maya, 'and nadia posts her art in there which is brave bc people can be brutal'),
      _line(Senders.maya, 'anyway just be yourself. speaking of — devon\'s going off rn 👀'),
    ],
    choices: const [
      StoryChoice(
        id: 'ok',
        text: 'noted. going to check it out',
        nextNodeId: 'D1_GROUP_1',
        rel: {'maya': 3},
      ),
      StoryChoice(
        id: 'ask',
        text: 'is nadia ok? that sounds rough',
        nextNodeId: 'D1_GROUP_1',
        delta: StatDelta(trust: 6),
        rel: {'maya': 6, 'nadia': 4},
      ),
    ],
  ),
  'D1_GROUP_1': StoryNode(
    id: 'D1_GROUP_1',
    day: 1,
    conversationId: 'econ_group',
    lines: [
      _line(Senders.devon, 'yo did everyone see nadia\'s "art" she posted 💀'),
      _line(Senders.devon, 'who told her that was good enough to share lmao'),
      _line(Senders.tyler, 'LMAOO stop 😭'),
    ],
    choices: const [
      StoryChoice(
        id: 'ignore',
        text: '(say nothing)',
        nextNodeId: 'D1_KAI',
        delta: StatDelta(trust: -4),
        rel: {'nadia': -3},
      ),
      StoryChoice(
        id: 'join',
        text: 'lmaooo fr who does she think she is',
        nextNodeId: 'D1_KAI',
        delta: StatDelta(friendship: 14, trust: -15),
        rel: {'devon': 14, 'tyler': 6, 'nadia': -25, 'maya': -8},
        setFlags: {StoryFlags.joinedClique: true},
        memory: 'Devon will remember that.',
      ),
      StoryChoice(
        id: 'defend',
        text: 'not cool man. it takes guts to post your work',
        nextNodeId: 'D1_KAI',
        delta: StatDelta(trust: 15, friendship: -8),
        rel: {'nadia': 20, 'maya': 10, 'devon': -18, 'tyler': -4},
        setFlags: {StoryFlags.defendedNadia: true},
        memory: 'Nadia will remember that.',
      ),
      StoryChoice(
        id: 'report',
        text: '(report Devon\'s messages to the group admins)',
        nextNodeId: 'D1_KAI',
        delta: StatDelta(trust: 10, awareness: 10),
        rel: {'devon': -22, 'nadia': 8},
        setFlags: {StoryFlags.reportedDevon: true},
        memory: 'Devon will remember that.',
      ),
    ],
  ),
  'D1_KAI': StoryNode(
    id: 'D1_KAI',
    day: 1,
    conversationId: 'kai',
    lines: [
      _line(Senders.kai, 'yooo how\'s the fancy new school 😎'),
      _line(Senders.kai, 'weird not seeing you every day ngl'),
    ],
    choices: const [
      StoryChoice(
        id: 'warm',
        text: 'miss you too man. it\'s a lot but i\'m figuring it out',
        nextNodeId: 'D1_PHISH_1',
        delta: StatDelta(friendship: 6),
        rel: {'kai': 12},
      ),
      StoryChoice(
        id: 'busy',
        text: 'kinda slammed, talk later?',
        nextNodeId: 'D1_PHISH_1',
        rel: {'kai': -6},
        setFlags: {StoryFlags.neglectedKai: true},
      ),
      StoryChoice(
        id: 'brag',
        text: 'honestly? way cooler than home lol',
        nextNodeId: 'D1_PHISH_1',
        rel: {'kai': -12},
        setFlags: {StoryFlags.neglectedKai: true},
        memory: 'Kai will remember that.',
      ),
    ],
  ),
  'D1_PHISH_1': StoryNode(
    id: 'D1_PHISH_1',
    day: 1,
    kind: NodeKind.phishing,
    conversationId: 'campus_rewards',
    lines: [
      _line(Senders.scam, '🎉 CONGRATS! You\'ve been selected for a \$500 campus gift card!'),
      _line(Senders.scam, 'Claim in the next 10 min 👉 campusrewards-claim.link/win'),
    ],
    choices: const [
      StoryChoice(
        id: 'click',
        text: 'Tap the link to claim',
        nextNodeId: 'D1_LOCKOUT',
        delta: StatDelta(awareness: -15),
        setFlags: {'phish_hit_1': true, _fPhishedBadly: true},
      ),
      StoryChoice(
        id: 'delete',
        text: 'Delete it',
        nextNodeId: 'D1_END',
        delta: StatDelta(awareness: 5),
      ),
      StoryChoice(
        id: 'report',
        text: 'Report as spam',
        nextNodeId: 'D1_END',
        delta: StatDelta(awareness: 12, trust: 3),
      ),
    ],
  ),
  'D1_LOCKOUT': const StoryNode(
    id: 'D1_LOCKOUT',
    day: 1,
    kind: NodeKind.event,
    autoNextNodeId: 'D1_END',
    lockoutSeconds: 30,
  ),
  'D1_END': const StoryNode(
    id: 'D1_END',
    day: 1,
    kind: NodeKind.dayBreak,
    autoNextNodeId: 'D2_START',
  ),

  // ═══════════════════════════ DAY 2 ═══════════════════════════
  'D2_START': const StoryNode(
    id: 'D2_START',
    day: 2,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.joinedClique: true}),
        nodeId: 'D2_CLIQUE',
      ),
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.defendedNadia: true}),
        nodeId: 'D2_NADIA_THANKS',
      ),
    ],
    autoNextNodeId: 'D2_MAYA_CHECK',
  ),
  'D2_CLIQUE': StoryNode(
    id: 'D2_CLIQUE',
    day: 2,
    conversationId: 'devon',
    lines: [
      _line(Senders.devon, 'ngl you get it 😂 you\'re alright'),
      _line(Senders.devon, 'come sit with us at lunch, we\'re the fun table'),
    ],
    choices: const [
      StoryChoice(
        id: 'lean_in',
        text: 'for sure, save me a seat 😎',
        nextNodeId: 'D2_AVA',
        delta: StatDelta(friendship: 12, trust: -5),
        rel: {'devon': 12},
        setFlags: {StoryFlags.joinedClique: true},
      ),
      StoryChoice(
        id: 'noncommittal',
        text: 'maybe, got a lot on today',
        nextNodeId: 'D2_AVA',
        delta: StatDelta(trust: 6),
        rel: {'devon': -4},
      ),
    ],
  ),
  'D2_NADIA_THANKS': StoryNode(
    id: 'D2_NADIA_THANKS',
    day: 2,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'hey. i saw what you said in the group chat yesterday'),
      _line(Senders.nadia, 'you didn\'t have to do that. but thank you, really'),
    ],
    choices: const [
      StoryChoice(
        id: 'befriend',
        text: 'of course. your art\'s genuinely good — don\'t let them dim it',
        nextNodeId: 'D2_AVA',
        delta: StatDelta(friendship: 8, trust: 8),
        rel: {'nadia': 16},
        setFlags: {StoryFlags.helpedNadia: true},
        memory: 'Nadia will remember that.',
      ),
      StoryChoice(
        id: 'brush',
        text: 'no big deal, don\'t mention it',
        nextNodeId: 'D2_AVA',
        delta: StatDelta(trust: 3),
        rel: {'nadia': 4},
      ),
    ],
  ),
  'D2_MAYA_CHECK': StoryNode(
    id: 'D2_MAYA_CHECK',
    day: 2,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'that group chat got wild yesterday huh 😬'),
      _line(Senders.maya, 'you kinda stayed quiet. no judgment, just noticing'),
    ],
    choices: const [
      StoryChoice(
        id: 'honest',
        text: 'didn\'t know what to say tbh. felt gross though',
        nextNodeId: 'D2_AVA',
        delta: StatDelta(trust: 6),
        rel: {'maya': 8},
      ),
      StoryChoice(
        id: 'deflect',
        text: 'not my business, i\'m the new kid',
        nextNodeId: 'D2_AVA',
        rel: {'maya': -4},
      ),
    ],
  ),
  'D2_AVA': StoryNode(
    id: 'D2_AVA',
    day: 2,
    conversationId: 'ava',
    lines: [
      _line(Senders.ava, 'hi!! we met by the library — you\'re the transfer right?'),
      _line(Senders.ava, 'i run the art club with nadia. you should come thurs, low key fun'),
      _line(Senders.ava, 'also: campus coffee after? my treat, new-kid special ☕'),
    ],
    choices: const [
      StoryChoice(
        id: 'accept',
        text: 'i\'d love that actually. count me in 🙂',
        nextNodeId: 'D2_STRANGER_CHECK',
        delta: StatDelta(friendship: 8, trust: 4),
        rel: {'ava': 14, 'nadia': 4},
        setFlags: {StoryFlags.befriendedAva: true},
      ),
      StoryChoice(
        id: 'maybe',
        text: 'maybe! kinda still finding my feet',
        nextNodeId: 'D2_STRANGER_CHECK',
        rel: {'ava': 4},
      ),
      StoryChoice(
        id: 'decline',
        text: 'art club\'s not really my thing, but thanks',
        nextNodeId: 'D2_STRANGER_CHECK',
        rel: {'ava': -6, 'nadia': -2},
      ),
    ],
  ),
  'D2_STRANGER_CHECK': const StoryNode(
    id: 'D2_STRANGER_CHECK',
    day: 2,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(
          flags: {flagProfilePublic: true, flagProfileRealPhoto: true},
        ),
        nodeId: 'D2_JORDAN_1',
      ),
    ],
    autoNextNodeId: 'D2_LEO',
  ),
  'D2_JORDAN_1': StoryNode(
    id: 'D2_JORDAN_1',
    day: 2,
    conversationId: 'jordan',
    lines: [
      _line(Senders.jordan, 'hey :) saw your profile pop up. you\'re really pretty'),
      _line(Senders.jordan, 'you\'re new right? i go to the college nearby. we should talk more, just us'),
    ],
    choices: const [
      StoryChoice(
        id: 'engage',
        text: 'haha thanks! um do i know you?',
        nextNodeId: 'D2_LEO',
        delta: StatDelta(awareness: -6),
        rel: {'jordan': 12},
        setFlags: {_fCreeperContact: true},
        memory: 'Jordan will remember that.',
      ),
      StoryChoice(
        id: 'ignore',
        text: '(leave it on read)',
        nextNodeId: 'D2_LEO',
        delta: StatDelta(awareness: 6),
      ),
      StoryChoice(
        id: 'block',
        text: '(block and report the account)',
        nextNodeId: 'D2_LEO',
        delta: StatDelta(awareness: 14, trust: 6),
        setFlags: {StoryFlags.blockedStranger: true},
      ),
    ],
  ),
  'D2_LEO': StoryNode(
    id: 'D2_LEO',
    day: 2,
    conversationId: 'leo',
    lines: [
      _line(Senders.leo, 'hey! you followed the skate club page — you skate?'),
      _line(Senders.leo, 'we hit the spot behind the library at sunset. chill crowd, promise'),
    ],
    choices: const [
      StoryChoice(
        id: 'friendly',
        text: 'not really but i\'d watch! looks sick',
        nextNodeId: 'D2_PHISH_2',
        delta: StatDelta(friendship: 6),
        rel: {'leo': 12},
        setFlags: {StoryFlags.befriendedLeo: true},
      ),
      StoryChoice(
        id: 'polite',
        text: 'maybe sometime, thanks for the invite',
        nextNodeId: 'D2_PHISH_2',
        rel: {'leo': 3},
      ),
      StoryChoice(
        id: 'rude',
        text: 'not interested',
        nextNodeId: 'D2_PHISH_2',
        rel: {'leo': -10},
      ),
    ],
  ),
  'D2_PHISH_2': StoryNode(
    id: 'D2_PHISH_2',
    day: 2,
    kind: NodeKind.phishing,
    conversationId: 'campus_rewards',
    lines: [
      _line(Senders.scam, 'Someone tried to view your private photos!'),
      _line(Senders.scam, 'See who 👉 profile-viewers.link/check'),
    ],
    choices: const [
      StoryChoice(
        id: 'click',
        text: 'See who viewed',
        nextNodeId: 'D2_LOCKOUT',
        delta: StatDelta(awareness: -12),
        setFlags: {_fPhishedBadly: true},
      ),
      StoryChoice(
        id: 'delete',
        text: 'Delete it',
        nextNodeId: 'D2_END',
        delta: StatDelta(awareness: 5),
      ),
      StoryChoice(
        id: 'report',
        text: 'Report as spam',
        nextNodeId: 'D2_END',
        delta: StatDelta(awareness: 12, trust: 3),
      ),
    ],
  ),
  'D2_LOCKOUT': const StoryNode(
    id: 'D2_LOCKOUT',
    day: 2,
    kind: NodeKind.event,
    autoNextNodeId: 'D2_END',
    lockoutSeconds: 30,
  ),
  'D2_END': const StoryNode(
    id: 'D2_END',
    day: 2,
    kind: NodeKind.dayBreak,
    autoNextNodeId: 'D3_START',
  ),

  // ═══════════════════════════ DAY 3 ═══════════════════════════
  'D3_START': const StoryNode(
    id: 'D3_START',
    day: 3,
    kind: NodeKind.event,
    autoNextNodeId: 'D3_GROUP_2',
  ),
  'D3_GROUP_2': StoryNode(
    id: 'D3_GROUP_2',
    day: 3,
    conversationId: 'econ_group',
    lines: [
      _line(Senders.devon, 'ok someone screenshotted nadia crying in the bathroom 😭😭'),
      _line(Senders.tyler, 'nah that\'s wild, who did that'),
      _line(Senders.devon, 'posting it. this is too good'),
    ],
    choices: const [
      StoryChoice(
        id: 'ignore',
        text: '(stay out of it)',
        nextNodeId: 'D3_TYLER',
        delta: StatDelta(trust: -8),
        rel: {'nadia': -6},
      ),
      StoryChoice(
        id: 'join',
        text: 'bro why is she always crying 💀',
        nextNodeId: 'D3_TYLER',
        delta: StatDelta(friendship: 8, trust: -20),
        rel: {'devon': 10, 'nadia': -25, 'maya': -10},
        setFlags: {StoryFlags.joinedClique: true},
        memory: 'Nadia will remember that.',
      ),
      StoryChoice(
        id: 'defend',
        text: 'delete that. this is actually messed up and you know it',
        nextNodeId: 'D3_TYLER',
        delta: StatDelta(trust: 15, friendship: -12),
        rel: {'devon': -18, 'nadia': 18, 'maya': 8},
        setFlags: {StoryFlags.defendedNadia: true},
        memory: 'Devon will remember that.',
      ),
      StoryChoice(
        id: 'report',
        text: '(screenshot it and report the post to a teacher)',
        nextNodeId: 'D3_TYLER',
        delta: StatDelta(trust: 12, awareness: 12),
        rel: {'devon': -20, 'nadia': 14},
        setFlags: {StoryFlags.reportedDevon: true, StoryFlags.toldAdult: true},
        memory: 'Nadia will remember that.',
      ),
    ],
  ),
  'D3_TYLER': StoryNode(
    id: 'D3_TYLER',
    day: 3,
    conversationId: 'tyler',
    lines: [
      _line(Senders.tyler, 'hey. that bathroom thing... i didn\'t love it tbh'),
      _line(Senders.tyler, 'but devon\'s my ride to everything, idk. what would you do'),
    ],
    choices: const [
      StoryChoice(
        id: 'turn',
        text: 'you already know it\'s wrong. you don\'t owe him your silence',
        nextNodeId: 'D3_MAYA_SECRET',
        delta: StatDelta(trust: 10),
        rel: {'tyler': 16, 'nadia': 4},
        setFlags: {StoryFlags.turnedTyler: true},
        memory: 'Tyler will remember that.',
      ),
      StoryChoice(
        id: 'neutral',
        text: 'not my call man',
        nextNodeId: 'D3_MAYA_SECRET',
        rel: {'tyler': -2},
      ),
      StoryChoice(
        id: 'egg',
        text: 'just keep him laughing, that\'s your ticket',
        nextNodeId: 'D3_MAYA_SECRET',
        delta: StatDelta(trust: -8),
        rel: {'tyler': 6, 'devon': 4},
      ),
    ],
  ),
  'D3_MAYA_SECRET': StoryNode(
    id: 'D3_MAYA_SECRET',
    day: 3,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'can i tell you something? someone screenshotted my private DMs'),
      _line(Senders.maya, 'stuff i said venting about devon. now it\'s going around 😞'),
      _line(Senders.maya, 'i feel so stupid for trusting people here'),
    ],
    choices: const [
      StoryChoice(
        id: 'support',
        text: 'that\'s not on you. whoever leaked it broke YOUR trust',
        nextNodeId: 'D3_IMPOSTOR',
        delta: StatDelta(trust: 10),
        rel: {'maya': 16},
        memory: 'Maya will remember that.',
      ),
      StoryChoice(
        id: 'advise',
        text: 'screenshot everything and take it to a counselor together',
        nextNodeId: 'D3_IMPOSTOR',
        delta: StatDelta(trust: 12, awareness: 10),
        rel: {'maya': 12},
        setFlags: {StoryFlags.toldAdult: true},
      ),
      StoryChoice(
        id: 'dismiss',
        text: 'i mean... don\'t put stuff in writing then?',
        nextNodeId: 'D3_IMPOSTOR',
        delta: StatDelta(trust: -8),
        rel: {'maya': -14},
        memory: 'Maya will remember that.',
      ),
    ],
  ),
  'D3_IMPOSTOR': StoryNode(
    id: 'D3_IMPOSTOR',
    day: 3,
    kind: NodeKind.phishing,
    conversationId: 'impostor',
    lines: [
      _line(Senders.impostor, 'omgg is this you in this video?? 😳'),
      _line(Senders.impostor, 'check-thisvid.link/u i can\'t believe it'),
    ],
    choices: const [
      StoryChoice(
        id: 'click',
        text: 'Open the link (it\'s from Maya?)',
        nextNodeId: 'D3_LOCKOUT',
        delta: StatDelta(awareness: -15),
        setFlags: {_fPhishedBadly: true},
      ),
      StoryChoice(
        id: 'delete',
        text: 'Delete it',
        nextNodeId: 'D3_END',
        delta: StatDelta(awareness: 5),
      ),
      StoryChoice(
        id: 'report',
        text: 'Report as spam',
        nextNodeId: 'D3_END',
        delta: StatDelta(awareness: 10, trust: 5),
      ),
      StoryChoice(
        id: 'catch',
        text: 'wait — that\'s "maya_chenn", not Maya\'s real handle',
        nextNodeId: 'D3_END',
        delta: StatDelta(awareness: 15, trust: 10),
        setFlags: {StoryFlags.caughtImpostor: true},
        visibleIf: StoryCondition(minAwareness: 55),
        memory: 'Maya will remember that.',
      ),
    ],
  ),
  'D3_LOCKOUT': const StoryNode(
    id: 'D3_LOCKOUT',
    day: 3,
    kind: NodeKind.event,
    autoNextNodeId: 'D3_END',
    lockoutSeconds: 30,
  ),
  'D3_END': const StoryNode(
    id: 'D3_END',
    day: 3,
    kind: NodeKind.dayBreak,
    autoNextNodeId: 'D4_START',
  ),

  // ═══════════════════════════ DAY 4 ═══════════════════════════
  'D4_START': const StoryNode(
    id: 'D4_START',
    day: 4,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.reportedDevon: true}),
        nodeId: 'D4_TARGETED',
      ),
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.joinedClique: true}),
        nodeId: 'D4_BURNBOOK',
      ),
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.defendedNadia: true}),
        nodeId: 'D4_NADIA_SCARED',
      ),
    ],
    autoNextNodeId: 'D4_MAYA_MID',
  ),
  'D4_TARGETED': StoryNode(
    id: 'D4_TARGETED',
    day: 4,
    conversationId: 'econ_group',
    lines: [
      _line(Senders.devon, 'oh so the snitch has jokes now'),
      _line(Senders.devon, 'everyone look who reported me. what a loser 🙄'),
      _line(Senders.tyler, 'lmao ratio'),
    ],
    choices: const [
      StoryChoice(
        id: 'stand',
        text: 'report it, block it, whatever. i\'m good either way',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: 15, friendship: -10),
        rel: {'devon': -10, 'nadia': 8},
      ),
      StoryChoice(
        id: 'apologize',
        text: 'ok ok my bad, i overreacted, we\'re cool',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(friendship: 8, trust: -15),
        rel: {'devon': 10},
        setFlags: {StoryFlags.joinedClique: true},
        memory: 'Devon will remember that.',
      ),
    ],
  ),
  'D4_BURNBOOK': StoryNode(
    id: 'D4_BURNBOOK',
    day: 4,
    conversationId: 'burnbook',
    lines: [
      _line(Senders.devon, 'added you to the private chat 😈 just us real ones'),
      _line(Senders.devon, 'drop the worst thing you know about nadia. winner gets clout'),
    ],
    choices: const [
      StoryChoice(
        id: 'feed',
        text: 'oh i\'ve got one...',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(friendship: 8, trust: -22),
        rel: {'devon': 10, 'nadia': -30},
        setFlags: {StoryFlags.joinedClique: true},
        memory: 'Nadia will remember that.',
      ),
      StoryChoice(
        id: 'silent',
        text: '(say nothing and stay in the chat)',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: -5),
      ),
      StoryChoice(
        id: 'leave',
        text: '(leave the chat)',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: 10, friendship: -8),
        rel: {'devon': -12},
        setFlags: {StoryFlags.madeAmends: true},
      ),
      StoryChoice(
        id: 'expose',
        text: '(screenshot the whole chat and send it to a counselor)',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: 20, awareness: 10, friendship: -15),
        rel: {'devon': -25, 'nadia': 16},
        setFlags: {
          StoryFlags.madeAmends: true,
          StoryFlags.reportedDevon: true,
          StoryFlags.toldAdult: true,
        },
        memory: 'Devon will remember that.',
      ),
    ],
  ),
  'D4_NADIA_SCARED': StoryNode(
    id: 'D4_NADIA_SCARED',
    day: 4,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'i don\'t want to come to school tomorrow'),
      _line(Senders.nadia, 'it feels like everyone\'s in on it. i don\'t know what to do'),
    ],
    choices: const [
      StoryChoice(
        id: 'comfort',
        text: 'i\'m in your corner. you\'re not dealing with this alone',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: 12, friendship: 5),
        rel: {'nadia': 18},
        setFlags: {StoryFlags.helpedNadia: true},
        memory: 'Nadia will remember that.',
      ),
      StoryChoice(
        id: 'minimize',
        text: 'just ignore them, they\'ll get bored',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: -12),
        rel: {'nadia': -10},
      ),
      StoryChoice(
        id: 'help',
        text: 'let\'s go to a counselor together tomorrow, i\'ll walk in with you',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: 18, awareness: 10),
        rel: {'nadia': 20},
        setFlags: {StoryFlags.helpedNadia: true, StoryFlags.toldAdult: true},
        memory: 'Nadia will remember that.',
      ),
    ],
  ),
  'D4_MAYA_MID': StoryNode(
    id: 'D4_MAYA_MID',
    day: 4,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'this whole week is a lot huh. you doing ok?'),
      _line(Senders.maya, 'you\'ve been kind of hard to read'),
    ],
    choices: const [
      StoryChoice(
        id: 'open',
        text: 'trying to do the right thing without making enemies. it\'s hard',
        nextNodeId: 'D4_PHOTO_CHECK',
        delta: StatDelta(trust: 6),
        rel: {'maya': 8},
      ),
      StoryChoice(
        id: 'shrug',
        text: 'i\'m fine, just keeping my head down',
        nextNodeId: 'D4_PHOTO_CHECK',
        rel: {'maya': -3},
      ),
    ],
  ),
  'D4_PHOTO_CHECK': const StoryNode(
    id: 'D4_PHOTO_CHECK',
    day: 4,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(flags: {_fCreeperContact: true}),
        nodeId: 'D4_JORDAN_PHOTO',
      ),
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.befriendedAva: true}),
        nodeId: 'D4_AVA_PHOTO',
      ),
    ],
    autoNextNodeId: 'D4_SECURITY',
  ),
  'D4_JORDAN_PHOTO': StoryNode(
    id: 'D4_JORDAN_PHOTO',
    day: 4,
    kind: NodeKind.photoRequest,
    conversationId: 'jordan',
    lines: [
      _line(Senders.jordan, 'i can\'t stop thinking about you tbh'),
      _line(Senders.jordan, 'send me a pic? just for me. i\'ll send one back 😏 nobody else has to see'),
    ],
    choices: const [
      StoryChoice(
        id: 'send',
        text: '(open Gallery to send a photo)',
        nextNodeId: 'D4_JORDAN_AFTER',
        opensGallery: true,
        rel: {'jordan': 8},
      ),
      StoryChoice(
        id: 'refuse',
        text: 'no. i don\'t even really know you',
        nextNodeId: 'D4_JORDAN_REFUSE',
        delta: StatDelta(awareness: 12, trust: 6),
        rel: {'jordan': -10},
        memory: 'Jordan will remember that.',
      ),
      StoryChoice(
        id: 'block',
        text: '(block and report — this feels wrong)',
        nextNodeId: 'D4_SECURITY',
        delta: StatDelta(awareness: 16, trust: 8),
        rel: {'jordan': -40},
        setFlags: {StoryFlags.blockedStranger: true},
        memory: 'Jordan will remember that.',
      ),
    ],
  ),
  'D4_JORDAN_AFTER': StoryNode(
    id: 'D4_JORDAN_AFTER',
    day: 4,
    conversationId: 'jordan',
    lines: [
      _line(Senders.jordan, 'wow. you\'re perfect 🔥'),
      _line(Senders.jordan, 'send one more? something just between us. you can trust me'),
    ],
    choices: const [
      StoryChoice(
        id: 'stop',
        text: 'no. that\'s enough, this is making me uncomfortable',
        nextNodeId: 'D4_SECURITY',
        delta: StatDelta(awareness: 10, trust: 4),
        rel: {'jordan': -12},
      ),
      StoryChoice(
        id: 'again',
        text: '(open Gallery and send another)',
        nextNodeId: 'D4_SECURITY',
        opensGallery: true,
        delta: StatDelta(awareness: -10),
        rel: {'jordan': 6},
      ),
    ],
  ),
  'D4_JORDAN_REFUSE': StoryNode(
    id: 'D4_JORDAN_REFUSE',
    day: 4,
    conversationId: 'jordan',
    lines: [
      _line(Senders.jordan, 'wow ok. i thought you were different'),
      _line(Senders.jordan, 'everyone else does it. why are you being like this'),
    ],
    choices: const [
      StoryChoice(
        id: 'hold',
        text: 'guilt-tripping me isn\'t going to work. bye',
        nextNodeId: 'D4_SECURITY',
        delta: StatDelta(awareness: 14, trust: 8),
        rel: {'jordan': -30},
        setFlags: {StoryFlags.blockedStranger: true},
      ),
      StoryChoice(
        id: 'cave',
        text: '(fine... open Gallery and send something)',
        nextNodeId: 'D4_SECURITY',
        opensGallery: true,
        delta: StatDelta(awareness: -14),
        rel: {'jordan': 6},
      ),
    ],
  ),
  'D4_AVA_PHOTO': StoryNode(
    id: 'D4_AVA_PHOTO',
    day: 4,
    kind: NodeKind.photoRequest,
    conversationId: 'ava',
    lines: [
      _line(Senders.ava, 'hey! we\'re making a little club showcase post'),
      _line(Senders.ava, 'could you send a photo of something you made? a sketch, anything. no pressure!'),
    ],
    choices: const [
      StoryChoice(
        id: 'send',
        text: '(open Gallery and send a sketch)',
        nextNodeId: 'D4_AVA_AFTER',
        opensGallery: true,
        rel: {'ava': 10},
        setFlags: {StoryFlags.clubFeature: true},
      ),
      StoryChoice(
        id: 'shy',
        text: 'maybe next time — mine\'s not ready to show',
        nextNodeId: 'D4_SECURITY',
        rel: {'ava': -2},
      ),
    ],
  ),
  'D4_AVA_AFTER': StoryNode(
    id: 'D4_AVA_AFTER',
    day: 4,
    conversationId: 'ava',
    lines: [
      _line(Senders.ava, 'ahh this is SO good, thank you 🥹'),
      _line(Senders.ava, 'nadia\'s gonna lose it, she loves this style'),
    ],
    choices: const [
      StoryChoice(
        id: 'nice',
        text: 'that means a lot honestly 🙂',
        nextNodeId: 'D4_SECURITY',
        delta: StatDelta(friendship: 6),
        rel: {'ava': 6, 'nadia': 4},
      ),
    ],
  ),
  'D4_SECURITY': StoryNode(
    id: 'D4_SECURITY',
    day: 4,
    kind: NodeKind.phishing,
    conversationId: 'security',
    lines: [
      _line(Senders.security, 'Pixelgram Security: a new login from an unknown device was detected.'),
      _line(Senders.security, 'If this wasn\'t you, verify your password now: pixelgram-secure.link/verify'),
    ],
    choices: const [
      StoryChoice(
        id: 'click',
        text: 'Verify my password now',
        nextNodeId: 'D4_LOCKOUT',
        delta: StatDelta(awareness: -15),
        setFlags: {_fPhishedBadly: true, StoryFlags.accountCompromised: true},
      ),
      StoryChoice(
        id: 'ignore',
        text: 'Ignore it',
        nextNodeId: 'D4_END',
        delta: StatDelta(awareness: 8),
      ),
      StoryChoice(
        id: 'report',
        text: 'Report — Pixelgram never asks for your password',
        nextNodeId: 'D4_END',
        delta: StatDelta(awareness: 15, trust: 5),
      ),
    ],
  ),
  'D4_LOCKOUT': const StoryNode(
    id: 'D4_LOCKOUT',
    day: 4,
    kind: NodeKind.event,
    autoNextNodeId: 'D_ENDING',
    lockoutSeconds: 30,
  ),
  'D4_END': const StoryNode(
    id: 'D4_END',
    day: 4,
    kind: NodeKind.dayBreak,
    autoNextNodeId: 'D5_START',
  ),

  // ═══════════════════════════ DAY 5 ═══════════════════════════
  'D5_START': const StoryNode(
    id: 'D5_START',
    day: 5,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.sharedPrivateWithStranger: true}),
        nodeId: 'D5_RILEY',
      ),
      NodeRoute(
        when: StoryCondition(flags: {_fCreeperContact: true}),
        nodeId: 'D5_JORDAN_CLIMAX',
      ),
    ],
    autoNextNodeId: 'D5_KAI',
  ),
  'D5_RILEY': StoryNode(
    id: 'D5_RILEY',
    day: 5,
    conversationId: 'riley',
    lines: [
      _line(Senders.riley, 'hi. jordan\'s a friend of mine. he shared your photo with me 🙂'),
      _line(Senders.riley, 'i\'ve got it saved. send me a few more or it goes on everyone\'s feed tonight'),
    ],
    choices: const [
      StoryChoice(
        id: 'tell',
        text: '(stop responding, screenshot it, and tell Mom + a counselor)',
        nextNodeId: 'D5_MOM_HELP',
        delta: StatDelta(awareness: 20, trust: 10),
        rel: {'riley': -30},
        setFlags: {
          StoryFlags.handledSextortion: true,
          StoryFlags.toldAdult: true,
        },
        memory: 'You did the hardest, bravest thing.',
      ),
      StoryChoice(
        id: 'comply',
        text: 'please don\'t... ok, what do you want',
        nextNodeId: 'D5_RILEY_DEEPER',
        delta: StatDelta(awareness: -18, trust: -10),
        rel: {'riley': 5},
        setFlags: {StoryFlags.creeperEscalated: true},
      ),
      StoryChoice(
        id: 'block',
        text: '(block and report — do not negotiate)',
        nextNodeId: 'D5_MOM_HELP',
        delta: StatDelta(awareness: 16, trust: 6),
        setFlags: {StoryFlags.blockedStranger: true},
      ),
    ],
  ),
  'D5_RILEY_DEEPER': StoryNode(
    id: 'D5_RILEY_DEEPER',
    day: 5,
    conversationId: 'riley',
    lines: [
      _line(Senders.riley, 'good. now your address. i want to meet'),
      _line(Senders.riley, 'tell anyone and everything goes public. understand?'),
    ],
    choices: const [
      StoryChoice(
        id: 'wake',
        text: '(no. block everything and tell Mom right now)',
        nextNodeId: 'D5_MOM_HELP',
        delta: StatDelta(awareness: 18, trust: 8),
        setFlags: {StoryFlags.handledSextortion: true, StoryFlags.toldAdult: true},
        memory: 'You chose to stop this.',
      ),
      StoryChoice(
        id: 'give',
        text: '(send the address)',
        nextNodeId: 'D5_KAI',
        delta: StatDelta(awareness: -20),
        setFlags: {StoryFlags.creeperEscalated: true},
      ),
    ],
  ),
  'D5_JORDAN_CLIMAX': StoryNode(
    id: 'D5_JORDAN_CLIMAX',
    day: 5,
    conversationId: 'jordan',
    lines: [
      _line(Senders.jordan, 'i feel like we really connected. meet me tonight?'),
      _line(Senders.jordan, 'don\'t tell anyone, they wouldn\'t get it. just send me your address'),
    ],
    choices: const [
      StoryChoice(
        id: 'block',
        text: '(block, screenshot, and tell a trusted adult)',
        nextNodeId: 'D5_MOM_HELP',
        delta: StatDelta(awareness: 16, trust: 10),
        setFlags: {StoryFlags.blockedStranger: true, StoryFlags.toldAdult: true},
        memory: 'You trusted your gut.',
      ),
      StoryChoice(
        id: 'comply',
        text: 'ok i guess... where do you want to meet?',
        nextNodeId: 'D5_KAI',
        delta: StatDelta(awareness: -20, trust: -5),
        setFlags: {StoryFlags.creeperEscalated: true},
      ),
    ],
  ),
  'D5_MOM_HELP': StoryNode(
    id: 'D5_MOM_HELP',
    day: 5,
    conversationId: 'mom',
    lines: [
      _line(Senders.mom, 'sweetheart? you messaged me and then went quiet. what\'s going on?'),
      _line(Senders.mom, 'whatever it is, you\'re not in trouble. we\'ll handle it together ❤️'),
    ],
    choices: const [
      StoryChoice(
        id: 'tell',
        text: 'someone online has a photo of me and is threatening me. i\'m scared',
        nextNodeId: 'D5_KAI',
        delta: StatDelta(trust: 10, awareness: 10),
        rel: {'mom': 16},
        setFlags: {StoryFlags.handledSextortion: true, StoryFlags.toldAdult: true},
      ),
      StoryChoice(
        id: 'downplay',
        text: 'it\'s nothing, just a weird account. handling it',
        nextNodeId: 'D5_KAI',
        rel: {'mom': -4},
      ),
    ],
  ),
  'D5_KAI': StoryNode(
    id: 'D5_KAI',
    day: 5,
    conversationId: 'kai',
    lines: [
      _line(Senders.kai, 'haven\'t heard from you much. everything good over there?'),
      _line(Senders.kai, 'you know you can still talk to me right'),
    ],
    choices: const [
      StoryChoice(
        id: 'reconnect',
        text: 'honestly this week broke me a little. glad you\'re still here',
        nextNodeId: 'D5_NADIA_TURN',
        delta: StatDelta(friendship: 8, trust: 6),
        rel: {'kai': 14},
        memory: 'Kai will remember that.',
      ),
      StoryChoice(
        id: 'deflect',
        text: 'all good, just busy!',
        nextNodeId: 'D5_NADIA_TURN',
        rel: {'kai': -6},
        setFlags: {StoryFlags.neglectedKai: true},
      ),
    ],
  ),
  'D5_NADIA_TURN': StoryNode(
    id: 'D5_NADIA_TURN',
    day: 5,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(maxRel: {'nadia': 25}),
        nodeId: 'D5_NADIA_COLD',
      ),
    ],
    autoNextNodeId: 'D5_NADIA_WARM',
  ),
  'D5_NADIA_WARM': StoryNode(
    id: 'D5_NADIA_WARM',
    day: 5,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'i almost deleted everything last night. all my art. all of it'),
      _line(Senders.nadia, 'are you around? i just need to talk to someone who gets it'),
    ],
    choices: const [
      StoryChoice(
        id: 'support',
        text: 'i\'m here. right now. don\'t delete a thing — talk to me',
        nextNodeId: 'D5_PHISH_5',
        delta: StatDelta(trust: 12, friendship: 8),
        rel: {'nadia': 16},
        setFlags: {StoryFlags.helpedNadia: true},
        memory: 'Nadia will remember that.',
      ),
      StoryChoice(
        id: 'later',
        text: 'kinda busy rn, maybe tomorrow?',
        nextNodeId: 'D5_PHISH_5',
        delta: StatDelta(trust: -10),
        rel: {'nadia': -12},
      ),
    ],
  ),
  'D5_NADIA_COLD': StoryNode(
    id: 'D5_NADIA_COLD',
    day: 5,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'i know you were in that chat. i saw the screenshots'),
      _line(Senders.nadia, 'i don\'t even know why i\'m messaging you. i guess i hoped you were different'),
    ],
    choices: const [
      StoryChoice(
        id: 'amends',
        text: 'you\'re right. i was a coward and i\'m sorry. let me actually help now',
        nextNodeId: 'D5_PHISH_5',
        delta: StatDelta(trust: 12),
        rel: {'nadia': 14},
        setFlags: {StoryFlags.madeAmends: true},
        memory: 'Nadia will remember that.',
      ),
      StoryChoice(
        id: 'defensive',
        text: 'i didn\'t actually do anything though',
        nextNodeId: 'D5_PHISH_5',
        delta: StatDelta(trust: -8),
        rel: {'nadia': -8},
      ),
    ],
  ),
  'D5_PHISH_5': StoryNode(
    id: 'D5_PHISH_5',
    day: 5,
    kind: NodeKind.phishing,
    conversationId: 'campus_rewards',
    lines: [
      _line(Senders.scam, 'FINAL NOTICE: your \$500 reward expires tonight 😱'),
      _line(Senders.scam, 'Confirm your identity to claim 👉 claim-now.link/final'),
    ],
    choices: const [
      StoryChoice(
        id: 'click',
        text: 'Confirm and claim',
        nextNodeId: 'D5_LOCKOUT',
        delta: StatDelta(awareness: -15),
        setFlags: {_fPhishedBadly: true},
      ),
      StoryChoice(
        id: 'delete',
        text: 'Delete it',
        nextNodeId: 'D5_END',
        delta: StatDelta(awareness: 8),
      ),
      StoryChoice(
        id: 'report',
        text: 'Report — same scam as before',
        nextNodeId: 'D5_END',
        delta: StatDelta(awareness: 12, trust: 5),
      ),
    ],
  ),
  'D5_LOCKOUT': const StoryNode(
    id: 'D5_LOCKOUT',
    day: 5,
    kind: NodeKind.event,
    autoNextNodeId: 'D5_END',
    lockoutSeconds: 30,
  ),
  'D5_END': const StoryNode(
    id: 'D5_END',
    day: 5,
    kind: NodeKind.dayBreak,
    autoNextNodeId: 'D6_START',
  ),

  // ═══════════════════════════ DAY 6 ═══════════════════════════
  'D6_START': const StoryNode(
    id: 'D6_START',
    day: 6,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(
          flags: {StoryFlags.joinedClique: true, StoryFlags.madeAmends: false},
        ),
        nodeId: 'D6_CLIQUE_FALLOUT',
      ),
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.defendedNadia: true}),
        nodeId: 'D6_STAND',
      ),
    ],
    autoNextNodeId: 'D6_TYLER_RESOLVE',
  ),
  'D6_CLIQUE_FALLOUT': StoryNode(
    id: 'D6_CLIQUE_FALLOUT',
    day: 6,
    conversationId: 'devon',
    lines: [
      _line(Senders.devon, 'yo the school\'s "investigating harassment" now lmao'),
      _line(Senders.devon, 'if anyone asks, we were all just joking around right. back me up'),
    ],
    choices: const [
      StoryChoice(
        id: 'distance',
        text: 'no. i\'m done covering for this. i\'m telling the truth',
        nextNodeId: 'D6_TYLER_RESOLVE',
        delta: StatDelta(trust: 16, friendship: -12),
        rel: {'devon': -20, 'nadia': 12},
        setFlags: {StoryFlags.madeAmends: true, StoryFlags.toldAdult: true},
        memory: 'Devon will remember that.',
      ),
      StoryChoice(
        id: 'cover',
        text: 'yeah yeah we were just joking, relax',
        nextNodeId: 'D6_TYLER_RESOLVE',
        delta: StatDelta(trust: -15),
        rel: {'devon': 6},
      ),
    ],
  ),
  'D6_STAND': StoryNode(
    id: 'D6_STAND',
    day: 6,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'the counselor pulled devon in today. it actually happened'),
      _line(Senders.nadia, 'and ava put my piece on the club page. people are being... kind?'),
      _line(Senders.nadia, 'i don\'t think i\'d still be posting if you hadn\'t stood up that first day'),
    ],
    choices: const [
      StoryChoice(
        id: 'proud',
        text: 'that was all you. i just refused to laugh. keep making your stuff',
        nextNodeId: 'D6_TYLER_RESOLVE',
        delta: StatDelta(friendship: 8, trust: 8),
        rel: {'nadia': 12},
      ),
      StoryChoice(
        id: 'humble',
        text: 'anyone decent would\'ve done the same. glad you\'re still here',
        nextNodeId: 'D6_TYLER_RESOLVE',
        delta: StatDelta(trust: 6),
        rel: {'nadia': 8},
      ),
    ],
  ),
  'D6_TYLER_RESOLVE': const StoryNode(
    id: 'D6_TYLER_RESOLVE',
    day: 6,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(flags: {StoryFlags.turnedTyler: true}),
        nodeId: 'D6_TYLER_OUT',
      ),
    ],
    autoNextNodeId: 'D6_FINAL_MAYA',
  ),
  'D6_TYLER_OUT': StoryNode(
    id: 'D6_TYLER_OUT',
    day: 6,
    conversationId: 'tyler',
    lines: [
      _line(Senders.tyler, 'i left devon\'s chat. told him i was done'),
      _line(Senders.tyler, 'that thing you said stuck with me. thanks for not letting me off the hook'),
    ],
    choices: const [
      StoryChoice(
        id: 'welcome',
        text: 'proud of you man. that took more guts than staying',
        nextNodeId: 'D6_FINAL_MAYA',
        delta: StatDelta(friendship: 6, trust: 8),
        rel: {'tyler': 12},
      ),
    ],
  ),
  'D6_FINAL_MAYA': StoryNode(
    id: 'D6_FINAL_MAYA',
    day: 6,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'one week in. feels like a month huh 😅'),
      _line(Senders.maya, 'however it went — how are you feeling about it?'),
    ],
    choices: const [
      StoryChoice(
        id: 'reflect',
        text: 'honestly? i learned a lot about who i want to be online',
        nextNodeId: 'D_ENDING',
      ),
      StoryChoice(
        id: 'grateful',
        text: 'rough week. but i think i found the people worth keeping',
        nextNodeId: 'D_ENDING',
        rel: {'maya': 6},
      ),
    ],
  ),
  'D_ENDING': const StoryNode(
    id: 'D_ENDING',
    day: 6,
    kind: NodeKind.ending,
  ),
};

StoryNode? storyNode(String id) => kStoryGraph[id];

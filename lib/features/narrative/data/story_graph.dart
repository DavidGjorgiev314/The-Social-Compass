import '../../game/application/game_controller.dart';
import '../domain/ending.dart';
import '../domain/story_models.dart';

class Senders {
  Senders._();
  static const maya = ('maya', 'Maya');
  static const devon = ('devon', 'Devon');
  static const nadia = ('nadia', 'Nadia');
  static const tyler = ('tyler', 'Tyler');
  static const jordan = ('jordan', 'Jordan');
  static const scam = ('campus_rewards', 'Campus Rewards');
  static const security = ('pixelgram_security', 'Pixelgram Security');
  static const impostor = ('maya_chenn', 'maya_chenn');
}

const _fPhishedBadly = 'phished_badly';
const _fCreeperContact = 'creeper_contact';
const _fHelpedNadia = 'helped_nadia';
const _fCaughtImpostor = 'caught_impostor';

StoryLine _line((String, String) sender, String text) =>
    StoryLine(senderId: sender.$1, senderName: sender.$2, text: text);

final Map<String, StoryNode> kStoryGraph = {
  // ─────────────────────────── DAY 1 ───────────────────────────
  'D1_START': StoryNode(
    id: 'D1_START',
    day: 1,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'hey!! so glad you made it into the group 🙌'),
      _line(Senders.maya, 'quick heads up, the class group chat can get... a lot lol'),
    ],
    choices: const [
      StoryChoice(
        id: 'warm',
        text: 'haha thanks for looking out. good to know 🙂',
        nextNodeId: 'D1_BULLY_1',
        delta: StatDelta(friendship: 8, trust: 4),
      ),
      StoryChoice(
        id: 'guarded',
        text: 'a lot how? should i be worried?',
        nextNodeId: 'D1_BULLY_1',
        delta: StatDelta(awareness: 5),
      ),
    ],
  ),
  'D1_BULLY_1': StoryNode(
    id: 'D1_BULLY_1',
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
        nextNodeId: 'D1_PHISH_1',
        delta: StatDelta(trust: -5),
      ),
      StoryChoice(
        id: 'join',
        text: 'lmaooo fr who does she think she is',
        nextNodeId: 'D1_PHISH_1',
        delta: StatDelta(friendship: 15, trust: -15),
        setFlags: {StoryFlags.joinedClique: true},
      ),
      StoryChoice(
        id: 'defend',
        text: 'not cool man, it actually took guts to post that',
        nextNodeId: 'D1_PHISH_1',
        delta: StatDelta(trust: 15, friendship: -10),
        setFlags: {StoryFlags.defendedNadia: true},
      ),
      StoryChoice(
        id: 'report',
        text: '(report Devon\'s messages to the group admins)',
        nextNodeId: 'D1_PHISH_1',
        delta: StatDelta(trust: 10, awareness: 10),
        setFlags: {StoryFlags.reportedDevon: true},
      ),
    ],
  ),
  'D1_PHISH_1': StoryNode(
    id: 'D1_PHISH_1',
    day: 1,
    kind: NodeKind.phishing,
    conversationId: 'campus_rewards',
    lines: [
      _line(Senders.scam,
          '🎉 CONGRATS! You\'ve been selected for a \$500 campus gift card!'),
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

  // ─────────────────────────── DAY 2 ───────────────────────────
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
        nodeId: 'D2_ALLY',
      ),
    ],
    autoNextNodeId: 'D2_NEUTRAL',
  ),
  'D2_CLIQUE': StoryNode(
    id: 'D2_CLIQUE',
    day: 2,
    conversationId: 'devon',
    lines: [
      _line(Senders.devon, 'ngl that was funny yesterday 😂 you get it'),
      _line(Senders.devon, 'come sit with us at lunch, we\'re the fun table'),
    ],
    choices: const [
      StoryChoice(
        id: 'lean_in',
        text: 'for sure, save me a seat 😎',
        nextNodeId: 'D2_CREEPER_CHECK',
        delta: StatDelta(friendship: 12, trust: -5),
        setFlags: {StoryFlags.joinedClique: true},
      ),
      StoryChoice(
        id: 'noncommittal',
        text: 'maybe, i\'ve got a lot on today',
        nextNodeId: 'D2_CREEPER_CHECK',
        delta: StatDelta(trust: 8),
      ),
    ],
  ),
  'D2_ALLY': StoryNode(
    id: 'D2_ALLY',
    day: 2,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'hey, i saw what you said in the group chat yesterday'),
      _line(Senders.nadia, 'you didn\'t have to do that. but thank you, really'),
    ],
    choices: const [
      StoryChoice(
        id: 'befriend',
        text: 'of course. your art\'s genuinely good, don\'t let them get to you',
        nextNodeId: 'D2_CREEPER_CHECK',
        delta: StatDelta(friendship: 10, trust: 8),
      ),
      StoryChoice(
        id: 'brush',
        text: 'no big deal, don\'t mention it',
        nextNodeId: 'D2_CREEPER_CHECK',
        delta: StatDelta(friendship: -4, trust: 3),
      ),
    ],
  ),
  'D2_NEUTRAL': StoryNode(
    id: 'D2_NEUTRAL',
    day: 2,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'that group chat got wild yesterday huh 😬'),
      _line(Senders.maya, 'anyway! how are you settling in?'),
    ],
    choices: const [
      StoryChoice(
        id: 'open',
        text: 'getting there! still figuring out who\'s who',
        nextNodeId: 'D2_CREEPER_CHECK',
        delta: StatDelta(friendship: 5),
      ),
      StoryChoice(
        id: 'wary',
        text: 'honestly some people here seem kind of mean',
        nextNodeId: 'D2_CREEPER_CHECK',
        delta: StatDelta(awareness: 5, trust: 3),
      ),
    ],
  ),
  'D2_CREEPER_CHECK': const StoryNode(
    id: 'D2_CREEPER_CHECK',
    day: 2,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(
          flags: {flagProfilePublic: true, flagProfileRealPhoto: true},
        ),
        nodeId: 'D2_CREEPER_1',
      ),
    ],
    autoNextNodeId: 'D2_PHISH_CHECK',
  ),
  'D2_CREEPER_1': StoryNode(
    id: 'D2_CREEPER_1',
    day: 2,
    conversationId: 'jordan',
    lines: [
      _line(Senders.jordan, 'hey :) saw your profile, you\'re really pretty'),
      _line(Senders.jordan, 'you\'re new here right? we should hang out sometime, just us'),
    ],
    choices: const [
      StoryChoice(
        id: 'engage',
        text: 'haha thanks! um, do i know you?',
        nextNodeId: 'D2_PHISH_CHECK',
        delta: StatDelta(friendship: 2, awareness: -5),
        setFlags: {_fCreeperContact: true},
      ),
      StoryChoice(
        id: 'ignore',
        text: '(leave it on read)',
        nextNodeId: 'D2_PHISH_CHECK',
        delta: StatDelta(awareness: 6),
      ),
      StoryChoice(
        id: 'block',
        text: '(block and report the account)',
        nextNodeId: 'D2_PHISH_CHECK',
        delta: StatDelta(awareness: 12, trust: 8),
      ),
    ],
  ),
  'D2_PHISH_CHECK': const StoryNode(
    id: 'D2_PHISH_CHECK',
    day: 2,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(flags: {flagProfilePublic: true}),
        nodeId: 'D2_PHISH_2',
      ),
    ],
    autoNextNodeId: 'D2_END',
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

  // ─────────────────────────── DAY 3 ───────────────────────────
  'D3_START': const StoryNode(
    id: 'D3_START',
    day: 3,
    kind: NodeKind.event,
    autoNextNodeId: 'D3_BULLY_2',
  ),
  'D3_BULLY_2': StoryNode(
    id: 'D3_BULLY_2',
    day: 3,
    conversationId: 'econ_group',
    lines: [
      _line(Senders.devon, 'ok someone screenshotted nadia crying in the bathroom 😭😭'),
      _line(Senders.tyler, 'nah that\'s wild who did that'),
      _line(Senders.devon, 'posting it. this is too good'),
    ],
    choices: const [
      StoryChoice(
        id: 'ignore',
        text: '(stay out of it)',
        nextNodeId: 'D3_PHISH_3',
        delta: StatDelta(trust: -10),
      ),
      StoryChoice(
        id: 'join',
        text: 'bro why is she always crying 💀',
        nextNodeId: 'D3_PHISH_3',
        delta: StatDelta(friendship: 10, trust: -20),
        setFlags: {StoryFlags.joinedClique: true},
      ),
      StoryChoice(
        id: 'defend',
        text: 'delete that. this is actually messed up and you know it',
        nextNodeId: 'D3_PHISH_3',
        delta: StatDelta(trust: 15, friendship: -15),
        setFlags: {StoryFlags.defendedNadia: true},
      ),
      StoryChoice(
        id: 'report',
        text: '(report the post and screenshot it for a teacher)',
        nextNodeId: 'D3_PHISH_3',
        delta: StatDelta(trust: 10, awareness: 10),
        setFlags: {StoryFlags.reportedDevon: true},
      ),
    ],
  ),
  'D3_PHISH_3': StoryNode(
    id: 'D3_PHISH_3',
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
        setFlags: {_fCaughtImpostor: true},
        visibleIf: StoryCondition(minAwareness: 60),
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

  // ─────────────────────────── DAY 4 ───────────────────────────
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
    autoNextNodeId: 'D4_PHISH_4',
  ),
  'D4_BURNBOOK': StoryNode(
    id: 'D4_BURNBOOK',
    day: 4,
    conversationId: 'burnbook',
    lines: [
      _line(Senders.devon, 'added you to the private chat 😈 just us real ones'),
      _line(Senders.devon, 'ok drop the worst thing you know about nadia, winner gets clout'),
    ],
    choices: const [
      StoryChoice(
        id: 'feed',
        text: 'oh i\'ve got one...',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(friendship: 10, trust: -20),
        setFlags: {StoryFlags.joinedClique: true},
      ),
      StoryChoice(
        id: 'silent',
        text: '(say nothing and stay in the chat)',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(trust: -5),
      ),
      StoryChoice(
        id: 'leave',
        text: '(leave the chat)',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(trust: 10, friendship: -10),
        setFlags: {StoryFlags.madeAmends: true},
      ),
      StoryChoice(
        id: 'expose',
        text: '(screenshot the whole thing and send it to a counselor)',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(trust: 20, awareness: 10, friendship: -15),
        setFlags: {StoryFlags.madeAmends: true, StoryFlags.reportedDevon: true},
      ),
    ],
  ),
  'D4_TARGETED': StoryNode(
    id: 'D4_TARGETED',
    day: 4,
    conversationId: 'econ_group',
    lines: [
      _line(Senders.devon, 'oh so the snitch has jokes now'),
      _line(Senders.devon, 'everyone, look who reported me. what a loser 🙄'),
      _line(Senders.tyler, 'lmao ratio'),
    ],
    choices: const [
      StoryChoice(
        id: 'stand',
        text: 'report it, block it, whatever. i\'m good either way',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(trust: 15, friendship: -10),
      ),
      StoryChoice(
        id: 'apologize',
        text: 'ok ok my bad, i overreacted, we\'re cool',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(friendship: 10, trust: -15),
        setFlags: {StoryFlags.joinedClique: true},
      ),
    ],
  ),
  'D4_NADIA_SCARED': StoryNode(
    id: 'D4_NADIA_SCARED',
    day: 4,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'i don\'t really want to come to school tomorrow'),
      _line(Senders.nadia, 'it feels like everyone\'s in on it. i don\'t know what to do'),
    ],
    choices: const [
      StoryChoice(
        id: 'comfort',
        text: 'i\'m in your corner. you\'re not dealing with this alone',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(trust: 15, friendship: 5),
        setFlags: {_fHelpedNadia: true},
      ),
      StoryChoice(
        id: 'minimize',
        text: 'just ignore them, they\'ll get bored eventually',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(trust: -15),
      ),
      StoryChoice(
        id: 'help',
        text: 'let\'s talk to a counselor together tomorrow, i\'ll go with you',
        nextNodeId: 'D4_PHISH_4',
        delta: StatDelta(trust: 20, awareness: 10),
        setFlags: {_fHelpedNadia: true},
      ),
    ],
  ),
  'D4_PHISH_4': StoryNode(
    id: 'D4_PHISH_4',
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
        id: 'delete',
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

  // ─────────────────────────── DAY 5 ───────────────────────────
  'D5_START': const StoryNode(
    id: 'D5_START',
    day: 5,
    kind: NodeKind.router,
    routes: [
      NodeRoute(
        when: StoryCondition(flags: {_fCreeperContact: true}),
        nodeId: 'D5_CREEPER_CLIMAX',
      ),
    ],
    autoNextNodeId: 'D5_TURN',
  ),
  'D5_CREEPER_CLIMAX': StoryNode(
    id: 'D5_CREEPER_CLIMAX',
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
        nextNodeId: 'D5_TURN',
        delta: StatDelta(awareness: 15, trust: 10),
      ),
      StoryChoice(
        id: 'comply',
        text: 'ok, i guess... where do you want to meet?',
        nextNodeId: 'D5_TURN',
        delta: StatDelta(awareness: -20, trust: -5),
        setFlags: {StoryFlags.creeperEscalated: true},
      ),
    ],
  ),
  'D5_TURN': StoryNode(
    id: 'D5_TURN',
    day: 5,
    conversationId: 'nadia',
    lines: [
      _line(Senders.nadia, 'i almost deleted everything last night. all of it.'),
      _line(Senders.nadia, 'are you around? i just need to talk to someone'),
    ],
    choices: const [
      StoryChoice(
        id: 'support',
        text: 'i\'m here. right now. talk to me',
        nextNodeId: 'D5_PHISH_5',
        delta: StatDelta(trust: 12, friendship: 8),
        setFlags: {_fHelpedNadia: true},
      ),
      StoryChoice(
        id: 'later',
        text: 'kinda busy rn, maybe tomorrow?',
        nextNodeId: 'D5_PHISH_5',
        delta: StatDelta(trust: -10),
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

  // ─────────────────────────── DAY 6 ───────────────────────────
  'D6_START': StoryNode(
    id: 'D6_START',
    day: 6,
    conversationId: 'maya',
    lines: [
      _line(Senders.maya, 'one week in. feels like a month huh 😅'),
      _line(Senders.maya, 'however this week went... how are you feeling about it?'),
    ],
    choices: const [
      StoryChoice(
        id: 'reflect',
        text: 'honestly? i learned a lot about who i want to be online',
        nextNodeId: 'D_ENDING',
        delta: StatDelta(),
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

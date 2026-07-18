enum NameChoice {
  real,
  alias;

  static NameChoice fromName(String? value) =>
      NameChoice.values.firstWhere(
        (e) => e.name == value,
        orElse: () => NameChoice.alias,
      );
}

enum PhotoChoice {
  photo,
  avatar;

  static PhotoChoice fromName(String? value) =>
      PhotoChoice.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PhotoChoice.avatar,
      );
}

enum ProfileVisibility {
  public,
  private;

  static ProfileVisibility fromName(String? value) =>
      ProfileVisibility.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ProfileVisibility.private,
      );
}

class ProfileChoices {
  const ProfileChoices({
    this.displayName = '',
    this.nameChoice = NameChoice.alias,
    this.photoChoice = PhotoChoice.avatar,
    this.avatarId = '',
    this.visibility = ProfileVisibility.private,
    this.completed = false,
  });

  final String displayName;
  final NameChoice nameChoice;
  final PhotoChoice photoChoice;
  final String avatarId;
  final ProfileVisibility visibility;
  final bool completed;

  bool get isPublic => visibility == ProfileVisibility.public;
  bool get usesRealPhoto => photoChoice == PhotoChoice.photo;
  bool get usesRealName => nameChoice == NameChoice.real;

  ProfileChoices copyWith({
    String? displayName,
    NameChoice? nameChoice,
    PhotoChoice? photoChoice,
    String? avatarId,
    ProfileVisibility? visibility,
    bool? completed,
  }) {
    return ProfileChoices(
      displayName: displayName ?? this.displayName,
      nameChoice: nameChoice ?? this.nameChoice,
      photoChoice: photoChoice ?? this.photoChoice,
      avatarId: avatarId ?? this.avatarId,
      visibility: visibility ?? this.visibility,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'nameChoice': nameChoice.name,
        'photoChoice': photoChoice.name,
        'avatarId': avatarId,
        'visibility': visibility.name,
        'completed': completed,
      };

  factory ProfileChoices.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ProfileChoices();
    return ProfileChoices(
      displayName: map['displayName'] as String? ?? '',
      nameChoice: NameChoice.fromName(map['nameChoice'] as String?),
      photoChoice: PhotoChoice.fromName(map['photoChoice'] as String?),
      avatarId: map['avatarId'] as String? ?? '',
      visibility: ProfileVisibility.fromName(map['visibility'] as String?),
      completed: map['completed'] as bool? ?? false,
    );
  }
}

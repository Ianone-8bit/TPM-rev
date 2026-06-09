enum MissionStatus {
  available,
  accepted,
  completed,
  claimed,
}

enum MissionType {
  daily,
  weekly,
}

class Mission {
  final int id;
  final String title;
  final String description;
  final int rewardExp;
  final int rewardGold;
  final MissionType type;
  MissionStatus status;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardExp,
    required this.rewardGold,
    required this.type,
    this.status = MissionStatus.available,
  });
}
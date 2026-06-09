import '../models/mission.dart';

class MissionService {
  static final MissionService instance =
      MissionService();

  final List<Mission> missions = [
    Mission(
      id: 1,
      title: "Walk 1000 Steps",
      description:
          "Complete 1000 steps today",
      rewardExp: 50,
      rewardGold: 20,
      type: MissionType.daily,
    ),

    Mission(
      id: 2,
      title: "Read 15 Minutes",
      description:
          "Read any book for 15 minutes",
      rewardExp: 30,
      rewardGold: 10,
      type: MissionType.daily,
    ),

    Mission(
      id: 3,
      title: "Drink 2L Water",
      description:
          "Stay hydrated today",
      rewardExp: 20,
      rewardGold: 10,
      type: MissionType.daily,
    ),

    Mission(
      id: 4,
      title: "Walk 10000 Steps",
      description:
          "Complete 10000 steps this week",
      rewardExp: 300,
      rewardGold: 100,
      type: MissionType.weekly,
    ),

    Mission(
      id: 5,
      title: "Complete 5 Missions",
      description:
          "Finish 5 daily missions",
      rewardExp: 500,
      rewardGold: 200,
      type: MissionType.weekly,
    ),

        Mission(
      id: 6,
      title: "Shadow Training",
      description: "Shake your phone 20 times",
      rewardExp: 50,
      rewardGold: 25,
      type: MissionType.daily,
    ),  
        Mission(
      id: 7,
      title: "Visit Hunter Outpost",
      description:
          "Reach the Hunter Outpost location",
      rewardExp: 150,
      rewardGold: 50,
      type: MissionType.daily,
    ),
  ];
}
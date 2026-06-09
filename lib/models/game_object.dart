import 'dart:math';

enum ObjectType {
  equipment,
  monster,
}

class GameObject {
  double x;
  double y;

  ObjectType type;

  GameObject({
    required this.x,
    required this.y,
    required this.type,
  });

  static GameObject random(
  double maxWidth,
) {
  final random = Random();

  return GameObject(
    x: random.nextDouble() * (maxWidth - 30),
    y: -50,
    type: random.nextBool()
        ? ObjectType.equipment
        : ObjectType.monster,
  );
}
}
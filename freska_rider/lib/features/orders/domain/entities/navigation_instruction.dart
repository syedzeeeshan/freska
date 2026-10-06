import 'package:equatable/equatable.dart';

enum ManeuverType {
  turnLeft,
  turnRight,
  sharpLeft,
  sharpRight,
  slightLeft,
  slightRight,
  uTurn,
  keepLeft,
  keepRight,
  straight,
  arrive,
  depart,
  roundabout,
}

class NavigationInstruction extends Equatable {
  final String instructionText;
  final double distanceMeters;
  final ManeuverType maneuverType;
  final String? roadName;
  final bool isArrival;

  const NavigationInstruction({
    required this.instructionText,
    required this.distanceMeters,
    this.maneuverType = ManeuverType.straight,
    this.roadName,
    this.isArrival = false,
  });

  String toSpokenPhrase({double? distance}) {
    if (isArrival) {
      return 'You have arrived at your destination.';
    }

    final d = distance ?? distanceMeters;
    final road =
        (roadName != null && roadName!.isNotEmpty) ? ' onto $roadName' : '';

    if (d <= 50) {
      switch (maneuverType) {
        case ManeuverType.turnLeft:
          return 'Turn left now$road.';
        case ManeuverType.turnRight:
          return 'Turn right now$road.';
        case ManeuverType.sharpLeft:
          return 'Take a sharp left now$road.';
        case ManeuverType.sharpRight:
          return 'Take a sharp right now$road.';
        case ManeuverType.slightLeft:
          return 'Keep left now$road.';
        case ManeuverType.slightRight:
          return 'Keep right now$road.';
        case ManeuverType.uTurn:
          return 'Make a U-turn now.';
        case ManeuverType.arrive:
          return 'Arriving at destination.';
        default:
          return 'Continue straight$road.';
      }
    } else if (d <= 200) {
      final meters = (d / 10).round() * 10;
      switch (maneuverType) {
        case ManeuverType.turnLeft:
          return 'In $meters meters, turn left$road.';
        case ManeuverType.turnRight:
          return 'In $meters meters, turn right$road.';
        case ManeuverType.sharpLeft:
          return 'In $meters meters, take a sharp left$road.';
        case ManeuverType.sharpRight:
          return 'In $meters meters, take a sharp right$road.';
        case ManeuverType.uTurn:
          return 'In $meters meters, make a U-turn.';
        case ManeuverType.arrive:
          return 'In $meters meters, you will arrive at your destination.';
        default:
          return 'In $meters meters, continue straight$road.';
      }
    } else if (d <= 500) {
      switch (maneuverType) {
        case ManeuverType.turnLeft:
          return 'In 500 meters, turn left$road.';
        case ManeuverType.turnRight:
          return 'In 500 meters, turn right$road.';
        case ManeuverType.uTurn:
          return 'In 500 meters, make a U-turn.';
        case ManeuverType.arrive:
          return 'In 500 meters, you will arrive at your destination.';
        default:
          return 'In 500 meters, continue straight$road.';
      }
    } else {
      final km = (d / 1000).toStringAsFixed(1);
      return 'Continue for $km kilometers$road.';
    }
  }

  @override
  List<Object?> get props => [
        instructionText,
        distanceMeters,
        maneuverType,
        roadName,
        isArrival,
      ];
}

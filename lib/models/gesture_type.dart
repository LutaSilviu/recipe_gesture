/// Represents the types of gestures that can be detected via camera or simulator.
enum GestureType {
  none,
  left,
  right,
  up,
  down,
  fist,
  palm;

  String get label {
    switch (this) {
      case GestureType.none:
        return 'None';
      case GestureType.left:
        return '← LEFT';
      case GestureType.right:
        return 'RIGHT →';
      case GestureType.up:
        return '↑ UP';
      case GestureType.down:
        return '↓ DOWN';
      case GestureType.fist:
        return '✊ FIST';
      case GestureType.palm:
        return '✋ PALM';
    }
  }

  String get actionDescription {
    switch (this) {
      case GestureType.none:
        return '-';
      case GestureType.left:
        return 'Previous column';
      case GestureType.right:
        return 'Next column';
      case GestureType.up:
        return 'Previous row';
      case GestureType.down:
        return 'Next row';
      case GestureType.fist:
        return 'Select recipe';
      case GestureType.palm:
        return 'Back';
    }
  }
}

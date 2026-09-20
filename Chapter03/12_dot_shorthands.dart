enum TrafficLight { red, yellow, green }

class BoxSize {
  final int width, height;
  const BoxSize(this.width, this.height);
  const BoxSize.square() : width = 10, height = 10;
}

void main() {
  demoEnums();
  demoConstructors();
  demoStaticMembers();
}

void demoEnums() {
  // Without dot shorthand:
  TrafficLight oldLight = TrafficLight.red;

  // With dot shorthand (Dart 3.10+):
  TrafficLight newLight = .green;
  print('Current light: $newLight');

  final instruction = switch (newLight) {
    .red => 'Stop',
    .yellow => 'Get ready',
    .green => 'Go',
  };
  print(instruction);
}

void demoConstructors() {
  final BoxSize defaultBox = .square();
  print('Default box: ${defaultBox.width} x ${defaultBox.height}');

  final standardBox = BoxSize.new(20, 30);
  BoxSize shortcutBox = .new(50, 60);
  print('Standard: ${standardBox.width} x ${standardBox.height}, Shortcut: ${shortcutBox.width} x ${shortcutBox.height}');
}

void demoStaticMembers() {
  Uri normalUri = Uri.parse('https://dart.dev');
  Uri shorthandUri = .parse('https://flutter.dev');
  print('URIs: $normalUri, $shorthandUri');

  Duration delay = Duration.zero;
  Duration quickDelay = .zero;
  print('Delays: $delay, $quickDelay');
}

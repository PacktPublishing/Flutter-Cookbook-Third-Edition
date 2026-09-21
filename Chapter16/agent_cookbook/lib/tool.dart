abstract class Tool {
  String get name;
  String get description;
  Map<String, dynamic> get parameters;

  Future<String> execute(Map<String, dynamic> input);
}

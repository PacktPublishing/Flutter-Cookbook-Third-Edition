import 'agent_runner.dart';
import 'tool.dart';

class Specialist {
  final String name;
  final String description;
  final AgentRunner _runner;

  Specialist({
    required this.name,
    required this.description,
    required String apiKey,
    required List<Tool> tools,
  }) : _runner = AgentRunner(apiKey: apiKey) {
    for (final tool in tools) {
      _runner.registerTool(tool);
    }
  }

  Future<String> handle(String request) {
    // Each subtask is independent: a specialist has no reason to
    // remember the last one, and concurrent subtasks would otherwise
    // interleave turns in a single history.
    _runner.reset();
    return _runner.run(request);
  }
}

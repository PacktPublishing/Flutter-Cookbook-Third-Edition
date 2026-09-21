class AgentCallbacks {
  final void Function(String plan)? onPlan;
  final void Function(String toolName,
      Map<String, dynamic> args)? onToolCall;
  final void Function(String toolName,
      String result)? onToolResult;
  final void Function(String text)? onReflect;
  final void Function(String text)? onComplete;

  const AgentCallbacks({
    this.onPlan,
    this.onToolCall,
    this.onToolResult,
    this.onReflect,
    this.onComplete,
  });
}

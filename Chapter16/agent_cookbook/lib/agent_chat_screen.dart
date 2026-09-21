import 'package:flutter/material.dart';
import 'agent_callbacks.dart';
import 'reflective_agent.dart';
import 'chat_message.dart';
import 'mcp_client.dart';

class AgentChatScreen extends StatefulWidget {
  const AgentChatScreen({super.key});

  @override
  State<AgentChatScreen> createState() =>
      _AgentChatScreenState();
}

class _AgentChatScreenState
    extends State<AgentChatScreen> {
  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  late final ReflectiveAgent _agent;
  McpClient? _mcp;

  @override
  void initState() {
    super.initState();
    const apiKey = String.fromEnvironment('GOOGLE_API_KEY');
    _agent = ReflectiveAgent(apiKey: apiKey);
    _connectMcp();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _connectMcp() async {
    // Connect to the MCP server over HTTP.
    // Works on iOS, Android, and desktop.
    const url = 'http://localhost:8080';
    try {
      _mcp = await McpClient.connect(url);
      final tools = await _mcp!.listTools();
      for (final tool in tools) {
        _agent.registerTool(tool);
      }
      if (mounted) setState(() {});
    } catch (e) {
      // Usually means the server was never started.
      _addMessage(ChatMessage(
        type: MessageType.error,
        text: 'Could not reach the notes server at '
            '$url. Start mcp_notes_server to use '
            'the notes tools.',
      ));
    }
  }

  void _addMessage(ChatMessage msg) {
    if (!mounted) return;
    setState(() => _messages.add(msg));
    // Scroll to bottom after the frame renders.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    _addMessage(ChatMessage(
      type: MessageType.user,
      text: text,
    ));

    setState(() => _isLoading = true);

    try {
      await _agent.run(
        text,
        callbacks: AgentCallbacks(
          onPlan: (plan) => _addMessage(
            ChatMessage(
              type: MessageType.plan,
              text: plan,
            ),
          ),
          onToolCall: (name, args) => _addMessage(
            ChatMessage(
              type: MessageType.toolCall,
              text: 'Calling $name...',
            ),
          ),
          onToolResult: (name, result) => _addMessage(
            ChatMessage(
              type: MessageType.toolResult,
              text: '$name: $result',
            ),
          ),
          onReflect: (text) => _addMessage(
              ChatMessage(type: MessageType.reflect, text: text)),
          onComplete: (text) => _addMessage(
            ChatMessage(
              type: MessageType.response,
              text: text,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _addMessage(ChatMessage(
        type: MessageType.error,
        text: 'The agent failed: $e',
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Ask the agent...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: switch (msg.type) {
        MessageType.user => Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        MessageType.plan => _infoBubble(
            icon: Icons.checklist,
            label: 'Plan',
            text: msg.text,
          ),
        MessageType.toolCall => _infoBubble(
            icon: Icons.build,
            label: 'Tool',
            text: msg.text,
          ),
        MessageType.toolResult => _infoBubble(
            icon: Icons.check_circle_outline,
            label: 'Result',
            text: msg.text,
          ),
        MessageType.reflect => _infoBubble(
            icon: Icons.psychology,
            label: 'Reflecting',
            text: msg.text,
          ),
        MessageType.response => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(msg.text),
            ),
          ),
        MessageType.error => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
      },
    );
  }

  Widget _infoBubble({
    required IconData icon,
    required String label,
    required String text,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        leading: Icon(icon, size: 18, color: Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          text.split('\n').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

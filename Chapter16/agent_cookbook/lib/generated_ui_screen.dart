import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'agent_callbacks.dart';
import 'agent_runner.dart';
import 'chat_message.dart';
import 'forecast_tool.dart';
import 'render_ui_tool.dart';

class GeneratedUiScreen extends StatefulWidget {
  const GeneratedUiScreen({super.key});

  @override
  State<GeneratedUiScreen> createState() => _GeneratedUiScreenState();
}

class _GeneratedUiScreenState extends State<GeneratedUiScreen> {
  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  late final AgentRunner _agent;

  @override
  void initState() {
    super.initState();
    const apiKey = String.fromEnvironment('GOOGLE_API_KEY');
    _agent = AgentRunner(apiKey: apiKey)
      ..registerTool(ForecastTool())
      ..registerTool(RenderUiTool());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

    // The last tree the model asked to render during this turn.
    Map<String, dynamic>? tree;

    try {
      final reply = await _agent.run(
        text,
        callbacks: AgentCallbacks(
          onToolCall: (name, args) {
            // render_ui is never executed: its arguments are the UI.
            if (name == 'render_ui') tree = args;
          },
        ),
      );
      // With a tree, only the rendered UI is shown, not the text.
      _addMessage(ChatMessage(
        type: MessageType.response,
        text: reply,
        tree: tree,
      ));
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

  /// Builds a widget from one node of the model's UI tree. The
  /// model chooses the nodes; styling is decided here.
  Widget buildNode(Map<String, dynamic> node) {
    return switch (node['type']) {
      'text' => _buildText(node),
      'card' => _buildCard(node),
      'column' => _buildColumn(node),
      'line_chart' => _buildChart(node),
      _ => _buildFallback(node),
    };
  }

  Widget _buildText(Map<String, dynamic> node) {
    return Text('${node['value'] ?? ''}');
  }

  Widget _buildCard(Map<String, dynamic> node) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text('${node['title'] ?? ''}'),
        subtitle: Text('${node['subtitle'] ?? ''}'),
      ),
    );
  }

  Widget _buildColumn(Map<String, dynamic> node) {
    final children =
        node['children'] is List ? node['children'] as List : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final child in children.whereType<Map>())
          buildNode(Map<String, dynamic>.from(child)),
      ],
    );
  }

  Widget _buildChart(Map<String, dynamic> node) {
    final series = [
      for (final s in node['series'] is List ? node['series'] as List : [])
        if (s is Map)
          (
            name: '${s['name'] ?? ''}',
            points: s['points'] is List
                ? (s['points'] as List).whereType<num>().toList()
                : <num>[],
          ),
    ];
    // A chart needs at least one series, and every series at
    // least one number to draw.
    if (series.isEmpty || series.any((s) => s.points.isEmpty)) {
      return _buildFallback(node);
    }

    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      theme.colorScheme.secondary,
      theme.colorScheme.error,
    ];

    // One x label per point; indices if the labels don't line up.
    final count = series.map((s) => s.points.length).reduce(max);
    final labels = node['labels'] is List ? node['labels'] as List : [];

    // About three evenly spaced y labels across every series.
    final values = series.expand((s) => s.points);
    final range = values.reduce(max) - values.reduce(min);
    final yInterval = range == 0 ? 1.0 : range / 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('${node['label'] ?? ''}', style: theme.textTheme.labelLarge),
        if (series.length > 1)
          Wrap(
            spacing: 16,
            children: [
              for (var i = 0; i < series.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Container(
                      width: 12,
                      height: 3,
                      color: colors[i % colors.length],
                    ),
                    Text(series[i].name, style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                for (var i = 0; i < series.length; i++)
                  LineChartBarData(
                    spots: [
                      for (var x = 0; x < series[i].points.length; x++)
                        FlSpot(x.toDouble(), series[i].points[x].toDouble()),
                    ],
                    color: colors[i % colors.length],
                    barWidth: 3,
                  ),
              ],
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: yInterval,
                    minIncluded: false,
                    maxIncluded: false,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: Text(
                        count > 5 && value.round().isOdd
                            ? ''
                            : labels.length == count
                                ? '${labels[value.round()]}'
                                : '${value.round()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(Map<String, dynamic> node) {
    // Anything unrenderable, including a type the model
    // invented, stays visible so the failure is noticed.
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Text('Cannot render: ${jsonEncode(node)}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generated UI')),
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
                  hintText: 'Ask about the weather...',
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
    final tree = msg.tree;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: switch (msg.type) {
        _ when tree != null => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: buildNode(tree),
            ),
          ),
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
        _ => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(msg.text),
            ),
          ),
      },
    );
  }
}

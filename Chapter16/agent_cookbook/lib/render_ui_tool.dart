import 'tool.dart';

/// A client-side tool: the model calls it with a UI tree as the
/// arguments, and the screen renders them. Nothing is executed.
class RenderUiTool extends Tool {
  @override
  String get name => 'render_ui';

  @override
  String get description =>
      'Show your answer to the user as UI instead of plain text. '
      'Call this once, after you have the data, when the answer '
      'has data worth laying out, such as a forecast: a short '
      'text summary, one card per day, and a line_chart. The root '
      'is usually a column. Do not call this for greetings or '
      'simple replies; answer those in plain text. Prefer one '
      'line_chart with several series over separate charts when '
      'the data shares an x-axis. Show only what answers the '
      'question. If the answer is a single value, a text node or '
      'one card is enough — do not include the whole dataset.';

  // Fields any node may have. Only a column has children, and
  // its children cannot be columns.
  static const _fields = {
    'value': {'type': 'string', 'description': 'text: the text'},
    'title': {'type': 'string', 'description': 'card: heading'},
    'subtitle': {'type': 'string', 'description': 'card: one short line'},
    'label': {'type': 'string', 'description': 'line_chart: chart title'},
    'labels': {
      'type': 'array',
      'items': {'type': 'string'},
      'description': 'line_chart: x-axis label for each point',
    },
    'series': {
      'type': 'array',
      'description': 'line_chart: lines sharing the same x positions',
      'items': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'what this line shows'},
          'points': {
            'type': 'array',
            'items': {'type': 'number'},
            'description': 'values in order, one per label',
          },
        },
        'required': ['points'],
      },
    },
  };

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'enum': ['column', 'text', 'card', 'line_chart'],
          },
          ..._fields,
          'children': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'type': {
                  'type': 'string',
                  'enum': ['text', 'card', 'line_chart'],
                },
                ..._fields,
              },
              'required': ['type'],
            },
          },
        },
        'required': ['type'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    return 'Shown to the user.';
  }
}

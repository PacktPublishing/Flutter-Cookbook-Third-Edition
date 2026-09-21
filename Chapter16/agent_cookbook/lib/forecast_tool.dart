import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tool.dart';

class ForecastTool extends Tool {
  @override
  String get name => 'get_forecast';

  @override
  String get description =>
      'Get the forecast of daily high and low temperatures '
      'for a given city. Supply the coordinates yourself; never '
      'ask the user for them.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'city': {
            'type': 'string',
            'description': 'The city name',
          },
          'latitude': {
            'type': 'number',
            'description': 'Latitude of the city. You know the '
                'coordinates of major cities; supply them '
                'directly rather than asking the user.',
          },
          'longitude': {
            'type': 'number',
            'description': 'Longitude of the city. You know the '
                'coordinates of major cities; supply them '
                'directly rather than asking the user.',
          },
          'days': {
            'type': 'integer',
            'description': 'Number of forecast days, 1 to 16. '
                'Defaults to 5 if the user does not specify a period.',
          },
        },
        'required': ['city', 'latitude', 'longitude'],
      };

  @override
  Future<String> execute(
    Map<String, dynamic> input,
  ) async {
    final city = input['city'] as String;
    final lat = input['latitude'];
    final lon = input['longitude'];
    final days = ((input['days'] as num?)?.toInt() ?? 5).clamp(1, 16);

    final url = 'https://api.open-meteo.com'
        '/v1/forecast'
        '?latitude=$lat'
        '&longitude=$lon'
        '&daily=temperature_2m_max,temperature_2m_min'
        '&forecast_days=$days'
        '&timezone=auto';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Forecast API error: ${response.statusCode}',
      );
    }

    final daily = jsonDecode(response.body)['daily'];
    return jsonEncode({
      'city': city,
      'dates': daily['time'],
      'highs': daily['temperature_2m_max'],
      'lows': daily['temperature_2m_min'],
    });
  }
}

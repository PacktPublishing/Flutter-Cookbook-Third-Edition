import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tool.dart';

class WeatherTool extends Tool {
  @override
  String get name => 'get_weather';

  @override
  String get description =>
      'Get the current weather for a given city. Supply the '
      'coordinates yourself; never ask the user for them.';

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

    final url = 'https://api.open-meteo.com'
        '/v1/forecast'
        '?latitude=$lat'
        '&longitude=$lon'
        '&current=temperature_2m';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Weather API error: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);
    final current = data['current'];
    return jsonEncode({
      'city': city,
      'temperature': '${current['temperature_2m']}\u00B0C',
    });
  }
}

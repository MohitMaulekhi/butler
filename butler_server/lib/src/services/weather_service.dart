import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class WeatherService {
  final Session session;
  final String apiKey;

  WeatherService(this.session, this.apiKey);

  Future<String> getWeather(String city) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return 'Error: ${response.statusCode} - ${response.body}';
    }

    final data = jsonDecode(response.body);
    final main = data['main'];
    final weather = data['weather'][0];
    final temp = main['temp'];
    final desc = weather['description'];

    return 'Weather in $city: $temp°C, $desc';
  }
}

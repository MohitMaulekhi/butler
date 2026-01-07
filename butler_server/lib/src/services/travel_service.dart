import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'dart:convert';

/// Travel service for flight search and weather.
class TravelService {
  /// Searches for flights using Amadeus API.
  static Future<List<Map<String, dynamic>>> searchFlights(
    Session session, {
    required String origin,
    required String destination,
    required String date,
    required String amadeusKey,
  }) async {
    try {
      // Amadeus requires OAuth token, but for simplicity using test mode
      final response = await http.get(
        Uri.parse(
          'https://test.api.amadeus.com/v2/shopping/flight-offers'
          '?originLocationCode=$origin'
          '&destinationLocationCode=$destination'
          '&departureDate=$date'
          '&adults=1',
        ),
        headers: {'Authorization': 'Bearer $amadeusKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final offers = data['data'] as List;

        session.log('Found ${offers.length} flight offers');

        return offers
            .map((offer) {
              final price = offer['price'];
              final itinerary = offer['itineraries'][0];

              return {
                'price': price['total'],
                'currency': price['currency'],
                'duration': itinerary['duration'],
                'stops': (itinerary['segments'] as List).length - 1,
              };
            })
            .toList()
            .cast<Map<String, dynamic>>();
      }

      session.log(
        'Flight search failed: ${response.statusCode}',
        level: LogLevel.warning,
      );
      return [];
    } catch (e, stackTrace) {
      session.log(
        'Error searching flights: $e',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Gets weather forecast using OpenWeather API.
  static Future<Map<String, dynamic>?> getWeather(
    Session session,
    String city,
    String apiKey,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather'
          '?q=$city'
          '&appid=$apiKey'
          '&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'city': data['name'],
          'temperature': data['main']['temp'],
          'feels_like': data['main']['feels_like'],
          'description': data['weather'][0]['description'],
          'humidity': data['main']['humidity'],
          'wind_speed': data['wind']['speed'],
        };
      }

      return null;
    } catch (e) {
      session.log('Error getting weather: $e', level: LogLevel.warning);
      return null;
    }
  }
}

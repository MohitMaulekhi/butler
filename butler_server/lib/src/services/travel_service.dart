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

  /// Searches for hotels/hostels using Amadeus API.
  static Future<List<Map<String, dynamic>>> searchHotels(
    Session session, {
    required String cityCode,
    String? checkInDate,
    String? checkOutDate,
    int adults = 1,
    required String amadeusKey,
  }) async {
    try {
      // 1. Get Hotels by City (simplified: we accept cityCode like common IATA codes for now)
      // Note: In a real app we might need a City Search endpoint first to get IDs.
      // Amadeus 'Hotel Search' often takes a list of hotel IDs or a geocode.
      // However, v1/reference-data/locations/hotels/by-city is useful to get a list of hotels.
      // But checking availability requires 'v3/shopping/hotel-offers'.
      
      // For this implementation, we will assume 'cityCode' is an IATA code (e.g. PAR for Paris)
      // and use the v1 endpoint to fetch hotels, then check offers? 
      // Actually v1/reference-data/locations/hotels/by-city allows filtering.
      
      // Let's try the newer v3/shopping/hotel-offers directly if it supports cityCode...
      // It normally requires hotelIds.
      
      // As a shortcut for this MVP: We use v1/reference-data/locations/hotels/by-city to get hotels
      // Then we might limit to top 5 and check offers.
      // OR safer: rely on the user asking for specific known cities that map to test data if we are in test mode.
      
      // Let's use the 'HOTEL SEARCH' (v1/shopping/hotel-offers?cityCode=PAR...) if available.
      // NOTE: Amadeus has deprecated some old endpoints.
      // The reliable flow is: Get list of hotels in city -> Get offers for specific hotels.
      
      // Let's try to query 'v1/reference-data/locations/hotels/by-city' first.
      
      final hotelListResponse = await http.get(
        Uri.parse(
          'https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-city'
          '?cityCode=$cityCode'
          '&radius=5'
          '&radiusUnit=KM'
          '&hotelSource=ALL',
        ),
         headers: {'Authorization': 'Bearer $amadeusKey'},
      );
      
      if (hotelListResponse.statusCode != 200) {
        session.log('Failed to fetch hotel list: ${hotelListResponse.body}', level: LogLevel.warning);
        return [{'error': 'Could not find hotels in $cityCode'}];
      }
      
      final hotelData = json.decode(hotelListResponse.body);
      final hotels = (hotelData['data'] as List).take(5).toList(); // Limit to 5 for performance
      final hotelIds = hotels.map((h) => h['hotelId']).join(',');
      
      if (hotelIds.isEmpty) {
        return [];
      }
      
      // 2. Get Offers for these hotels
      // API: v3/shopping/hotel-offers
      var offersUrl = 'https://test.api.amadeus.com/v3/shopping/hotel-offers?hotelIds=$hotelIds&adults=$adults';
      if (checkInDate != null) offersUrl += '&checkInDate=$checkInDate';
      if (checkOutDate != null) offersUrl += '&checkOutDate=$checkOutDate';
      
      final offersResponse = await http.get(
        Uri.parse(offersUrl),
        headers: {'Authorization': 'Bearer $amadeusKey'},
      );
      
      if (offersResponse.statusCode == 200) {
        final data = json.decode(offersResponse.body);
        final offers = data['data'] as List;
        
        return offers.map((offer) {
          final hotel = offer['hotel'];
          final firstOffer = offer['offers'][0];
          
          return {
            'name': hotel['name'],
            'hotelId': hotel['hotelId'],
            'city': hotel['cityCode'], // often null in this response, better from first call if needed
            'price': firstOffer['price']['total'],
            'currency': firstOffer['price']['currency'],
            'checkIn': firstOffer['checkInDate'],
            'checkOut': firstOffer['checkOutDate'],
            'description': hotel['description']?['text'] ?? 'No description',
          };
        }).toList();
      }
      
      return [];
      
    } catch (e) {
       session.log('Error searching hotels: $e', level: LogLevel.error);
       return [];
    }
  }
}

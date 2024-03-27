import 'dart:convert';

import 'package:http/http.dart' as http;

class Weather {
  final String cityName;
  final dynamic temp;
  final dynamic hum;
  final dynamic wind;
  final dynamic des;


  Weather({
    required this.cityName,
    required this.temp,
    required this.hum,
    required this.wind,
    required this.des,
  });

  static Future<Weather> getWeatherData(String cityName) async {
    try {
      var url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'q': cityName,
          'units': 'metric',
          'appid': 'e0ea7c2430957c0b90c7a6375a5f8cba',
          'lang': 'vi'
        },
      );

      var response = await http.get(url);

      if (response.statusCode == 200) {
        String data = response.body;
        var decodeData = jsonDecode(data);

        var _cityName = decodeData['name'];
        var _temp = decodeData['main']['temp'];
        var _hum = decodeData['main']['humidity'];
        var _wind = decodeData['wind']['speed'];
        var _des = decodeData['weather'][0]['description'];
        return Weather(
          cityName: _cityName,
          temp: _temp,
          hum: _hum,
          wind: _wind,
          des: _des,
        );
      } else {
        throw Exception('Failed to fetch weather data: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to fetch weather data: $error');
    }
  }
}

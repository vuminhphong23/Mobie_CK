  import 'package:http/http.dart' as http;
  import 'dart:convert';

  class CityData {
    final String name;
    final String countryName;
    final String stateCode;
    final Map<String, int> population;

    CityData({
      required this.name,
      required this.countryName,
      required this.stateCode,
      required this.population,

    });

    factory CityData.fromJson(Map<String, dynamic> json) {
      return CityData(
        name: json['name'],
        countryName: json['countryName'],
        stateCode: json['state_code'],
        population: {},
      );
    }


    // static Future<List<CityData>> fetchListCities(String countryName) async {
    //   var result = 'https://countriesnow.space/api/v0.1/countries/states/q?country=' + countryName;
    //   var url = Uri.parse(result);
    //   var response = await http.get(url);
    //
    //
    //   if (response.statusCode == 200) {
    //     var jsonData = jsonDecode(response.body);
    //     var citiesData = jsonData['data']['states'] as List;
    //
    //     List<CityData> cities = citiesData.map((cityData) {
    //       return CityData(
    //         name: cityData['name'],
    //         countryName: jsonData['data']['name'],
    //         stateCode: cityData['state_code'],
    //         population: {},
    //       );
    //     }).toList();
    //
    //     return cities;
    //   } else {
    //     throw Exception('Failed to fetch states: ${response.reasonPhrase}');
    //   }
    // }

    static Future<CityData> fetchCityData(String countryName, String cityName) async {
      var result = 'https://countriesnow.space/api/v0.1/countries/states/q?country=' + countryName;
      var url = Uri.parse(result);

      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var statesData = jsonData['data']['states'] as List;
        var populationCounts = await fetchCityPopulation(cityName);

        List<CityData> states = statesData.map((stateData) {
          return CityData(
            name: stateData['name'],
            countryName: jsonData['data']['name'],
            stateCode: stateData['state_code'],
            population:  populationCounts,
          );
        }).toList();
        for (var s in states) {
          if (s.name == cityName) {
            return s;
          }
        }

      }
      return CityData(
        name: cityName,
        countryName: countryName,
        stateCode: '',
        population: {},
      );
    }



    static Future<List<CityData>> fetchListStates(String countryName) async {
      try {
        var result = 'https://countriesnow.space/api/v0.1/countries/states/q?country=' + countryName;
        var url = Uri.parse(result);

        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          var statesData = jsonData['data']['states'] as List;

          List<CityData> states = statesData.map((stateData) {
            return CityData(
              name: stateData['name'],
              countryName: jsonData['data']['name'],
              stateCode: stateData['state_code'],
              population: {},
            );
          }).toList();

          return states;
        } else {
          throw Exception('Failed to fetch states: ${response.reasonPhrase}');
        }
      } catch (error) {
        throw Exception('Failed to fetch states: $error');
      }
    }
    static Future<String> fetchState(String countryName, String cityName) async {
      try {
        var result = 'https://countriesnow.space/api/v0.1/countries/states/q?country=' + countryName;
        var url = Uri.parse(result);

        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          var statesData = jsonData['data']['states'] as List;

          List<CityData> states = statesData.map((stateData) {
            return CityData(
              name: stateData['name'],
              countryName: jsonData['data']['name'], // Lấy tên quốc gia từ phản hồi JSON
              stateCode: stateData['state_code'],
              population: {},
            );
          }).toList();
          for(var s in states){
            if(s.name == cityName){
              return s.stateCode;
            }
          }
          return 'Null';
        } else {
          throw Exception('Failed to fetch states: ${response.reasonPhrase}');
        }
      } catch (error) {
        return 'Null';
      }
    }
    static Future<Map<String, int>> fetchCityPopulation(String cityName) async {
      String apiUrl = 'https://countriesnow.space/api/v0.1/countries/population/cities';
      try {
        http.Response response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          Map<String, int> cityPopulationData = {};

          for (var cityData in data['data']) {
            if (cityName.toLowerCase().contains(cityData['city'].toString().toLowerCase()) || cityData['city'].toString().toLowerCase().contains(cityName.toLowerCase())) {
              var populationCounts = cityData['populationCounts'] as List;
              if (populationCounts.isNotEmpty) {
                var latestPopulation = populationCounts.last;
                int populationValue = int.tryParse(latestPopulation['value'].toString()) ?? 0;
                cityPopulationData['year'] = int.tryParse(latestPopulation['year'].toString()) ?? 0;
                cityPopulationData['population'] = populationValue;
                return cityPopulationData;
              }
              throw Exception('Population data not found for city: $cityName');
            }
          }
          throw Exception('City not found: $cityName');
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } catch (error) {
        return {'year': 0, 'population': 0};
      }
    }
  }

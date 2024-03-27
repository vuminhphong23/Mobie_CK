import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'city_model.dart';


class CountryData {
  final String country;
  final Map<String, int> populationCounts;
  final List<CityData> cities;
  final String flagUrl;
  final Map<String, String> position;
  final String currency;
  final String capital;
  final String iso2;

  CountryData({
    required this.country,
    required this.populationCounts,
    required this.cities,
    required this.flagUrl,
    required this.position,
    required this.currency,
    required this.capital,
    required this.iso2,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      country: json['country'],
      populationCounts: {},
      cities: [],
      flagUrl: '',
      position: {},
      currency: '',
      capital: '',
      iso2: '',
    );
  }

  static Future<List<CountryData>> fetchListCountriesData() async {
    var url = Uri.parse('https://countriesnow.space/api/v0.1/countries');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var countriesData = jsonData['data'] as List;

      return countriesData.map((countryData) =>
          CountryData.fromJson(countryData)).toList();
    } else {
      throw Exception(
          'Failed to fetch countries data: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, int>> _getLatestPopulation(String countryName) async {
    try {
      var url = Uri.parse('https://countriesnow.space/api/v0.1/countries/population/q?country=$countryName');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data'];

        var populationCounts = data['populationCounts'] as List;
        if (populationCounts.isNotEmpty) {
          var latestPopulation = populationCounts.last;
          return {
            'year': latestPopulation['year'],
            'population': latestPopulation['value'],
          };
        }
        throw Exception('Population data not found for country: $countryName');
      } else {
        throw Exception('Failed to fetch population data: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to fetch population data: $error')  ;
    }
  }


  static Future<String> _getFlagUrl(String countryName) async {
    try {
      var url = Uri.parse(
          'https://countriesnow.space/api/v0.1/countries/flag/images/q?country=$countryName');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var country = jsonData['data'];
        if (country['name'] == countryName) {
          return country['flag'];
        }

        throw Exception('Flag URL not found for country: $countryName');
      } else {
        throw Exception('Failed to fetch flag URL: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to fetch flag URL: $error');
    }
  }

  static Future<Map<String, String>> _getPosition(String countryName) async {
    try {
      var url = Uri.parse(
          'https://countriesnow.space/api/v0.1/countries/positions/q?country=$countryName');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var country = jsonData['data'];
        if (country['name'] == countryName) {
          return {
            'latitude': country['lat'].toString(),
            'longitude': country['long'].toString(),
          };
        }

      } else {
        throw Exception(
            'Failed to fetch country position: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to fetch country position: $error');
    }

    return {}; // Return an empty map if no geographical position is found
  }

  static Future<String> _getCurrency(String countryName) async {
    try {
      var url = Uri.parse(
          'https://countriesnow.space/api/v0.1/countries/currency/q?country=$countryName');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var country = jsonData['data'];
        if (country['name'] == countryName) {
          return country['currency'];
        }
      } else {
        throw Exception(
            'Failed to fetch country currency: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to fetch country currency: $error');
    }

    return '';
  }

  static Future<String> _getCapital(String countryName) async {
    try {
      var url = Uri.parse(
          'https://countriesnow.space/api/v0.1/countries/capital/q?country=$countryName');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var country = jsonData['data'];
        if (country['name'] == countryName) {
          return country['capital'];
        }

      } else {
        throw Exception(
            'Failed to fetch country capital: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to fetch country capital: $error');
    }

    return '';
  }

  static Future<String> _getIso2(String countryName) async {
    try {
      var url = Uri.parse('https://countriesnow.space/api/v0.1/countries/iso/q?country=$countryName');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var country = jsonData['data'];
          if (country['name'] == countryName) {
            return country['Iso2'];
          }

      } else {
        throw Exception('Failed to fetch ISO2 code: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to fetch ISO2 code: $error');
    }

    return '';
  }

  static Future<CountryData> fetchCountryData(String countryName) async {
    try {
      var flagUrl = await _getFlagUrl(countryName);
      var position = await _getPosition(countryName);
      var currency = await _getCurrency(countryName);
      var capital = await _getCapital(countryName);
      var iso2 = await _getIso2(countryName);
      var populationCounts = await _getLatestPopulation(countryName);
      var cities = await CityData.fetchListStates(countryName);

      return CountryData(
        country: countryName,
        populationCounts: populationCounts,
        flagUrl: flagUrl,
        position: position,
        currency: currency,
        capital: capital,
        iso2: iso2,
        cities: cities,
      );
    } catch (error) {
      throw Exception('Đã xảy ra lỗi khi tải dữ liệu quốc gia: $error');
    }
  }

}

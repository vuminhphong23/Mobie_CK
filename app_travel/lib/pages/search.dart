import 'dart:math';
import 'package:flutter/material.dart';
import '../models/city_model.dart';
import '../models/country_model.dart';
import 'city.dart';
import 'country.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<CountryData> _allCountries = [];
  List<CountryData> _searchResultsCountries = [];
  List<CityData> _allCities = [];
  List<CityData> _searchResultsCities = [];
  bool _isSearching = false;
  bool _searchByCity = false;
  CountryData? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _allCountries = await CountryData.fetchListCountriesData();
  }

  final Random random = Random();
  List<int> imageIndexes = List<int>.generate(11, (index) => index + 1);
  //xáo trộn ảnh
  void shuffleImageIndexes() {
    imageIndexes.shuffle();
  }

  String getRandomImagePath() {
    if (imageIndexes.isEmpty) {
      imageIndexes = List<int>.generate(11, (index) => index + 1);
      shuffleImageIndexes();
    }
    int randomIndex = imageIndexes.removeAt(0);
    return 'images/city$randomIndex.jpg';
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/city2.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Search',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Filter by: ',style: TextStyle(fontSize: 22),),
                  DropdownButton<bool>(
                    value: _searchByCity,
                    onChanged: (bool? value) {
                      setState(() {
                        _searchByCity = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: false,
                        child: Text('Country',style: TextStyle(fontSize: 20),),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('City',style: TextStyle(fontSize: 20),),
                      ),
                    ],
                  ),
                ],
              ),
              if (_searchByCity) _buildCountryDropdown(),
              SizedBox(height: 10),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: _searchByCity ? 'Enter city name' : 'Enter country name',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 18),
                ),
                onChanged: (value) {
                  _search(value);
                },
              ),
              SizedBox(height: 10),
              _isSearching
                  ? Expanded(
                child: _searchByCity
                    ? _buildCityResultsList()
                    : _buildCountryResultsList(),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButton<CountryData>(
      value: _selectedCountry,
      hint: Text('Select a country',style: TextStyle(fontSize: 22),),
      onChanged: (CountryData? newValue) {
        setState(() {
          _selectedCountry = newValue;
          if (_selectedCountry != null) {
            _loadCitiesForSelectedCountry(_selectedCountry!.country);
          }
        });
      },
      items: _allCountries.map<DropdownMenuItem<CountryData>>((CountryData country) {
        return DropdownMenuItem<CountryData>(
          value: country,
          child: Text(country.country,style: TextStyle(fontSize: 16),),
        );
      }).toList(),
    );
  }

  Future<void> _loadCitiesForSelectedCountry(String countryName) async {
    _allCities = await CityData.fetchListStates(countryName);
  }
//kq tìm kiếm list countries
  Widget _buildCountryResultsList() {
    return _searchResultsCountries.isEmpty
        ? Center(child: Text('No results found'))
        : ListView.builder(
      itemCount: _searchResultsCountries.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: ListTile(
            leading: Container(
              width: 45, height: 45,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  _searchResultsCountries[index].country[0],
                  style: TextStyle(color: Colors.white,fontSize: 22),
                ),
              ),
            ),
            title: Text(_searchResultsCountries[index].country,style: TextStyle(fontWeight: FontWeight.w500),),
            trailing: ClipRRect(
              borderRadius: BorderRadius.circular(50), // Độ cong của góc
              child: Image.asset(
                getRandomImagePath(),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CountryDetail(countryName: _searchResultsCountries[index].country)));
            },
          ),
        );
      },
    );
  }
//kq tìm kiếm list cities
  Widget _buildCityResultsList() {
    return _searchResultsCities.isEmpty
        ? Center(child: Text('No results found'))
        : ListView.builder(
      itemCount: _searchResultsCities.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: ListTile(
            leading: Container(
              width: 45, height: 45,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  _searchResultsCities[index].name[0],
                  style: TextStyle(color: Colors.white,fontSize: 22),
                ),
              ),
            ),
            title: Text(_searchResultsCities[index].name,style: TextStyle(fontWeight: FontWeight.w500),),
            subtitle: Text(_searchResultsCities[index].countryName),
            trailing: ClipRRect(
              borderRadius: BorderRadius.circular(50), // Độ cong của góc
              child: Image.asset(
                getRandomImagePath(),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityDetail(
                    cityName: _searchResultsCities[index].name,
                    countryName: _selectedCountry!.country,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _search(String query) {
    if (_searchByCity) {
      _searchCities(query);
    } else {
      _searchCountries(query);
    }
  }

  void _searchCountries(String query) {
    setState(() {
      _searchResultsCountries = _allCountries
          .where((country) => country.country.toLowerCase().
      contains(query.toLowerCase()))
          .toList();
      _isSearching = query.isNotEmpty;
    });
  }

  void _searchCities(String query) {
    setState(() {
      _searchResultsCities = _allCities
          .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _isSearching = query.isNotEmpty;
    });
  }
}








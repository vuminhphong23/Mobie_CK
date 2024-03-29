import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'city.dart';
import 'country.dart';

class ListFavoritePage extends StatefulWidget {
  final int index;

  const ListFavoritePage({required this.index});
  @override
  _ListFavoritePageState createState() => _ListFavoritePageState();
}

class _ListFavoritePageState extends State<ListFavoritePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/city5.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Favorites', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Expanded(
                child: widget.index == 1 ? _buildCityList() : _buildCountryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collectionGroup('favourite_countries').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No favorites found'));
        }

        // Tạo một map để đếm số lần xuất hiện của mỗi quốc gia
        Map<String, int> countryCountMap = {};
        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          var data = document.data() as Map<String, dynamic>;
          String country = data['country'];
          if (countryCountMap.containsKey(country)) {
            countryCountMap[country] = countryCountMap[country]! + 1;
          } else {
            countryCountMap[country] = 1;
          }
        });

        List<MapEntry<String, int>> sortedCountries = countryCountMap.entries.toList();
        sortedCountries.sort((a, b) => b.value.compareTo(a.value));
        sortedCountries = sortedCountries.take(10).toList();
        List<Widget> countryCards = [];
        sortedCountries.forEach((entry) {
          String country = entry.key;
          int count = entry.value;
          countryCards.add(
            _buildCountryCard(country, count),
          );
        });

        return ListView(
          children: countryCards,
        );
      },
    );
  }




  Widget _buildCityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collectionGroup('favourite_cities').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No favorites found'));
        }

        Map<String, int> cityCountMap = {};
        Map<String, String> cityCountryMap = {};
        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          var data = document.data() as Map<String, dynamic>;
          String city = data['name'];
          String country = data['countryName'];
          if (cityCountMap.containsKey(city)) {
            cityCountMap[city] = cityCountMap[city]! + 1;
          } else {
            cityCountMap[city] = 1;
            cityCountryMap[city] = country;
          }
        });

        List<MapEntry<String, int>> sortedCities = cityCountMap.entries.toList();
        sortedCities.sort((a, b) => b.value.compareTo(a.value));

        List<Widget> cityCards = [];
        sortedCities = sortedCities.take(10).toList();
        sortedCities.forEach((entry) {
          String city = entry.key;
          int count = entry.value;
          String countryName = cityCountryMap[city]!;
          cityCards.add(
            _buildCityCard(city, countryName, count),
          );
        });

        return ListView(
          children: cityCards,
        );
      },
    );
  }

  Widget _buildCountryCard(String country, int count) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            country.isNotEmpty ? country[0] : '',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
        title: Text(country,style: TextStyle(fontWeight: FontWeight.w500),),
        trailing: Stack(
          children: [
            Icon(
                Icons.favorite,
                size: 30,
                color: Colors.redAccent
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CountryDetail(countryName: country)),
          );
        },
      ),
    );
  }

  Widget _buildCityCard(String cityName, String countryName, int count) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            cityName.isNotEmpty ? cityName[0] : '',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
        title: Text(cityName,style: TextStyle(fontWeight: FontWeight.w500),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(countryName != null ? countryName : ''),
            SizedBox(height: 5),
          ],
        ),
        trailing:Stack(
          children: [
            Icon(
              Icons.favorite,
              size: 30,
              color: Colors.redAccent
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CityDetail(
                cityName: cityName,
                countryName: countryName,
              ),
            ),
          );
        },
      ),
    );
  }
}

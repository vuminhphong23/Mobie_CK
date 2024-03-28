import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_travel/models/city_model.dart';
import 'city.dart';
import 'country.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool _searchByCity = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          title: Text('Favorites', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Filter by: ', style: TextStyle(fontSize: 22)),
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
                        child: Text('Country', style: TextStyle(fontSize: 20)),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('City', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: _searchByCity ? _buildCityList() : _buildCountryList(),
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

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            var data = document.data() as Map<String, dynamic>;
            return _buildCountryCard(data['country']);
          }).toList(),
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

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            var data = document.data() as Map<String, dynamic>;
            return _buildCityCard(data['name'], data['countryName']);
          }).toList(),
        );
      },
    );
  }

  Widget _buildCountryCard(String countryName) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            countryName[0],
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
        title: Text(countryName),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CountryDetail(countryName: countryName)),
          );
        },
      ),
    );
  }

  Widget _buildCityCard(String cityName, String countryName) {
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
        title: Text(cityName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(countryName != null ? countryName : ''),
            SizedBox(height: 5),
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

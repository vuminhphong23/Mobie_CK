import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'city.dart';
import 'country.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool _searchByCity = false;
  late String userId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserId();
  }

  Future<void> _checkUserId() async {
    // Get userId from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
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
          image: AssetImage('images/city9.jpg'),
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
                  Text('Filter by: ', style: TextStyle(fontSize: 22,fontWeight: FontWeight.w400)),
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
      stream: _firestore.collection('favourite').doc(userId).collection('favourite_countries').snapshots(),
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
      stream: _firestore.collection('favourite').doc(userId).collection('favourite_cities').snapshots(),
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

        List<Map<String, dynamic>> cityDataList = snapshot.data!.docs.map((DocumentSnapshot document) {
          var data = document.data() as Map<String, dynamic>;
          return {
            'name': data['name'],
            'countryName': data['countryName'],
          };
        }).toList();

        // Nhóm thành phố theo quốc gia
        Map<String, List<Map<String, dynamic>>> groupedByCountry = {};
        cityDataList.forEach((cityData) {
          String country = cityData['countryName'];
          groupedByCountry.putIfAbsent(country, () => []);
          groupedByCountry[country]!.add(cityData);
        });

        // Sắp xếp các quốc gia theo chữ cái đầu
        List<String> sortedCountries = groupedByCountry.keys.toList();
        sortedCountries.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        // Sắp xếp các thành phố trong mỗi nhóm quốc gia theo chữ cái đầu của tên thành phố
        groupedByCountry.forEach((country, cities) {
          cities.sort((a, b) => (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));
        });

        // Tạo danh sách các widget thành phố đã sắp xếp
        List<Widget> sortedCityWidgets = [];
        sortedCountries.forEach((country) {
          sortedCityWidgets.add(Text(country, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,)));
          sortedCityWidgets.addAll(groupedByCountry[country]!.map((cityData) => _buildCityCard(cityData['name'], cityData['countryName'])));
        });

        return ListView(
          children: sortedCityWidgets,
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
        title: Text(countryName,style: TextStyle(fontWeight: FontWeight.w500),),
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(50), // Độ cong của góc
          child: Image.asset(
            getRandomImagePath(),
            width: 45,
            height: 45,
            fit: BoxFit.cover,
          ),
        ),
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
        title: Text(cityName,style: TextStyle(fontWeight: FontWeight.w500),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(countryName != null ? countryName : ''),
            SizedBox(height: 5),
          ],
        ),
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(50), // Độ cong của góc
          child: Image.asset(
            getRandomImagePath(),
            width: 45,
            height: 45,
            fit: BoxFit.cover,
          ),
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

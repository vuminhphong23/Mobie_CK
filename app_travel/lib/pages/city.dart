import 'dart:async';
import 'package:app_travel/models/city_model.dart';
import 'package:app_travel/widgets/app_bar_city.dart';
import 'package:flutter/material.dart';
import '../models/timezone.dart';
import '../models/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/weather_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'clock.dart';

class CityDetail extends StatefulWidget {
  final String cityName;
  final String countryName;

  const CityDetail({required this.cityName, required this.countryName});

  @override
  State<CityDetail> createState() => _CityDetailState();
}

class _CityDetailState extends State<CityDetail> {
  late Future<CityData> _cityData;
  late Future<Weather> _weatherData;
  late TimeInfo _timeInfo;
  late String _randomImagePath;
  late bool _isFavorite = false;
  String? userId;



  String getWeatherImage(String weatherDescription) {
    if (weatherDescription.contains('đen')) {
      return 'heavycloud';
    } else if (weatherDescription.contains('mưa')) {
      return 'lightrain';
    } else if (weatherDescription.contains('nắng')) {
      return 'clear';
    } else if (weatherDescription.contains('rào')) {
      return 'thunderstorm';
    } else if (weatherDescription.contains('mây')) {
      return 'lightcloud';
    } else {
      return 'clear';
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  @override
  void initState() {
    super.initState();
    initializeData();

  }
  Future<void> _fetchTimeInfo(String name) async {
    if(readTimezonesFromFile(name) == 'null'){
      setState(() {
        _timeInfo = TimeInfo(
          datetime: '...',
        );
      });
      return;
    }
    final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/'+'${readTimezonesFromFile(name)}'+'.txt'));

    if (response.statusCode == 200) {
      List<String> data = response.body.split('\n');
      String time = '';
      for (String line in data) {
        if (line.startsWith('datetime:')) {
          time = line.substring(10);
          break;
        }
      }
      DateTime dateTime = DateTime.parse(time.replaceAll('T', ' ').split('.')[0]);

      String formattedDateTime = '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
      setState(() {
        _timeInfo = TimeInfo(
          datetime: formattedDateTime,
        );
      });
    } else {
      throw Exception('Failed to load time information');
    }
  }

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Random random = Random();

  String getRandomImagePath() {
    int randomIndex = random.nextInt(11);
    return 'images/city${randomIndex + 1}.jpg';
  }

  Future<bool> isCityFavourite(String cityName) async {
    try {
      // Check if the country is already in the favorites list
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favourite_cities')
          .where('name', isEqualTo: cityName)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      // Handle error if any
      print('Error while checking country in favourites: $error');
      return false;
    }
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

  Future<void> initializeData() async {
    _cityData = CityData.fetchCityData(widget.countryName,widget.cityName);
    _weatherData = Weather.getWeatherData(widget.countryName);
    _timeInfo = TimeInfo(datetime: "...");
    _randomImagePath = getRandomImagePath();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _fetchTimeInfo(widget.countryName));
    _isFavorite = await isCityFavourite(widget.cityName);
    _checkUserId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_randomImagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: AppBarCity(name: widget.cityName),
        ),
        body: FutureBuilder(
          future: _cityData,
          builder: (context, AsyncSnapshot<CityData> snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;
              return SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFA8D1F6),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFA8D1F6).withOpacity(.5),
                            offset: const Offset(0, 25),
                            blurRadius: 10,
                            spreadRadius: -12,
                          )
                        ],
                      ),
                      child: FutureBuilder(
                        future: _weatherData,
                        builder: (context, AsyncSnapshot<Weather> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            var weather = snapshot.data!;
                            return SingleChildScrollView(
                              padding: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 75),
                                    child: Text(
                                      _timeInfo.datetime != "..." ? _timeInfo.datetime : '',
                                      style: TextStyle(
                                        color: Color(0xff04225b),
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Container(
                                        width: 200,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(.5),
                                              offset: const Offset(0, 25),
                                              blurRadius: 10,
                                              spreadRadius: -12,
                                            )
                                          ],
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              top: -40,
                                              left: 20,
                                              child: Image.asset(
                                                'images/${getWeatherImage(weather.des)}.png',
                                                width: 100,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              left: 20,
                                              child: Tooltip(
                                                message: weather.des,
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width - 220,
                                                  child: Text(
                                                    weather.des,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                    ),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 50,
                                              right: 20,
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text(
                                                      weather.temp.toString(),
                                                      style: TextStyle(
                                                        fontSize: 40,
                                                        fontWeight: FontWeight.bold,
                                                        foreground: Paint()..shader = linearGradient,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    'o',
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                      fontWeight: FontWeight.bold,
                                                      foreground: Paint()..shader = linearGradient,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 50),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            weatherItem(
                                              text: 'Wind Speed',
                                              value: weather.wind,
                                              unit: 'km/h',
                                              imageUrl: 'images/windspeed.png',
                                            ),
                                            SizedBox(height: 15,),
                                            weatherItem(
                                                text: 'Humidity',
                                                value: weather.hum,
                                                unit: '',
                                                imageUrl: 'images/humidity.png'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      height: MediaQuery.of(context).size.height / 2.8,
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFEDF2F6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${data.name}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  if (!_isFavorite) {
                                    try {
                                      // Save country data to Firestore
                                      await _firestore
                                          .collection('users')
                                          .doc(userId)
                                          .collection('favourite_cities')
                                          .add({
                                        'name': data.name,
                                        'countryName': data.countryName,
                                        'stateCode': data.stateCode,
                                        'population': data.population,
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('City added to favourites')),
                                      );

                                      setState(() {
                                        _isFavorite = true; // Mark as added to favourites
                                      });
                                    } catch (error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to add City to favourites')),
                                      );
                                      print('Failed to add City to favourites: $error');
                                    }
                                  } else {
                                    try {
                                      // Get reference of document to delete from Firestore
                                      QuerySnapshot querySnapshot = await _firestore
                                          .collection('users')
                                          .doc(userId)
                                          .collection('favourite_cities')
                                          .where('name', isEqualTo: data.name)
                                          .get();

                                      querySnapshot.docs.forEach((doc) async {
                                        // Delete document from Firestore
                                        await _firestore
                                            .collection('users')
                                            .doc(userId)
                                            .collection('favourite_cities')
                                            .doc(doc.id)
                                            .delete();
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('City removed from favourites')),
                                      );

                                      setState(() {
                                        _isFavorite = false; // Mark as removed from favourites
                                      });
                                    } catch (error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to remove city from favourites')),
                                      );
                                      print('Failed to remove city from favourites: $error');
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    color: _isFavorite ? Colors.red : Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text('StateCode: ${data.stateCode}',style: TextStyle(fontSize: 18),),
                          SizedBox(height:10),
                          Text('Country: ${data.countryName}',style: TextStyle(fontSize: 18),),
                          SizedBox(height:10),
                          Text('Population: ${data.population.isNotEmpty ? data.population['population'] : "Không có dữ liệu"}' + ' (Năm '+ '${data.population['year']})', style: TextStyle(fontSize: 18),),
                          SizedBox(height:10),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    'images/city2.jpg',
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 90,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    'images/city3.jpg',
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 90,
                                  ),
                                ),
                              ),
                              Container(
                                width: 105,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage('images/city4.jpg'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.4),
                                      BlendMode.srcOver,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "10+",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('City Not Found'),
                      content: Text('${widget.cityName} city currently has no data.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              });
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

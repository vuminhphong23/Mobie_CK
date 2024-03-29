import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/country_model.dart';
import '../models/timezone.dart';
import '../models/weather.dart';
import '../widgets/app_bar_country.dart';
import '../widgets/weather_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'clock.dart';

class CountryDetail extends StatefulWidget {
  final String countryName;

  const CountryDetail({required this.countryName});

  @override
  State<CountryDetail> createState() => _CountryDetailState();
}

class _CountryDetailState extends State<CountryDetail> {
  late Future<CountryData> _countryData;
  late Future<Weather> _weatherData;
  late TimeInfo _timeInfo;
  late String _randomImagePath;
  late bool _isFavorite = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> _fetchTimeInfo(String name) async {
    if (readTimezonesFromFile(name) == 'null') {
      setState(() {
        _timeInfo = TimeInfo(
          datetime: '...',
        );
      });
      return;
    }
    final response =
    await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/' + '${readTimezonesFromFile(name)}' + '.txt'));

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

      String formattedDateTime =
          '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isCountryFavourite(String countryName) async {
    try {
      // Check if the country is already in the favorites list
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favourite_countries')
          .where('country', isEqualTo: countryName)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      // Handle error if any
      print('Error while checking country in favourites: $error');
      return false;
    }
  }

  bool _userIdChecked = false; // kiểm tra xem userId đã được kiểm tra hay chưa

  Future<void> _checkUserId() async {
    if (!_userIdChecked) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid;
        });
      }
      _userIdChecked = true;
    }
  }

  Future<void> initializeData() async {
    _countryData = CountryData.fetchCountryData(widget.countryName);
    _weatherData = Weather.getWeatherData(widget.countryName);
    _randomImagePath = getRandomImagePath();
    _timeInfo = TimeInfo(datetime: "...");
    Timer.periodic(Duration(seconds: 1), (Timer t) => _fetchTimeInfo(widget.countryName));
    _checkUserId();
    _isFavorite = await isCountryFavourite(widget.countryName);
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
          child: AppBarCountry(name: widget.countryName),
        ),
        body: FutureBuilder(
          future: _countryData,
          builder: (context, AsyncSnapshot<CountryData> snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;
              return SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Thời tiết
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
                          ]),
                      child: FutureBuilder(
                        future: _weatherData,
                        builder: (context, AsyncSnapshot<Weather> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            var weather = snapshot.data!;
                            return Column(
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
                                const SizedBox(
                                  height: 20,
                                ),
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
                                          ]),
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
                                          SizedBox(height: 15),
                                          weatherItem(
                                            text: 'Humidity',
                                            value: weather.hum,
                                            unit: '',
                                            imageUrl: 'images/humidity.png',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    //Quốc gia
                    Container(
                      height: MediaQuery.of(context).size.height / 2.3,
                      padding: EdgeInsets.all(20),
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
                                '${data.country}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  if (!_isFavorite) {
                                    try {

                                      await _firestore
                                          .collection('users')
                                          .doc(userId)
                                          .collection('favourite_countries')
                                          .add({
                                        'country': data.country,
                                        'populationCounts': data.populationCounts,
                                        'flagUrl': data.flagUrl,
                                        'position': data.position,
                                        'currency': data.currency,
                                        'capital': data.capital,
                                        'iso2': data.iso2,
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Country added to favourites')),
                                      );

                                      setState(() {
                                        _isFavorite = true; // Mark as added to favourites
                                      });
                                    } catch (error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to add country to favourites')),
                                      );
                                      print('Failed to add country to favourites: $error');
                                    }
                                  } else {
                                    try {
                                      // Get reference of document to delete from Firestore
                                      QuerySnapshot querySnapshot = await _firestore
                                          .collection('users')
                                          .doc(userId)
                                          .collection('favourite_countries')
                                          .where('country', isEqualTo: data.country)
                                          .get();

                                      querySnapshot.docs.forEach((doc) async {

                                        await _firestore
                                            .collection('users')
                                            .doc(userId)
                                            .collection('favourite_countries')
                                            .doc(doc.id)
                                            .delete();
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Country removed from favourites')),
                                      );

                                      setState(() {
                                        _isFavorite = false; // Mark as removed from favourites
                                      });
                                    } catch (error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to remove country from favourites')),
                                      );
                                      print('Failed to remove country from favourites: $error');
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
                          Text(
                            'Population: ${data.populationCounts.isNotEmpty ? data.populationCounts['population'] : "Data not available"} (Year ${data.populationCounts['year']})',
                            style: TextStyle(fontSize: 18),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 9),
                                  Text(
                                    'Position :',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 9),
                                  Text(
                                    '   + ${data.position.isNotEmpty ? 'Lat: ${data.position['latitude']}' : "Data not available"}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 9),
                                  Text(
                                    '   + ${data.position.isNotEmpty ? 'Long: ${data.position['longitude']}' : "Data not available"}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 9),
                                  Text(
                                    'Currencies: ${data.currency}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              SizedBox(width: 2),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  data.flagUrl.isNotEmpty
                                      ? SvgPicture.network(
                                    data.flagUrl,
                                    height: 62,
                                    width: 50,
                                  )
                                      : Text('No flag data available'),
                                  SizedBox(height: 8),
                                  Text(
                                    'Capital: ${data.capital}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Code ISO2: ${data.iso2}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    'images/city4.jpg',
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
                                    'images/city5.jpg',
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
                                    image: AssetImage('images/city6.jpg'),
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
                    SizedBox(height: 20),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Country Not Found'),
                      content: Text('${widget.countryName} currently has no data.'),
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
}

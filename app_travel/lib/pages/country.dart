import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/country_model.dart';
import '../models/weather.dart';
import '../widgets/post_app_bar.dart';
import '../widgets/weather_item.dart';
import 'cities_of_country.dart';
import 'package:intl/intl.dart';

class CountryDetail extends StatefulWidget {
  final String countryName;
  const CountryDetail({required this.countryName});
  @override
  State<CountryDetail> createState() => _CountryDetailState();
}

class _CountryDetailState extends State<CountryDetail> {
  late Future<CountryData> _countryData;
  late Future<Weather> _weatherData;

  String getWeatherImage(String weatherDescription) {
    if (weatherDescription.contains('đen')) {
      return 'heavycloud';
    } else if (weatherDescription.contains('mưa')) {
      return 'lightrain';
    } else if (weatherDescription.contains('nắng')) {
      return 'clear';
    } else if (weatherDescription.contains('rào')) {
      return 'thunderstorm';
    } else if (weatherDescription.contains('mây')){
      return 'lightcloud';
    }
    else {
      return 'clear';
    }
  }
  @override
  void initState() {
    super.initState();
    _countryData = CountryData.fetchCountryData(widget.countryName);
    _weatherData = Weather.getWeatherData(widget.countryName);
  }
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Random random = Random();

  String getRandomImagePath() {
    int randomIndex = random.nextInt(6);
    return 'images/city${randomIndex + 1}.jpg';
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(getRandomImagePath()),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: PostAppBar(name:widget.countryName),
        ),
        body: FutureBuilder(
          future: _countryData,
          builder: (context, AsyncSnapshot<CountryData> snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;
              return SingleChildScrollView(
                padding: EdgeInsets.only(left:16, right:16, top:5),
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
                            return SingleChildScrollView(
                              padding: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy - HH:mm:ss').format(DateTime.now()),
                                      style: const TextStyle(
                                        color: Color(0xff04225b),
                                        fontSize: 25,
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
                      height: MediaQuery.of(context).size.height / 2.35,
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
                                '${data.country}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "4.5",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text('Population: ${data.populationCounts.isNotEmpty ? data.populationCounts['population'] : "Không có dữ liệu"}' + ' (Năm '+ '${data.populationCounts['year']})', style: TextStyle(fontSize: 18),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 9),
                                    Text('Position :', style: TextStyle(fontSize: 18),),
                                    SizedBox(height: 9),
                                    Text('   + ${data.position.isNotEmpty ? 'Lat: ${data.position['latitude']}' : "Không có dữ liệu"}', style: TextStyle(fontSize: 18),),
                                    SizedBox(height: 9),
                                    Text('   + ${data.position.isNotEmpty ? 'Long: ${data.position['longitude']}' : "Không có dữ liệu"}', style: TextStyle(fontSize: 18),),
                                    SizedBox(height: 9),
                                    Text('Currencies: ${data.currency}', style: TextStyle(fontSize: 18),),
                                  ]
                              ),
                              SizedBox(width: 2,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height:10),
                                  data.flagUrl.isNotEmpty
                                      ? SvgPicture.network(
                                    data.flagUrl,
                                    height: 62,
                                    width: 50,
                                  ): Text('Không có dữ liệu về quốc kỳ'),
                                  SizedBox(height: 8),
                                  Text('Capital: ${data.capital}', style: TextStyle(fontSize: 18),),
                                  SizedBox(height: 8),
                                  Text('Code ISO2: ${data.iso2}', style: TextStyle(fontSize: 18),),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height:10),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    getRandomImagePath(),
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
                                    getRandomImagePath(),
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
                                    image: AssetImage(getRandomImagePath()),
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
        floatingActionButton: Container(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityListScreen(countryName: widget.countryName),
                ),
              );
            },
            child:Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("View",style: TextStyle(fontSize: 20, color: Colors.black),),
                  Text("Cities",style: TextStyle(fontSize: 20, color: Colors.black),),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,



      ),
    );
  }
}
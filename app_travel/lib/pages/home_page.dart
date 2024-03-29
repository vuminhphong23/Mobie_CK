import 'dart:math';

import 'package:app_travel/models/city_model.dart';
import 'package:app_travel/pages/list_best_favorite.dart';
import 'package:app_travel/widgets/home_app_bar.dart';
import 'package:app_travel/widgets/home_bottom_bar.dart';
import 'package:app_travel/pages/country.dart';
import 'package:flutter/material.dart';

import '../components/mydrawer.dart';
import '../models/country_model.dart';
import 'city.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var category = [
    'Best Country Places',
    'Best City Places',
  ];



  List<CountryData> _allCountries = [];
  List<CityData> _allCities = [];

  bool _isLoading = true;
  String location = 'Vietnam';
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  Future<void> _loadData() async {
    await Future.wait([_loadCities('Vietnam'),_loadCountries()]);
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _loadCountries() async {
    _allCountries = await CountryData.fetchListCountriesData();
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _loadCities(String location) async {
    _allCities = await CityData.fetchListStates(location);
    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: HomeAppBar(
          onLocationChanged: (String location) {
            setState(() {
              this.location = location;
            });
            _loadCities(location);
          },
        )
      ),
      drawer: MyDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: 6,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            if (_allCountries.isEmpty) {
                              return SizedBox();
                            }
                            if (index < _allCountries.length) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CountryDetail(countryName: _allCountries[index].country),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 160,
                                  padding: EdgeInsets.all(20),
                                  margin: EdgeInsets.only(left: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: AssetImage('images/city${index+1}.jpg'),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.dstATop),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: Icon(
                                          Icons.bookmark_border_outlined,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          '${_allCountries[index].country}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for(int i = 0; i < 2; i++)
                          InkWell(
                            onTap: (){
                              if (i == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ListFavoritePage(index: i)),
                                );
                              } else if (i == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      ListFavoritePage(index: i)),
                                );
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    )
                                  ]
                              ),
                              child: Text(
                                category[i],
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    if (_allCities.isNotEmpty && _allCities.length > index) {
                      return Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CityDetail(
                                      cityName: _allCities[index].name,
                                      countryName: location,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage('images/city${index+6}.jpg'),
                                    fit: BoxFit.cover,
                                    opacity: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_allCities[index].name}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.more_vert,
                                    size: 30,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                Text(
                                  "4.5",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  },


                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(height:70,child: HomeBottomBar()),
    );
  }
}

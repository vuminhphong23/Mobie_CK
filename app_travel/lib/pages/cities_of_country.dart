
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/city_model.dart';
import 'city.dart';


class CityListScreen extends StatefulWidget {
  final String countryName;

  CityListScreen({required this.countryName});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  bool isSearching = false;
  List<CityData> originalCities = [];
  List<CityData> displayedCities = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      List<CityData> cities = await CityData.fetchListStates(widget.countryName);
      setState(() {
        originalCities = cities;
        displayedCities = cities;
      });
    } catch (error) {
      print('Error fetching cities: $error');
    }
  }

  void _filterCities(String query) {
    setState(() {
      displayedCities = originalCities.where((city) => city.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }
  final Random random = Random();

  String getRandomImagePath() {
    int randomIndex = random.nextInt(6); // Sinh số ngẫu nhiên từ 0 đến 5
    return 'images/city${randomIndex + 1}.jpg'; // Trả về đường dẫn của hình ảnh
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
          child: AppBarCities(context),
        ),
        body: ListView.builder(
          itemCount: displayedCities.length,
          itemBuilder: (context, index) {
            return _buildCardWithLeadingAvatar(displayedCities[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildCardWithLeadingAvatar(CityData city, int index) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetail(cityName: city.name,countryName: widget.countryName,),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: ListTile(
          leading: Container(
            width: 50, height: 50,
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                city.name[0],
                style: TextStyle(color: Colors.white,fontSize: 22),
              ),
            ),
          ),
          title: Text(city.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),),
          subtitle: Text('StateCode: ${city.stateCode}',style: TextStyle(fontSize: 16),),
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(50), // Độ cong của góc
            child: Image.asset(
              getRandomImagePath(),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget AppBarCities(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 6,
                      )
                    ]
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          isSearching ? Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: _filterCities,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ),
          ) : Container(),
          Container(
            width: 50,
            height: 50,
            child: InkWell(
              onTap: (){
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    displayedCities = originalCities;
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 6,
                      )
                    ]
                ),
                child: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

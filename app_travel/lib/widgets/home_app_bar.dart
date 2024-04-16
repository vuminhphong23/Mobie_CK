
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import '../models/country_model.dart';
import '../pages/search.dart';

class HomeAppBar extends StatefulWidget {
  final Function(String) onLocationChanged;

  HomeAppBar({required this.onLocationChanged});

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  TextEditingController locationController = TextEditingController();
  String location ="Vietnam";
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    locationController.text = 'Vietnam';
    _loadCountries();
  }
  List<CountryData> _allCountries = [];
  List<String> countryNames = [];

  Future<void> _loadCountries() async {
    _allCountries = await CountryData.fetchListCountriesData();
    for (var countryData in _allCountries) {
      countryNames.add(countryData.country);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                  )
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sort_rounded,
                size: 28,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 55),
          Icon(
            Icons.location_on,
            color: Color(0xFFF65959),
            size: 30,
          ),
          SizedBox(width: 5),
          Expanded(
            child: AutoCompleteTextField<String>(
              key: key,style: TextStyle(fontSize: 22),
              controller: locationController,
              clearOnSubmit: false,
              suggestions: countryNames,
              itemBuilder: (BuildContext context, String suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              itemFilter: (String suggestion, String query) {
                return suggestion.toLowerCase().startsWith(query.toLowerCase());
              },
              itemSorter: (String a, String b) {
                return a.compareTo(b);
              },
              itemSubmitted: (String suggestion) {
                setState(() {
                  location = suggestion;
                  locationController.text = suggestion;
                });
                widget.onLocationChanged(suggestion);
              },
              decoration: InputDecoration(
                hintText: "Enter location",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.search,
                size: 28,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}


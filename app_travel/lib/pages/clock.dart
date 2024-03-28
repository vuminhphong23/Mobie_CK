
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/timezone.dart';

class TimeInfo {
  final String datetime;
  TimeInfo({
    required this.datetime,
  });

  factory TimeInfo.fromJson(Map<String, dynamic> json) {
    return TimeInfo(
      datetime: json['datetime'],
    );
  }
}

// class ClockPage extends StatefulWidget {
//   @override
//   _ClockPageState createState() => _ClockPageState();
// }
//
// class _ClockPageState extends State<ClockPage> {
//   late TimeInfo _timeInfo;
//
//   @override
//   void initState() {
//     super.initState();
//     _timeInfo = TimeInfo( // Khởi tạo _timeInfo với giá trị null
//       datetime: '',
//     );
//     _fetchTimeInfo(); // Gọi hàm để lấy dữ liệu từ JSON
//     Timer.periodic(Duration(seconds: 1), (Timer t) => _fetchTimeInfo()); // Cập nhật dữ liệu mỗi giây
//   }
//
//   Future<void> _fetchTimeInfo(String name) async {
//     readTimezonesFromFile(name);
//     final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/'+'${readTimezonesFromFile(name)}'+'.txt'));
//
//     if (response.statusCode == 200) {
//       List<String> data = response.body.split('\n');
//       String time = '';
//       for (String line in data) {
//         if (line.startsWith('datetime:')) {
//           time = line.substring(10);
//           break;
//         }
//       }
//       DateTime dateTime = DateTime.parse(time);
//       String formattedDateTime = '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
//       setState(() {
//         _timeInfo = TimeInfo(
//           datetime: formattedDateTime,
//         );
//       });
//     } else {
//       throw Exception('Failed to load time information');
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Clock'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Time: ${_timeInfo.datetime}',
//               style: TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';

// import 'package:blog/constant.dart';
// import 'package:blog/models/api_response2.dart';
// import 'package:blog/models/user2.dart';
// import 'package:http/http.dart' as http;

// Future getUsers() async {
//   ApiResponse2 apiResponse2 = ApiResponse2();

//   try {
//     var token = '25|xpiP54l7QIdF2MWEh4NJGEN0BB1w59uGpRlA6PhV';
//     var url = Uri.parse(userUrl);
//     var response = await http.get(url, headers: {
//       'Accept': 'application/json',
//       'Authorization': 'Bearer $token'
//     });

//     switch (response.statusCode) {
//       case 200:
//         apiResponse2.data = User2.fromJson(jsonDecode(response.body));
//         break;
//       case 401:
//         apiResponse2.error = unauthorized;
//         break;

//       default:
//         apiResponse2.error = somethingWentWrong;
//     }
//   } catch (e) {
//     apiResponse2.error = serverError;
//   }
//   return apiResponse2;
// }

// strings
import 'package:flutter/material.dart';

// const baseUrl = 'http://127.0.0.1:8000/api'; // xampp local server ip
const baseUrl =
    'http://10.0.2.2:8000/api'; // bluestack local ip for xampp server
const loginUrl = baseUrl + '/login';
const registerUrl = baseUrl + '/register';
const logoutUrl = baseUrl + '/logout';
const userUrl = baseUrl + '/user';
const postUrl = baseUrl + '/posts';
const commentsUrl = baseUrl + '/comments';

// errors
const serverError = 'Server Error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';

// input decoration

InputDecoration kInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    contentPadding: const EdgeInsets.all(10),
    border: const OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Colors.black),
    ),
  );
}

// button

TextButton kTextButton(String label, Function() onPressed) {
  return TextButton(
    onPressed: onPressed,
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
    style: ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blue),
      padding: MaterialStateProperty.resolveWith(
        (states) => const EdgeInsets.symmetric(vertical: 10),
      ),
    ),
  );
}

// Login register hint

Row kLoginRegisterHint(String text, String label, Function() onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text),
      GestureDetector(
        child: Text(
          label,
          style: const TextStyle(color: Colors.blue),
        ),
        onTap: onTap,
      )
    ],
  );
}

// likes and comment button
Expanded kLikeAndComment(
    int value, IconData icon, Color color, Function() onTap) {
  return Expanded(
    child: Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text('$value'),
            ],
          ),
        ),
      ),
    ),
  );
}

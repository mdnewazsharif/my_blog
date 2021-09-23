import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/user.dart';
import 'package:blog/screens/Home.dart';
import 'package:blog/screens/register.dart';
import 'package:blog/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.error}'),
        ),
      );
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token ?? '');

    await prefs.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              TextFormField(
                controller: txtEmail,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Email is required'),
                  EmailValidator(errorText: 'Please enter a valid email')
                ]),
                keyboardType: TextInputType.emailAddress,
                decoration: kInputDecoration("Email"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: txtPassword,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Email is required'),
                  MinLengthValidator(6,
                      errorText: 'Password must be at lest 6 character long')
                ]),
                obscureText: true,
                decoration: kInputDecoration("Password"),
              ),
              const SizedBox(height: 10),
              loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    )
                  : kTextButton("Login", () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          _loginUser();
                        });
                      }
                    }),
              const SizedBox(height: 10),
              kLoginRegisterHint("Don't have an account? ", "Register Now", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Register(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

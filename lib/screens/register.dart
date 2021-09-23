import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/user.dart';
import 'package:blog/screens/home.dart';
import 'package:blog/screens/login.dart';
import 'package:blog/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController(),
      emailContoller = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController();

  void _registerUser() async {
    ApiResponse response = await register(
        nameController.text, emailContoller.text, passwordController.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = !loading;
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
                controller: nameController,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Name is required'),
                ]),
                keyboardType: TextInputType.streetAddress,
                decoration: kInputDecoration("Name"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailContoller,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Email is required'),
                  EmailValidator(errorText: 'Please enter a valid email')
                ]),
                keyboardType: TextInputType.emailAddress,
                decoration: kInputDecoration("Email"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Email is required'),
                  MinLengthValidator(6,
                      errorText: 'Password must be at lest 6 character long')
                ]),
                obscureText: true,
                decoration: kInputDecoration("Password"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordConfirmController,
                validator: (val) => val != passwordController.text
                    ? 'Confirm password not matched'
                    : null,
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
                          _registerUser();
                        });
                      }
                    }),
              const SizedBox(height: 10),
              kLoginRegisterHint("Already have an account? ", "Login Now", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Login(),
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

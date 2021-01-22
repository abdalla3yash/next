import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next/auth/login.dart';
import 'package:next/todo/home.dart';
import 'package:next/widget/const.dart';
import 'package:next/widget/textField.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  var _key = GlobalKey<FormState>();
  bool _autovalidation = false;
  bool _isLoading = false;
  String _error;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 150.0,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'NEXT',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Here To Help You',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Form(
                      autovalidate: _autovalidation,
                      key: _key,
                      child: Column(
                        children: <Widget>[
                          textFormField('Email', _emailController, false),
                          SizedBox(
                            height: 10,
                          ),
                          textFormField('Name', _nameController, false),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              contentPadding: const EdgeInsets.all(15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Password',
                            ),
                            obscureText: true,
                            controller: _passwordController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Password is required!!';
                              } else if (value.length < 6) {
                                return ' Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              contentPadding: const EdgeInsets.all(15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Confirm Password',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Confirmation is required!!';
                              } else if (value != _passwordController.text) {
                                return 'Passwords Not Match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            height: 50.0,
                            decoration: decoration,
                            width: double.infinity,
                            child: FlatButton(
                              onPressed: _onRegisterClick,
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          _errorMessage(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "have an account? ",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      FlatButton(
                        padding: const EdgeInsets.only(right: 30.0),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Text(
                          'Sign In',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                              fontSize: 17.0,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _errorMessage(BuildContext context) {
    if (_error == null) {
      return Container();
    }
    return Container(
      child: Text(
        _error,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  void _onRegisterClick() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autovalidation = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _autovalidation = false;
      });

      try {
        AuthResult result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: (_emailController.text).trim(),
                password: (_passwordController.text).trim());
        FirebaseUser user = result.user;
        await Firestore.instance
            .collection('profiles')
            .document()
            .setData({'name': _nameController.text, 'user_id': user.uid});

        if (user != null) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      } on PlatformException catch (e) {
        setState(() {
          print(e);
          _isLoading = false;
          if (e.code.toString() == "ERROR_NETWORK_REQUEST_FAILED") {
            setState(() {
              _error = 'Check Your Internet Connection.';
            });
          } else if (e.code.toString() == "ERROR_INVALID_EMAIL") {
            setState(() {
              _error = 'Invalid email, Try again with valid email.';
            });
          } else if (e.code.toString() == "ERROR_EMAIL_ALREADY_IN_USE") {
            setState(() {
              _error = 'This Email Is Already Exist!!';
            });
          } else {
            setState(() {
              _error = 'Something went wrong, Try again.';
            });
          }
        });
      }
    }
  }
}

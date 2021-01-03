import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:next/auth/login.dart';
import 'package:next/todo/home.dart';
import 'package:next/widget/const.dart';

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
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              contentPadding: const EdgeInsets.all(15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Email',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Email is required!!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              contentPadding: const EdgeInsets.all(15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Name',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Name is required!!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              contentPadding: const EdgeInsets.all(15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Password',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Password is required!!';
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

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((authResult) {
        Firestore.instance.collection('profiles').document().setData({
          'name': _nameController.text,
          'user_id': authResult.user.uid
        }).then((_) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }).catchError((error) {
          setState(() {
            _isLoading = false;
            _error = error.toString();
          });
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _error = error.toString();
        });
      });
    }
  }
}

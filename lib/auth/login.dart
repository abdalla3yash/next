import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:next/auth/register.dart';
import 'package:next/todo/home.dart';
import 'package:next/widget/const.dart';
import 'package:next/widget/textField.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  var _key = GlobalKey<FormState>();

  bool _autovalidation = false;
  bool _isLoading = false;
  String _error;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                      children: [
                        textFormField('Email', _emailController, false),
                        SizedBox(
                          height: 15,
                        ),
                        textFormField('Password', _passwordController, true),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          height: 50.0,
                          decoration: decoration,
                          width: double.infinity,
                          child: FlatButton(
                            onPressed: _onLoginClick,
                            child: Text(
                              'Login',
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
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 15.0),
                    ),
                    FlatButton(
                      padding: const EdgeInsets.only(right: 30.0),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => RegisterScreen()));
                      },
                      child: Text(
                        'Sign Up',
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
          ],
        ),
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

  void _onLoginClick() async {
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
        FirebaseUser user =
            (await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        ))
                .user;
        if (user != null) {
          _isLoading = false;
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
}

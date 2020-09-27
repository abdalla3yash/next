import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:next/auth/login.dart';
import 'package:next/todo/home.dart';

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
      appBar: AppBar(
        centerTitle: true,
        title: Text('Register'),
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          autovalidate: _autovalidation,
          key: _key,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Email'),
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
                decoration: InputDecoration(hintText: 'Name'),
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
                decoration: InputDecoration(hintText: 'Password'),
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
                decoration: InputDecoration(hintText: 'Confirm Password'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Confirmation is required!!';
                  }
                  return null;
                },
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: _onRegisterClick,
                  child: Text('Register'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _errorMessage(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("have an account?"),
                  SizedBox(
                    width: 20,
                  ),
                  FlatButton(
                    child: Text("Login"),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    },
                  )
                ],
              ),
            ],
          ),
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

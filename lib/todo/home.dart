import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:next/auth/login.dart';
import 'package:next/todo/new_todo.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseUser _user;
  bool _hasError = false;
  bool _isLoading = true;
  String _errorMessage;
  String _name;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('profiles')
          .where('user_id', isEqualTo: user.uid)
          .getDocuments()
          .then((snapShot) {
        setState(() {
          _name = snapShot.documents[0]['name'];
          _user = user;
          _hasError = false;
          _isLoading = false;
        });
      });
    }).catchError((error) {
      _hasError = true;
      _errorMessage = error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          title: _isLoading
              ? Text("Home")
              : (_hasError
                  ? _error(context, _errorMessage)
                  : Text(
                      _name,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    )),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () async {
                  try {
                    final result = await InternetAddress.lookup('google.com');
                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                      print('connected');
                      FirebaseAuth.instance.signOut().then((_) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      });
                    }
                  } on SocketException catch (_) {
                    print('not connected');
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Check Your Internet Connection"),
                    ));
                  }
                }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _newTodo,
          backgroundColor: Color(0xFFF4325C),
          child: Icon(Icons.add),
        ),
        body: Container(
            child: Stack(
          children: <Widget>[
            //stack overlaps widgets

            _isLoading
                ? _loading(context)
                : (_hasError
                    ? _error(context, _errorMessage)
                    : _content(context)),
          ],
        )));
  }

  void _newTodo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewTodo()));
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('todos')
              .orderBy('done', descending: false)
              .where('user_id', isEqualTo: _user.uid)
              .snapshots(),
          // ignore: missing_return
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return _error(context, 'No Connection is Made');
                break;
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return _error(context, snapshot.error.toString());
                }
                if (snapshot.hasData) {
                  if (snapshot.data.documents.length == 0) {
                    return Center(
                      child: Text(
                        'NO DATA FOUND!!!',
                        style:
                            TextStyle(color: Theme.of(context).disabledColor),
                      ),
                    );
                  }
                }
                return _drawScreen(context, snapshot.data);
                break;
            }
          }),
    );
  }

  Widget _error(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
      itemCount: data.documents.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          child: ListTile(
            leading: IconButton(
                icon: Icon(Icons.assignment_turned_in,
                    color: (data.documents[position]['done'] == true)
                        ? Colors.teal
                        : (data.documents[position]['done'] == false)
                            ? Colors.grey.shade400
                            : Colors.grey.shade400),
                onPressed: () {
                  if (data.documents[position]['done'] == false) {
                    Firestore.instance
                        .collection('todos')
                        .document(data.documents[position].documentID)
                        .updateData({'done': true});
                  } else if (data.documents[position]['done'] == true) {
                    Firestore.instance
                        .collection('todos')
                        .document(data.documents[position].documentID)
                        .updateData({'done': false});
                  }
                }),
            title: Text(
              data.documents[position]['body'],
              style: TextStyle(
                  decoration: data.documents[position]['done']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red.shade300,
                ),
                onPressed: () async {
                  try {
                    final result = await InternetAddress.lookup('google.com');
                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                      print('connected');
                      Firestore.instance
                          .collection('todos')
                          .document(data.documents[position].documentID)
                          .delete();
                    }
                  } on SocketException catch (_) {
                    print('not connected');
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Check Your Internet Connection"),
                    ));
                  }
                }),
          ),
        );
      },
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

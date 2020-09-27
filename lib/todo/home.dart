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
      appBar: AppBar(
        title: _isLoading
            ? Text("Home")
            : (_hasError ? _error(context, _errorMessage) : Text(_name)),
        centerTitle: true,
      ),
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          DrawerHeader(child: null),
          ListTile(
            title: Text('Log Out'),
            trailing: Icon(Icons.exit_to_app),
            onTap: () async {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              });
            },
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _newTodo,
        child: Icon(Icons.add),
      ),
      body: _isLoading
          ? _loading(context)
          : (_hasError ? _error(context, _errorMessage) : _content(context)),
    );
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
                if (!snapshot.hasData) {
                  return _error(context, 'no data');
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
        'ERROR',
        style: TextStyle(color: Colors.red),
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
                icon: Icon(
                  Icons.assignment_turned_in,
                  color: data.documents[position]['done']
                      ? Colors.teal
                      : Colors.grey.shade400,
                ),
                onPressed: () {
                  Firestore.instance
                      .collection('todos')
                      .document(data.documents[position].documentID)
                      .updateData({'done': true});
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
                onPressed: () {
                  Firestore.instance
                      .collection('todos')
                      .document(data.documents[position].documentID)
                      .delete();
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

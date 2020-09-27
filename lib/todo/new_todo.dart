import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewTodo extends StatefulWidget {
  @override
  _NewTodoState createState() => _NewTodoState();
}

class _NewTodoState extends State<NewTodo> {
  var _key = GlobalKey<FormState>();
  TextEditingController _todoController = TextEditingController();
  bool _autovalidation = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _todoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New ToDo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savetodo,
        child: Icon(Icons.save),
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          autovalidate: _autovalidation,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _todoController,
                decoration: InputDecoration(hintText: 'Enter Todo'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'todo text is required';
                  }
                  return null;
                },
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

  void _savetodo() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autovalidation = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });

      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance.collection('todos').document().setData({
          'body': _todoController.text,
          'done': false,
          'user_id': user.uid
        }).then((_) {
          Navigator.of(context).pop();
        });
      });
    }
  }
}

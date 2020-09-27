class Todo {
  String body;
  String user_id;
  bool done;

  Todo({this.body, this.user_id, this.done});

  Todo.fromJson(Map<String, dynamic> map) {
    this.body = map['body'];
    this.user_id = map['user_id'];
    this.done = map['done'];
  }

  Map<String, dynamic> toMap() {
    return {
      'body': this.body,
      'user_id': this.user_id,
      'done': this.done,
    };
  }
}

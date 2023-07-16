import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  bool isEdit = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : "Add Todo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                isEdit ? updateData() : submitData();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(isEdit ? "Update" : "Submit"),
              ))
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('Nothing to call update without todo data');
    }
    final id = todo!['_id'];
    final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    //http://api.nstack.in/v1/todos/64ae91cf9f18ae99c185a126

    //  submit Updated data to the server
    final url = "http://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      showSuccessMessage("Updation Success");
    } else {
      showErrorMessage("Updation Failed");
    }
  }

  Future<void> submitData() async {
    //  get te data from form
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    //  submit data to the server
    final url = "http://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    //  show success or fail msg on status
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';

      showSuccessMessage("Creation Success");
    } else {
      print("Error");
      showErrorMessage("Cretion Fsiled");
      print(response.body);
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
        content: Text(
      message,
      style: TextStyle(color: Colors.black),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

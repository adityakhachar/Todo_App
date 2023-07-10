import 'dart:convert';
import 'package:api_todo_app/Screens/add_page.dart';
import 'package:api_todo_app/Screens/add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'Edit') {
                      // Open edit Page
                    } else {
                      // Delete and refresh
                      DeleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text("Edit"),
                        value: 'Edit',
                      ),
                      PopupMenuItem(
                        child: Text("Delete"),
                        value: 'Delete',
                      )
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
      //////
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToaddPage();
        },
        label: Text("Add Todo"),
      ),
    );
  }

  void navigateToaddPage() {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    Navigator.push(context, route);
  }

  Future<void> DeleteById(String id) async {
    // Delete the item
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      //Remove item from the list
      final filered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filered;
      });
    } else {
      // Show error
      showErrorMessage("Deletion Failes");
    }
  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true;
    });
    final url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final Response = await http.get(uri);
    if (Response.statusCode == 200) {
      final json = jsonDecode(Response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {
      print("Error");
    }
    setState(() {
      isLoading = false;
    });
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

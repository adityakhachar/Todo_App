import 'dart:convert';
import 'dart:ui';
import 'package:api_todo_app/Screens/add_page.dart';
import 'package:api_todo_app/Screens/add_page.dart';
import 'package:api_todo_app/Services/Todo_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

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
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
                child: Text(
              "No Todo Item",
              style: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 40,
              ),
            )),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          // Open edit Page
                          navigateTOEditPage(item);
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
      //////
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //
          navigateToaddPage1();
        },
        label: Text("Add Todo"),
      ),
    );
  }

  Future<void> navigateToaddPage1() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });

    fetchTodo();
  }

  Future<void> navigateToaddPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });

    fetchTodo();
  }

  Future<void> navigateTOEditPage(Map item) async {
    final route = MaterialPageRoute(
        builder: (context) => AddTodoPage(
              todo: item,
            ));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });

    fetchTodo();
  }

  Future<void> DeleteById(String id) async {
    // // Delete the item
    // final url = 'http://api.nstack.in/v1/todos/$id';
    // final uri = Uri.parse(url);
    final isSuceess = await TodoServices.deleteByID(id);
    if (isSuceess) {
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
    // setState(() {
    //   isLoading = true;
    // });
    // final url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    // final uri = Uri.parse(url);
    // final Response = await http.get(uri);
    final response = await TodoServices.fetchToDos();

    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage("Something Went wrong");
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

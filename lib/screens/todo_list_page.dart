import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fecthTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Center(child: Text('Todo List')),
      ),
      body: Visibility(
        visible: isLoading,
        // Trong trường hợp isLoading = true sẽ hiện thị danh sách
        replacement: RefreshIndicator(
          onRefresh: fecthTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Open Edit Page
                        navigateToEditPage(item);
                      } else if (value == 'delete') {
                        // Delete and remove  the item
                        deleteById(id);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                );
              }),
        ),
        // Trong trường hợp isLoading = false sẽ hiện thị cái này
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: const Text('Add Todo')),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fecthTodo();
  }

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(builder: (context) => const AddPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fecthTodo();
  }

  // Delete Item
  Future<void> deleteById(String id) async {
    // Delete the item
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      // Remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      // Show Error
      showFailedMessage('Delete Failure');
    }
  }

  // Get API
  Future<void> fecthTodo() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    // Hiện rhij dữ liệu
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  // In ra thông báo khi xảy ra lỗi
  void showFailedMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

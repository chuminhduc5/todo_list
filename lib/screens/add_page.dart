import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({super.key, this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    // Kiểm tra việc cần làm có tồn tại hay không
    if (todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      desController.text = description;
    }else{

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit ? 'Edit Todo' : 'Add Todo'
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: desController,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Description',
            ),
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: isEdit ? updateData : submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                isEdit ? 'Update' : 'Submit',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  // Put
  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null){
      print('You can not call updates without todo data');
      return;
    }
    final id = todo['_id'];
    final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final desc = desController.text;
    final body = {
      "title": title,
      "description": desc,
      "is_completed": isCompleted,
    };

    // Submit update data to the server
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
        uri,
        // Nội dung body
        body: jsonEncode(body),
        // Khai báo loại dữ liệu bạn đang gửi
        headers: {'Content-Type': 'application/json'});

    // Show success or fail message based on status
    if (response.statusCode == 200) {
      print('Update Success');
      showSuccessMessage('Cập nhật thành công');
    } else {
      showFailedMessage('Thất bại');
    }
  }

  // Post
  Future<void> submitData() async {
    // Get the data from form
    final title = titleController.text;
    final desc = desController.text;
    final body = {
      "title": title,
      "description": desc,
      "is_completed": false,
    };

    // Submit data to the server
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        // Nội dung body
        body: jsonEncode(body),
        // Khai báo loại dữ liệu bạn đang gửi
        headers: {'Content-Type': 'application/json'});

    // Show success or fail message based on status
    if (response.statusCode == 201) {
      titleController.text = '';
      desController.text = '';
      print('Creation Success');
      showSuccessMessage('Thêm thành công');
    } else {
      showFailedMessage('Thất bại');
    }
  }

  // In ra thông báo thành cồng
  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

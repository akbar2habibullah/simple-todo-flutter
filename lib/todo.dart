import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final TextEditingController _textController = TextEditingController();
  List _todoList = [
    {'title': 'Example Task 1', 'finished': false},
    {'title': 'Example Task 2', 'finished': true},
    {'title': 'Example Task 3', 'finished': false},
  ];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Enter a new To-Do item'),
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todoList[index]['title']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _todoList[index]['finished'],
                        onChanged: (value) {
                          setState(() {
                            _todoList[index]['finished'] = value!;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _todoList.removeAt(index);
                          });
                        },
                      )
                    ],
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(
                            task: _todoList[index],
                            onEdited: (task) {
                              setState(() {
                                _todoList[index] = task;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoItem,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTodoItem() async {
    final response = await http.post(
      Uri.parse('https://65984b39668d248edf2468b1.mockapi.io/api/ToDo'),
      headers: {},
      body: json.encode({
        'title': _textController.text,
        'finished': false,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _isLoading = true;
      });

      final List newTodoList = [
        ..._todoList,
        {
          'title': _textController.text,
          'finished': false,
        }
      ];
      setState(() {
        _textController.clear();
        _todoList = newTodoList;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to add To-Do item');
    }
  }
}

class EditTaskScreen extends StatelessWidget {
  final Map<String, dynamic> task;
  final TextEditingController _textController = TextEditingController();
  final Function(Map<String, dynamic>) onEdited;

  EditTaskScreen({required this.task, required this.onEdited});

  @override
  Widget build(BuildContext context) {
    _textController.text = task['title'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              onEdited({
                'title': _textController.text,
                'finished': task['finished']
              });
              Navigator.pop(context, task);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          decoration: InputDecoration(labelText: 'Task Title'),
        ),
      ),
    );
  }
}

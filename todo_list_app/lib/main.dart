import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(TodoListApp());
}

class Todo {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  bool isDone;

  Todo({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.isDone = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isDone': isDone,
    };
  }
}

class TodoListApp extends StatefulWidget {
  @override
  _TodoListAppState createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  List<Todo> todos = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = prefs.getString('todos');
    if (todoListJson != null) {
      final todoList = jsonDecode(todoListJson) as List<dynamic>;
      setState(() {
        todos = todoList.map((json) => Todo.fromJson(json)).toList();
      });
    }
  }

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson =
        jsonEncode(todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', todoListJson);
  }

  void addTodo() {
    final name = nameController.text;
    final description = descriptionController.text;
    final newTodo = Todo(
      name: name,
      description: description,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 7)),
    );
    setState(() {
      todos.add(newTodo);
    });
    saveTodos();
    nameController.clear();
    descriptionController.clear();
  }

  void toggleTodoStatus(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
    });
    saveTodos();
  }

  void removeTodoItem(int index) {
    setState(() {
      todos.removeAt(index);
    });
    saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Todo List'),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: addTodo,
              child: Text('Add Todo'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  final formattedStartDate =
                      DateFormat.yMd().add_jm().format(todo.startDate);
                  final formattedEndDate =
                      DateFormat.yMd().add_jm().format(todo.endDate);

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(todo.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todo.description),
                          SizedBox(height: 5),
                          Text('Start Date: $formattedStartDate'),
                          Text('End Date: $formattedEndDate'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          removeTodoItem(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

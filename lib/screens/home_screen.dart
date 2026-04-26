import 'package:flutter/material.dart';
import 'package:todo_app_firebase/models/todo_model.dart';
import 'package:todo_app_firebase/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todos'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Action'),
                    content: Text('Are you sure you want to delete this item?'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context), // Closes the dialog
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add your logic here
                          Navigator.pop(context);
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.plus_one_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<TodoModel>>(
        future: firebaseService.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("There is issue in loading data..."));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: Icon(
                    todo.completed ? Icons.check_circle : Icons.circle_rounded,
                  ),
                );
              },
            );
          }
          return Center(child: Text('No todos yet'));
        },
      ),
    );
  }
}

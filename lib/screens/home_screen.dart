import 'package:flutter/material.dart';
import 'package:todo_app_firebase/models/todo_model.dart';
import 'package:todo_app_firebase/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firebaseService = FirebaseService();
  final taskName = TextEditingController();
  final taskDescription = TextEditingController();
  List<TodoModel> previousTodos = [];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  void _handleListChanges(List<TodoModel> newTodos) {
    // Compare old list with new list
    if (newTodos.length > previousTodos.length) {
      // NEW ITEM ADDED!
      int newIndex = newTodos.length - 1;
      _listKey.currentState?.insertItem(newIndex);
    }

    // Update previous list
    previousTodos = newTodos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('My Todos'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add TODO'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Todo Name"),
                        ),
                        TextField(
                          controller: taskName,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Enter about Todo'),
                        ),
                        TextField(
                          controller: taskDescription,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context), // Closes the dialog
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          var titleName = taskName.text;
                          var descriptionData = taskDescription.text;
                          if (titleName.isEmpty || descriptionData.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields!'),
                              ),
                            );
                            return;
                          }
                          final todoModel = TodoModel(
                            id: '',
                            title: titleName,
                            description: descriptionData,
                            completed: false,
                            createdAt: DateTime.now(),
                          );
                          firebaseService.addTodo(todoModel);

                          taskDescription.clear();
                          taskName.clear();

                          Navigator.pop(context);
                        },

                        child: Text('Confirm'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<TodoModel>>(
        stream: firebaseService.getTodosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("There is issue in loading data..."));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final todos = snapshot.data!;
            _handleListChanges(todos);
            return AnimatedList(
              key: _listKey, // ← We'll create this in a moment
              initialItemCount: todos.length,
              itemBuilder: (context, index, animation) {
                final todo = todos[index];
                return SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: Offset(0, -1),
                      end: Offset(0, 0),
                    ).chain(CurveTween(curve: Curves.easeOut)),
                  ),
                  child: ListTile(
                    title: Text(todo.title),
                    subtitle: Text(todo.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: todo.completed,
                          onChanged: (val) {
                            TodoModel updateTodo = TodoModel(
                              id: todo.id,
                              title: todo.title,
                              description: todo.description,
                              completed: !todo.completed,
                              createdAt: todo.createdAt,
                            );
                            firebaseService.updateTodo(updateTodo);
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            firebaseService.deleteTodo(todo.id);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
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

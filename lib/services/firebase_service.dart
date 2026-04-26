import 'package:todo_app_firebase/models/todo_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  Future<void> addTodo(TodoModel todo) async {
    try {
      await FirebaseFirestore.instance.collection('todos').add({
        'id': todo.id,
        'title': todo.title,
        'description': todo.description,
        'completed': todo.completed,
        'createdAt': todo.createdAt,
      });
    } catch (e) {
      print('Erroe adding: $e');
    }
  }

  Future<List<TodoModel>> getTodos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('todos')
          .get();

      return snapshot.docs
          .map((doc) => TodoModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error adding: $e');
      return [];
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(todo.id).update({
        'title': todo.title,
        'description': todo.description,
        'completed': todo.completed,
        'createdAt': todo.createdAt,
      });
    } catch (e) {
      print("Error in updating data: $e");
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(id).delete();
    } catch (e) {
      print("Error in deleting data: $e");
    }
  }
}

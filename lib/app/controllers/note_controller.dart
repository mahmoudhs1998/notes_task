import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:todotask/app/models/note.dart';

// Controllers
class NotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Note> notes = <Note>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearchActive = false.obs;
  final RxList<String> recentSearches = <String>[].obs;
  final String profilePictureUrl = 'https://th.bing.com/th/id/OIP.IGNf7GuQaCqz_RPq5wCkPgHaLH?w=115&h=180&c=7&r=0&o=5&pid=1.7'; // Placeholder for demo
  final selectedType = 'text'.obs;
  final todoItems = <TodoItem>[].obs;
  final selectedDateTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
    debounce(searchQuery, (_) => filterNotes(), time: const Duration(milliseconds: 300));
    fetchNotes();
  }

  void filterNotes() {
    // Filter notes based on the search query
    if (searchQuery.isEmpty) {
      filteredNotes.assignAll(notes);
    } else {
      filteredNotes.assignAll(
        notes.where((note) => note.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            note.content.toLowerCase().contains(searchQuery.value.toLowerCase()))
            .toList(),
      );
    }
  }

  void fetchNotes() {
    _firestore.collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      notes.value = snapshot.docs.map((doc) => Note.fromSnapshot(doc)).toList();
    });
  }

  List<Note> get filteredNotes {
    return searchQuery.isEmpty ? notes : notes.where((note) =>
    note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        note.content.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  void addToRecents(String query) {
    if (query.isNotEmpty && !recentSearches.contains(query)) {
      if (recentSearches.length >= 5) recentSearches.removeLast();
      recentSearches.insert(0, query);
    }
  }

  void clearRecents() {
    recentSearches.clear();
  }

  Future<void> addNote(String title, String content, String type) async {
    await _firestore.collection('notes').add({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
    });
  }
  Future<void> addNoteWithType(String title, dynamic content, String type, {List<TodoItem>? todoItems, EventDetails? eventDetails}) async {
    final noteData = {
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
    };

    if (todoItems != null) {
      noteData['todoItems'] = todoItems.map((item) => item.toMap()).toList();
    }

    if (eventDetails != null) {
      noteData['eventDetails'] = eventDetails.toMap();
    }

    await _firestore.collection('notes').add(noteData);
  }

  // New methods for managing todos in notes
  void toggleTodoItemInNote(String noteId, int todoIndex) {
    final noteIndex = notes.indexWhere((note) => note.id == noteId);
    if (noteIndex != -1) {
      Note note = notes[noteIndex];
      if (note.type == 'todo' && note.todoItems != null) {
        note.todoItems![todoIndex].isChecked = !note.todoItems![todoIndex].isChecked;

        // Create a new note instance to trigger reactive update
        notes[noteIndex] = Note(
          id: note.id,
          title: note.title,
          content: note.content,
          type: note.type,
          todoItems: note.todoItems,
          eventDetails: note.eventDetails,
          timestamp: note.timestamp,
        );
      }
    }
  }

  // Optional: Add method to get completion status
  String getTodoCompletion(String noteId) {
    final note = notes.firstWhere((note) => note.id == noteId);
    if (note.todoItems == null || note.todoItems!.isEmpty) return '0/0';

    final completed = note.todoItems!.where((item) => item.isChecked).length;
    return '$completed/${note.todoItems!.length}';
  }

  void toggleTodoItem(int index) {
    todoItems[index].isChecked = !todoItems[index].isChecked;
    todoItems.refresh();
  }

  void removeTodoItem(int index) {
    todoItems.removeAt(index);
  }

  void addTodoItem(String text) {
    todoItems.add(TodoItem(text: text));
  }

  void setDateTime(DateTime dateTime) {
    selectedDateTime.value = dateTime;
  }
  Future<void> updateNote(String id, String title, String content) async {
    await _firestore.collection('notes').doc(id).update({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }

}

// class NotesController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final RxList<Note> notes = <Note>[].obs;
//   final RxString searchQuery = ''.obs;
//   final RxBool isSearching = false.obs;
//   final RxBool isSearchActive = false.obs;
//   final RxList<String> recentSearches = <String>[].obs;
//
//   // Add profile picture URL - in a real app, this would come from user authentication
//   final String profilePictureUrl = 'https://th.bing.com/th/id/OIP.IGNf7GuQaCqz_RPq5wCkPgHaLH?w=115&h=180&c=7&r=0&o=5&pid=1.7'; // Placeholder for demo
//
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchNotes();
//   }
//   NotesController() {
//     debounce(searchQuery, (_) => filterNotes(), time: const Duration(milliseconds: 300));
//   }
//
//
//   void filterNotes() {
//     if (searchQuery.isEmpty) {
//       filteredNotes.assignAll(notes);
//     } else {
//       filteredNotes.assignAll(
//         notes.where((notes) =>
//             notes.title.toLowerCase().contains(searchQuery.value.toLowerCase())),
//       );
//     }
//   }
//
//
//   void fetchNotes() {
//     _firestore.collection('notes')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .listen((snapshot) {
//       notes.value = snapshot.docs.map((doc) => Note.fromSnapshot(doc)).toList();
//     });
//   }
//
//   Future<void> addNote(String title, String content, String type) async {
//     await _firestore.collection('notes').add({
//       'title': title,
//       'content': content,
//       'timestamp': FieldValue.serverTimestamp(),
//       'type': type,
//     });
//   }
//
//   Future<void> updateNote(String id, String title, String content) async {
//     await _firestore.collection('notes').doc(id).update({
//       'title': title,
//       'content': content,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<void> deleteNote(String id) async {
//     await _firestore.collection('notes').doc(id).delete();
//   }

//   List<Note> get filteredNotes {
//     return searchQuery.isEmpty
//         ? notes
//         : notes.where((note) =>
//     note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
//         note.content.toLowerCase().contains(searchQuery.toLowerCase()))
//         .toList();
//   }
//   void addToRecents(String query) {
//     if (query.isNotEmpty && !recentSearches.contains(query)) {
//       if (recentSearches.length >= 5) recentSearches.removeLast();
//       recentSearches.insert(0, query);
//     }
//   }
//
//   void clearRecents() {
//     recentSearches.clear();
//   }
// }
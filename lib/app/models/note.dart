
// Models
import 'package:cloud_firestore/cloud_firestore.dart';

// First, let's update the Note model to support different types
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String type; // 'text', 'todo', 'event', 'list'
  final List<TodoItem>? todoItems;
  final EventDetails? eventDetails;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.type,
    this.todoItems,
    this.eventDetails,
  });

  factory Note.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Note(
      id: snap.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] ?? 'text',
      todoItems: data['todoItems'] != null
          ? List<TodoItem>.from(
          (data['todoItems'] as List).map((item) => TodoItem.fromMap(item)))
          : null,
      eventDetails: data['eventDetails'] != null
          ? EventDetails.fromMap(data['eventDetails'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'todoItems': todoItems?.map((item) => item.toMap()).toList(),
      'eventDetails': eventDetails?.toMap(),
    };
  }
}

class TodoItem {
  final String text;
  bool isChecked;

  TodoItem({required this.text, this.isChecked = false});

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      text: map['text'] ?? '',
      isChecked: map['isChecked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isChecked': isChecked,
    };
  }
}

class EventDetails {
  final String title;
  final DateTime time;
  final String? icon;
  final String? phoneNumber;

  EventDetails({
    required this.title,
    required this.time,
    this.icon,
    this.phoneNumber,
  });

  factory EventDetails.fromMap(Map<String, dynamic> map) {
    return EventDetails(
      title: map['title'] ?? '',
      time: (map['time'] as Timestamp).toDate(),
      icon: map['icon'],
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': Timestamp.fromDate(time),
      'icon': icon,
      'phoneNumber': phoneNumber,
    };
  }
}
// class Note {
//   final String id;
//   final String title;
//   final String content;
//   final DateTime timestamp;
//   final String type; // 'text', 'image', 'drawing', 'link'
//
//   Note({
//     required this.id,
//     required this.title,
//     required this.content,
//     required this.timestamp,
//     required this.type,
//   });
//
//   factory Note.fromSnapshot(DocumentSnapshot snap) {
//     final data = snap.data() as Map<String, dynamic>;
//     return Note(
//       id: snap.id,
//       title: data['title'] ?? '',
//       content: data['content'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp).toDate(),
//       type: data['type'] ?? 'text',
//     );
//   }
// }
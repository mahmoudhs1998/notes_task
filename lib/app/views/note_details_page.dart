import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todotask/app/controllers/note_controller.dart';
import 'package:todotask/app/models/note.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final NotesController controller = Get.find();

  NoteDetailPage({required this.note}) {
    titleController.text = note.title;
    contentController.text = note.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              Get.defaultDialog(
                title: 'Delete Note',
                middleText: 'Are you sure you want to delete this note?',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  controller.deleteNote(note.id);
                  Get.back();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
              ),
            ),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Note content',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.updateNote(
            note.id,
            titleController.text,
            contentController.text,

          );
          Get.back();
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

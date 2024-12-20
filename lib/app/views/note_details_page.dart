import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todotask/app/controllers/note_controller.dart';
import 'package:todotask/app/models/note.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final phoneController = TextEditingController();
  final NotesController controller = Get.find();

  NoteDetailPage({required this.note}) {
    titleController.text = note.title;
    contentController.text = note.content;
    if (note.type == 'event' && note.eventDetails != null) {
      phoneController.text = note.eventDetails!.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
              ),
            ),
            const Divider(),
            Expanded(
              child: _buildContentByType(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveNote(),
        child: const Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildContentByType() {
    switch (note.type) {
      case 'todo':
        return _buildTodoContent();
      case 'event':
        return _buildEventContent();
      default:
        return _buildTextContent();
    }
  }

  Widget _buildTextContent() {
    return TextField(
      controller: contentController,
      maxLines: null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Note content',
      ),
    );
  }

  Widget _buildTodoContent() {
    return Obx(() {
      // Initialize controller's todoItems with note's items if not already set
      if (controller.todoItems.isEmpty && note.todoItems != null) {
        controller.todoItems.assignAll(note.todoItems!);
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: controller.todoItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: controller.todoItems[index].isChecked,
                    onChanged: (value) {
                      controller.toggleTodoItem(index);
                    },
                  ),
                  title: Text(controller.todoItems[index].text),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.removeTodoItem(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: 'Add new item',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (contentController.text.isNotEmpty) {
                      controller.addTodoItem(contentController.text);
                      contentController.clear();
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.addTodoItem(value);
                  contentController.clear();
                }
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEventContent() {
    // Initialize controller's datetime with note's datetime if not already set
    if (controller.selectedDateTime.value == null && note.eventDetails != null) {
      controller.setDateTime(note.eventDetails!.time);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
              () => ListTile(
            leading: const Icon(Icons.event),
            title: Text(
              controller.selectedDateTime.value != null
                  ? DateFormat('MMM d, y ・ h:mm a')
                  .format(controller.selectedDateTime.value!)
                  : 'Select date and time',
            ),
            onTap: () => _selectDateTime(Get.context!),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.phone),
          title: TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Phone number (optional)',
            ),
            keyboardType: TextInputType.phone,
          ),
        ),
        const Divider(),
        Expanded(
          child: TextField(
            controller: contentController,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Additional notes',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateTime.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          controller.selectedDateTime.value ?? DateTime.now(),
        ),
      );

      if (time != null) {
        controller.setDateTime(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
      }
    }
  }

  void _saveNote() {
    switch (note.type) {
      case 'todo':
        controller.updateNote(
          note.id,
          titleController.text,
          '',
          todoItems: controller.todoItems,
        );
        break;
      case 'event':
        if (controller.selectedDateTime.value != null) {
          final eventDetails = EventDetails(
            title: titleController.text,
            time: controller.selectedDateTime.value!,
            phoneNumber: phoneController.text,
            icon: note.eventDetails?.icon ?? 'phone',
          );
          controller.updateNote(
            note.id,
            titleController.text,
            contentController.text,
            eventDetails: eventDetails,
          );
        }
        break;
      default:
        controller.updateNote(
          note.id,
          titleController.text,
          contentController.text,
        );
    }
    Get.back();
  }

  void _showDeleteConfirmation() {
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
  }
}
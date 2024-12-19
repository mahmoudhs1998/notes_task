import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todotask/app/controllers/note_controller.dart';
import 'package:todotask/app/models/note.dart';

class AddNotePage extends StatelessWidget {
  AddNotePage({super.key});

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final phoneController = TextEditingController();
  final NotesController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetX<NotesController>(
      init: controller,
      builder: (controller) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'New Note',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (type) {
                controller.selectedType.value = type;
                if (type == 'todo') {
                  controller.todoItems.clear();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'text',
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 20),
                      SizedBox(width: 8),
                      Text('Text Note'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'todo',
                  child: Row(
                    children: [
                      Icon(Icons.check_box, size: 20),
                      SizedBox(width: 8),
                      Text('Todo List'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'event',
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 20),
                      SizedBox(width: 8),
                      Text('Event/Call'),
                    ],
                  ),
                ),
              ],
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
                child: _buildContentSection(controller),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _saveNote(controller),
          child: const Icon(Icons.save),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildContentSection(NotesController controller) {
    switch (controller.selectedType.value) {
      case 'todo':
        return _buildTodoSection(controller);
      case 'event':
        return _buildEventSection(controller);
      default:
        return TextField(
          controller: contentController,
          maxLines: null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Note content',
          ),
        );
    }
  }

  Widget _buildTodoSection(NotesController controller) {
    return Column(
      children: [
        Expanded(
          child: Obx(
                () => ListView.builder(
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEventSection(NotesController controller) {
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
            onTap: () async {
              final date = await showDatePicker(
                context: Get.context!,
                initialDate: controller.selectedDateTime.value ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: Get.context!,
                  initialTime: TimeOfDay.now(),
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
            },
          ),
        ),
        if (controller.selectedDateTime.value != null) ...[
          const Divider(),
          ListTile(
            trailing: const Icon(Icons.phone),
            title: TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Phone number (optional)',
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
        const Divider(thickness: 1),
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

  void _saveNote(NotesController controller) {
    if (titleController.text.isEmpty &&
        (controller.selectedType.value != 'todo' ||
            controller.todoItems.isEmpty)) {
      Get.snackbar('Error', 'Please enter a title or add items');
      return;
    }

    switch (controller.selectedType.value) {
      case 'todo':
        if (controller.todoItems.isNotEmpty) {
          controller.addNoteWithType(
            titleController.text,
            '',
            'todo',
            todoItems: controller.todoItems,
          );
        }
        break;
      case 'event':
        if (controller.selectedDateTime.value != null) {
          controller.addNoteWithType(
            titleController.text,
            contentController.text,
            'event',
            eventDetails: EventDetails(
              title: titleController.text,
              time: controller.selectedDateTime.value!,
              phoneNumber: phoneController.text,
              icon: 'phone',
            ),
          );
        }
        break;
      default:
        controller.addNoteWithType(
          titleController.text,
          contentController.text,
          'text',
        );
    }

    Get.back();
  }
}




// class AddNotePage extends StatelessWidget {
//   final titleController = TextEditingController();
//   final contentController = TextEditingController();
//   final NotesController controller = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.close, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'New Note',
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: titleController,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Title',
//               ),
//             ),
//             Expanded(
//               child: TextField(
//                 controller: contentController,
//                 maxLines: null,
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   hintText: 'Note content',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (titleController.text.isNotEmpty || contentController.text.isNotEmpty) {
//             controller.addNote(
//               titleController.text,
//               contentController.text,
//               'text',
//             );
//             Get.back();
//           }
//         },
//         child: Icon(Icons.save),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }

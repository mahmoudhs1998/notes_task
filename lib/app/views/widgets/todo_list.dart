import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todotask/app/controllers/note_controller.dart';
import 'package:todotask/app/models/note.dart';

class TodoNote extends StatelessWidget {
  final String title;
  final List<TodoItem> todoItems;
  final String id;
  final NotesController controller;
  final VoidCallback? onTap;

  const TodoNote({
    Key? key,
    required this.title,
    required this.todoItems,
    required this.id,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Obx(
                    () => Column(
                  children: todoItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: item.isChecked,
                            onChanged: (bool? value) {
                              controller.toggleTodoItemInNote(id, index);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.text,
                            style: TextStyle(
                              decoration: item.isChecked
                                  ? TextDecoration.lineThrough
                                  : null,
                              color:
                              item.isChecked ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
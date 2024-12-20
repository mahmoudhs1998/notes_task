import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todotask/app/controllers/note_controller.dart';
import 'package:todotask/app/models/note.dart';
import 'package:todotask/app/views/add_note.dart';
import 'package:todotask/app/views/note_details_page.dart';





class NotesHomePages extends StatelessWidget {
  final NotesController controller = Get.put(NotesController());
  final searchController = TextEditingController();

  NotesHomePages({super.key});

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        // First check if search is active
        if (controller.isSearchActive.value) {
          _handleSearchToggle(); // Close search instead of exiting
          return false; // Prevent app exit
        }
        return true; // Allow app exit if search is not active
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16,),
                    Expanded(child: _buildNotesList()),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.clearAddNoteForm();
            Get.to(() => AddNotePage());
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }


  Widget _buildSearchBar() {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: controller.isSearchActive.value ? 400 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(controller.isSearchActive.value ? 20 : 30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: controller.isSearchActive.value ? 0 : 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: Icon(
                      controller.isSearchActive.value ? Icons.arrow_back : Icons.search,
                      color: Colors.grey,
                    ),
                    onPressed: _handleSearchToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onTap: () {
                      if (!controller.isSearchActive.value) {
                        controller.isSearchActive.value = true;
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search notes',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                      if (value.trim().isNotEmpty) {
                        controller.filterNotes();
                      } else {
                        controller.resetSearch();
                      }
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.addToRecents(value);
                        controller.isSearchActive.value = false;
                      }
                    },
                  ),
                ),
                if (controller.searchQuery.isNotEmpty)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                        controller.searchQuery.value = '';
                        controller.resetSearch();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                const SizedBox(width: 8),
                // Mic Icon
                if (controller.isSearchActive.value)
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.grey),
                    onPressed: () {
                      // Implement voice search functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                // Profile Picture
                if (!controller.isSearchActive.value)
                  CircleAvatar(
                    backgroundImage: NetworkImage(controller.profilePictureUrl),
                    radius: 16,
                  ),
              ],
            ),
            if (controller.isSearchActive.value) ...[
              const Divider(thickness: 1, height: 50),
              _buildSearchOverlay(),
            ],
          ],
        ),
      ),
    ));
  }
  void _handleSearchToggle() {
    if (controller.isSearchActive.value) {
      controller.isSearchActive.value = false;
      searchController.clear();
      controller.searchQuery.value = '';
      controller.resetSearch();
    } else {
      controller.isSearchActive.value = true;
    }
  }




  Widget _buildSearchOverlay() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildTypeFilters(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.recentSearches.isNotEmpty)
                  TextButton(
                    onPressed: () => controller.clearRecents(),
                    child: const Text('Clear all'),
                  ),
              ],
            ),
          ),
          _buildRecentSearches(),
        ],
      );
    });
  }

  Widget _buildTypeFilters() {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the Row
        children: [
          _buildFilterButton('Images', Icons.image),
          const SizedBox(width: 16), // Space between buttons
          _buildFilterButton('Drawings', Icons.edit),
          const SizedBox(width: 16), // Space between buttons
          _buildFilterButton('Links', Icons.link),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon) {
    return InkWell(
      onTap: () {
        controller.filterNotesByType(label.toLowerCase());
        searchController.text = label;
        controller.searchQuery.value = label;
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey[600], size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Obx(() => Column(
      children: controller.recentSearches.map((search) => ListTile(
        leading: const Icon(Icons.history),
        title: Text(search),
        onTap: () {
          searchController.text = search;
          controller.searchQuery.value = search;
          controller.filterNotes();
        },
      )).toList(),
    ));
  }


  Widget _buildNotesList() {
    return Obx(() => GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _getChildAspectRatio(controller.filteredNotes),
      ),
      itemCount: controller.filteredNotes.length,
      itemBuilder: (context, index) {
        final note = controller.filteredNotes[index];

        return _buildNoteCard(note);
      },
    ));
  }


// Enhanced method to calculate dynamic aspect ratio
  double _getChildAspectRatio(List<Note> notes) {
    // Calculate a base ratio for the grid items
    double baseRatio = 0.85;

    // Loop through notes to get the best dynamic ratio
    for (var note in notes) {
      double titleLengthFactor = note.title.length / 30; // Based on title length
      double contentLengthFactor = note.content.length / 100; // Based on content length

      // Adjust aspect ratio based on title length
      if (note.title.length > 50) {
        baseRatio += 0.05; // Increase the ratio for longer titles
      }

      // Adjust aspect ratio based on content length
      if (note.content.length > 100) {
        baseRatio += 0.1; // Increase ratio more for longer content
      } else if (note.content.length > 50) {
        baseRatio += 0.05; // Moderate increase for medium-length content
      }

      // Apply final dynamic ratio adjustment based on both title and content
      baseRatio += titleLengthFactor * 0.05 + contentLengthFactor * 0.1;
    }

    // Ensure the ratio stays within reasonable bounds to prevent extreme aspect ratios
    baseRatio = baseRatio.clamp(0.7, 1.2); // Clamp between 0.7 and 1.2

    return baseRatio;
  }

  // Update the note card widget to handle different types
  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () => Get.to(() => NoteDetailPage(note: note)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getNoteColor(note.type),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildNoteContent(note),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(note.timestamp),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteContent(Note note) {
    switch (note.type) {
      case 'todo':
        return _buildTodoContent(note.todoItems ?? []);
      case 'event':
        return _buildEventContent(note.eventDetails!);
      default:
        return Text(
          note.content,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 5,
        );
    }
  }

  Widget _buildTodoContent(List<TodoItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.take(4).map((item) {
        return Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: item.isChecked,
                onChanged: null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 14,
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  color: item.isChecked ? Colors.grey : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEventContent(EventDetails event) {
    return Row(
      children: [
        Icon(
          Icons.phone,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateFormat('MMM d, h:mm a').format(event.time),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Update the color function
  Color _getNoteColor(String type) {
    switch (type) {
      case 'todo':
        return Colors.green[100]!;
      case 'event':
        return Colors.purple[100]!;
      case 'list':
        return Colors.orange[100]!;
      default:
        return Colors.blue[100]!;
    }
  }


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


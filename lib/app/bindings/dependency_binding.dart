import 'package:get/get.dart';
import 'package:todotask/app/controllers/note_controller.dart';

class DependencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotesController>(() => NotesController());
  }
}

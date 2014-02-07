import 'dart:html';
import 'task.dart';

void main() {
  querySelector("#add_task_form").onSubmit.listen(createTask);
  (querySelector("#add_task_button") as ButtonElement).text = addBtnText;

  loadStorageTasks();
}


import 'dart:html';
import 'dart:convert';
import 'dart:async' show StreamSubscription;

List<Task> Tasks = new List();
int idNum = 1;
bool editMode = false;
Task activeTask;
String storageKey = 'tasks',
    addBtnText = 'Create task',
    editBtnText = 'Save task',
    completeTitle = 'Complete task',
    editText = 'Edit',
    deleteText = 'Delete';

/**
 * Task class
 */
class Task {
  int _id = idNum;
  String desc = null;
  bool completed = false;
  Element _elem = new LIElement(),
      _editElem = new ButtonElement(),
      _deleteElem = new ButtonElement();
  StreamSubscription _completeClickSubscr,
      _editClickSubscr,
      _deleteClickSubscr;

  Task(String description, [bool completed]) {
    this.desc = description;
    if (completed != null) this.completed = completed;
    idNum++;

    this._completeClickSubscr = this._elem.onClick.listen((MouseEvent event) {
      this.isCompleted ? this.reOpen() : this.complete();
      refreshList();
    });
    this._editClickSubscr = this._editElem.onClick.listen(edit);
    this._deleteClickSubscr = this._deleteElem.onClick.listen((MouseEvent event) {
      this.destroy();
      event.preventDefault();
      event.stopPropagation();
    });

    this._elem.title = completeTitle;
    this._editElem.text = _editElem.title = editText;
    this._deleteElem.text = _deleteElem.title = deleteText;
    this._editElem.className = _deleteElem.className = 'task-buttons';
  }
  
  void complete() {
    this.completed = true;
  }
  
  void reOpen() {
    this.completed = false;
  }
  
  void destroy() {
    this._completeClickSubscr.cancel();
    this._editClickSubscr.cancel();
    this._deleteClickSubscr.cancel();
    removeTaskElement(this);
    Tasks.remove(this);
  }

  void edit(MouseEvent event) {
    editMode = true;
    activeTask = this;
    (querySelector("#add_task_button") as ButtonElement).text = editBtnText;
    (querySelector("#new_task_text") as InputElement)
      ..value = this.description
      ..focus();
    event.preventDefault();
    event.stopPropagation();
  }
  
  void saveDesc(String desc) {
    this.desc = desc;
    activeTask = null;
    (querySelector("#add_task_button") as ButtonElement).text = addBtnText;
    refreshList();
  }
  
  Element get getElement => _elem;
  Element get getEditElement => _editElem;
  Element get getDeleteElement => _deleteElem;
  String get description => desc;
  bool get isCompleted => completed;  
  int get id => _id;
}


void main() {
  querySelector("#add_task_form").onSubmit.listen(createTask);
  (querySelector("#add_task_button") as ButtonElement).text = addBtnText;

  loadStorageTasks();
}


/**
 * Refreshes list of all tasks and their state
 */
void refreshList() {
  Element list = querySelector("#all_tasks");

  int i = Tasks.length-1;
  for (; i >= 0; i--) {
    Task me = Tasks[i];
    String idBadge = me.id.toString();
    String css = me.isCompleted ? 'todo-item-completed' : '';
    Element item = me.getElement;
    Element editBtn = me.getEditElement;
    Element deleteBtn = me.getDeleteElement;

    item.className = "todo-item $css";
    if (item.id.isEmpty) item.id = "todo-item-$idBadge";
    if (item.text.isEmpty || item.text != me.description) item.text = me.description;
    if (item.children.indexOf(editBtn) == -1) item.children.add(editBtn);
    if (item.children.indexOf(deleteBtn) == -1) item.children.add(deleteBtn);

    if (list.children.indexOf(item) == -1) list.children.insert(0,item);
  }

  saveToStorage();
}


/**
 * removes task element from the wrapper
 */
void removeTaskElement(Task task) {
  Element list = querySelector("#all_tasks");
  String idBadge = task.id.toString();

  int i = 0, length = list.children.length;
  Element child;
  for (; i < length; i++) {
    child = list.children[i];
    if (child.id == "todo-item-$idBadge") {
      list.children.removeAt(i);
      return;
    }
  }
}


/**
 * Returns task by given id
 */
Task getTask(int id) {
  int i = 0, len = Tasks.length;
  for(; i< len; i++) {
    if (Tasks[i].id == id) {
      return Tasks[i];
    }
  }
  throw new StateError('Task with given ID does not exist');
}


/**
 * fetches saved data from localstorage
 */
void loadStorageTasks() {
  String storage = window.localStorage[storageKey];
  List items = new List();

  if (storage.isNotEmpty) {
    items = JSON.decode(storage);
  }

  int i = 0, length = items.length;
  for(; i<length; i++) {
    Map item = items[i];
    Tasks.add(new Task(item['description'], item['completed'] == "true"));
  }
  refreshList();
}


/**
 * saves current data into storage
 */
void saveToStorage() {
  int i = 0, len = Tasks.length;
  List data = new List();

  for(; i<len; i++) {
    Task it = Tasks[i];
    String _desc = it.description;
    bool _completed = it.isCompleted;
    data.add('{"description": "$_desc", "completed": "$_completed"}');
  }
  
  window.localStorage[storageKey] = "["+ data.join(",") +"]";
}


/**
 * Creates task when the button is clicked
 */
void createTask(Event event) {
  InputElement input = querySelector("#new_task_text");
  String text = input.value;

  if (editMode) {
    activeTask.saveDesc(text);
  } else {
    Tasks.add(new Task(text));
  }
  refreshList();
  input.value = null;

  event.preventDefault();
  event.stopPropagation();
}

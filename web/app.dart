import 'dart:html';
import 'dart:convert';
import 'dart:async' show StreamSubscription;

List<Task> Tasks = new List();
int idNum = 1;
String storageKey = 'tasks';

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

  Task(String description) {
    desc = description;
    idNum++;

    _completeClickSubscr = _elem.onClick.listen((MouseEvent event) {
      isCompleted ? reOpen() : complete();
      refreshList();
    });
    _editClickSubscr = _editElem.onClick.listen(edit);
    _deleteClickSubscr = _deleteElem.onClick.listen((MouseEvent event) {
      destroy();
      event.preventDefault();
      event.stopPropagation();
      refreshList();
    });

    _elem.title = 'Complete task';
    _editElem.text = _editElem.title = 'Edit';
    _deleteElem.text = _deleteElem.title = 'Delete';
    _editElem.className = _deleteElem.className = 'task-buttons';
  }
  
  void complete() {
    completed = true;
  }
  
  void reOpen() {
    completed = false;
  }
  
  void destroy() {
    _completeClickSubscr.cancel();
    _editClickSubscr.cancel();
    _deleteClickSubscr.cancel();
    Tasks.remove(this);
  }

  void edit(MouseEvent event) {
    //(querySelector("#new_task_text") as InputElement).value = this.description;
    event.preventDefault();
    event.stopPropagation();
  }
  
  //TODO edit task
  
  Element get getElement => _elem;
  Element get getEditElement => _editElem;
  Element get getDeleteElement => _deleteElem;
  String get description => desc;
  bool get isCompleted => completed;  
  int get id => _id;
}


void main() {
  querySelector("#add_task").text = "Create item";
  querySelector("#add_task_form").onSubmit.listen(createTask);
  
//  loadStorageTasks();
//  window.localStorage[storageKey] = '';
}


/**
 * Refreshes list of all tasks and their state
 */
void refreshList() {
  Element list = querySelector("#all_tasks");
  
  //TODO do not clear, only refresh ?
  list.children.clear();
  
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

//    if (list.children.indexOf(item) == -1) list.children.insert(0,item);
    list.children.add(item);
  }

  //TODO localStorage saving
//  saveToStorage();
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
  
  print(storage);
  if (storage.isNotEmpty) {
    print(JSON.decode(storage));
//    items = JSON.decode(storage); 
  }
  
//  print(items);
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
  
//  print(data.join(","));
  window.localStorage[storageKey] = data.join(",");
}


/**
 * Creates task when the button is clicked
 */
void createTask(Event event) {
  InputElement input = querySelector("#new_task_text");
  String text = input.value;

  Tasks.add(new Task(text));
  refreshList();
  input.value = null;

  event.preventDefault();
  event.stopPropagation();
}

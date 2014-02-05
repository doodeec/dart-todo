import 'dart:html';
import 'dart:core';
import 'dart:convert';

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
  Element _elem = new LIElement();
  var _subscr = null;
  
  Task(String description) {
    desc = description;
    idNum++;
    
    _subscr = _elem.onClick.listen((MouseEvent event) {
      isCompleted ? destroy() : complete();
      refreshList();
    });
  }
  
  void complete() {
    completed = true;
  }
  
  void reOpen() {
    completed = false;
  }
  
  void destroy() {
    _subscr.cancel();
    Tasks.remove(this);
  }
  
  //TODO edit task
  
  Element get getElement => _elem;
  String get description => desc;
  bool get isCompleted => completed;  
  int get id => _id;
}


void main() {
  querySelector("#add_task")
    ..text = "Create item"
    ..onClick.listen(createTask);
  
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
    
    item.className = "todo-item $css";
    if (item.id.isEmpty) item.id = "todo-item-$idBadge";
    if (item.text.isEmpty || item.text != me.description) item.text = me.description;
    //TODO buttons edit/delete/complete
    
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
    //TODO throws error when there are multiple objects in storage
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
void createTask(MouseEvent event) {
  String text = (querySelector("#new_task_text") as InputElement).value;

  Tasks.add(new Task(text));
  refreshList();
}

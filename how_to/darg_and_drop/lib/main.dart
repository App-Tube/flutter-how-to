import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag & Drop Demo',
      // 1. Changed the theme to dark
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          background: const Color.fromARGB(255, 39, 39, 39),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Drag & Drop Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 2. Defined variables to hold all tasks and stored them in a map which key is the task status
  // and a scroll controller so we can scroll horizontaly the list once we start dragging
  final _tasks = <TaskStatus, List<Task>>{};
  final ScrollController _mainListScrollController = ScrollController();

  // 3. helper variables for storing the total number of tasks created, a timer so we can cancel the scroll controller
  // move once the item is in the center, and a bool to hold if the user dragge to right or left
  int _counter = 0;
  Timer? _timer;
  bool? _lastMoveRight;

  @override
  void initState() {
    // 4. initialising the map for the task statuses and adding an empty list
    TaskStatus.values.forEach((status) {
      _tasks[status] = <Task>[];
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                controller: _mainListScrollController,
                slivers: [
                  ...TaskStatus.values.map(
                    (status) => SliverToBoxAdapter(
                      child: RowStatusCard(
                        tasks: _tasks[status] ?? [],
                        taskStatus: status,
                        screenSize: screenSize,
                        taskAccepted: (task, newStatus) {
                          _tasks[task.status]?.remove(task);
                          _tasks[newStatus]?.add(
                            Task(title: task.title, status: newStatus),
                          );
                          setState(() {});
                        },
                        onDrag: (isRight) {
                          if (_lastMoveRight == isRight) {
                            return;
                          }

                          _lastMoveRight = isRight;
                          _moveMainList(isRight);
                        },
                        cancelDrag: () {
                          _lastMoveRight = null;
                          _timer?.cancel();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 5. Creating a new task in the todo column and increasing the counter
          _tasks[TaskStatus.todo]
              ?.add(Task(title: "To Do $_counter", status: TaskStatus.todo));
          _counter++;
          setState(() {});
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _moveMainList(bool isRight) {
    _timer?.cancel();

    _timer = Timer(Duration(milliseconds: 100), () {
      if (_mainListScrollController.offset <= 20 && !isRight) {
        _timer?.cancel();
        return;
      }

      if (_mainListScrollController.offset >
          (_mainListScrollController.position.maxScrollExtent)) {
        _timer?.cancel();
        return;
      }

      _mainListScrollController.animateTo(
        _mainListScrollController.offset + (isRight ? 50 : -50),
        duration: Duration(milliseconds: 50),
        curve: Curves.easeIn,
      );

      _moveMainList(isRight);
    });
  }
}

// 6. Created a widget that will display a full height card for each task status and displaying all tasks
// in a list view
class RowStatusCard extends StatelessWidget {
  final void Function(Task task, TaskStatus newStatus) taskAccepted;
  final void Function(bool isRight) onDrag;
  final void Function() cancelDrag;

  final TaskStatus taskStatus;
  final List<Task> tasks;
  final Size screenSize;

  const RowStatusCard({
    required this.tasks,
    required this.taskStatus,
    required this.screenSize,
    required this.taskAccepted,
    required this.onDrag,
    required this.cancelDrag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.height * 0.8,
      width: screenSize.width * 0.8,
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            taskStatus.displayTitle,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 2,
              color: Colors.black38,
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              builder: (BuildContext context, List<Task?> candidateData,
                  List<dynamic> rejectedData) {
                return ListStatusColumnWidget(
                  tasks: tasks,
                  taskStatus: taskStatus,
                  screenSize: screenSize,
                  onDrag: onDrag,
                  cancelDrag: cancelDrag,
                );
              },
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                taskAccepted(details.data, taskStatus);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 7. Created a ListView that shows the tasks
class ListStatusColumnWidget extends StatelessWidget {
  final void Function(bool isRight) onDrag;
  final void Function() cancelDrag;

  final TaskStatus taskStatus;
  final List<Task> tasks;
  final Size screenSize;

  const ListStatusColumnWidget({
    required this.tasks,
    required this.taskStatus,
    required this.screenSize,
    required this.onDrag,
    required this.cancelDrag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(border: Border.all()),
          child: Center(
            child: Text(
              "Drag a task here",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Draggable<Task>(
            data: tasks[index],
            dragAnchorStrategy: (draggable, context, position) {
              return pointerDragAnchorStrategy(draggable, context, position);
            },
            onDragUpdate: (details) {
              print("onDragUpdate: ${details.globalPosition}");
              if (details.globalPosition.dx > screenSize.width * 0.8) {
                onDrag(true);
              } else if (details.globalPosition.dx < screenSize.width * 0.2) {
                onDrag(false);
              } else {
                cancelDrag();
              }
            },
            onDragEnd: (_) => cancelDrag(),
            onDragCompleted: () => cancelDrag(),
            onDraggableCanceled: (velocity, offset) => cancelDrag(),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: TaskWidget(
                task: tasks[index],
                backgroundColor: tasks[index].status.backgroundColor,
              ),
            ),
            feedback: TaskWidget(
              task: tasks[index],
              backgroundColor: tasks[index].status.backgroundColor,
            ),
            child: TaskWidget(
              task: tasks[index],
              backgroundColor: tasks[index].status.backgroundColor,
            ),
          ),
        );
      },
      itemCount: tasks.length,
    );
  }
}

// 8. Created a simple task widge which looks like a card with title
class TaskWidget extends StatelessWidget {
  final Task task;
  final Color backgroundColor;

  const TaskWidget({
    required this.task,
    required this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// 9. Created a data class for holding informations about the task
class Task {
  final String title;
  final TaskStatus status;

  Task({
    required this.title,
    required this.status,
  });
}

// 10. Created an enum for statuses that will represent the columns in which we can drag the tasks
enum TaskStatus {
  todo("To Do", Colors.black),
  inprogress("In Progress", Colors.blue),
  inreview("In Review", Colors.orange),
  done("Done", Colors.green);

  const TaskStatus(
    this.displayTitle,
    this.backgroundColor,
  );

  final String displayTitle;
  final Color backgroundColor;
}

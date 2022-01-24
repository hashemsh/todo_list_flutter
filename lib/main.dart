import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list_flutter/data.dart';
import 'package:todo_list_flutter/edit.dart';

const taskBoxName = 'task';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskEntityAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEntity>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: primaryVariantColor),
  );
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794CFF);
const Color primaryVariantColor = Color(0xff5C0AFF);
const secondaryTextColor = Color(0xffAFBED0);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xff1D2830);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            headline6: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: secondaryTextColor),
          iconColor: secondaryTextColor,
          border: InputBorder.none,
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          primaryVariant: primaryVariantColor,
          background: Color(0xffF3F5F8),
          onSurface: primaryTextColor,
          onPrimary: Colors.white,
          onBackground: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEntity>(taskBoxName);
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(
                task: TaskEntity(),
              ),
            ),
          );
        },
        label: Row(
          children: const [
            Text('add new task'),
            SizedBox(
              width: 8,
            ),
            Icon(CupertinoIcons.add_circled)
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeData.colorScheme.primary,
                    themeData.colorScheme.primaryVariant,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ToDo List',
                          style: themeData.textTheme.headline6!
                              .apply(color: themeData.colorScheme.onPrimary),
                        ),
                        Icon(
                          CupertinoIcons.share,
                          color: themeData.colorScheme.onPrimary,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.search),
                          label: Text('Search task ... '),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<TaskEntity>>(
                valueListenable: box.listenable(),
                builder: (context, box, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: box.values.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today',
                                  style: themeData.textTheme.headline6!
                                      .apply(fontSizeFactor: 0.8),
                                ),
                                Container(
                                  width: 60,
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                )
                              ],
                            ),
                            MaterialButton(
                              color: const Color(0xffEAEFF5),
                              textColor: secondaryTextColor,
                              elevation: 0,
                              onPressed: () {},
                              child: Row(
                                children: const [
                                  Text('Delete All'),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Icon(
                                    CupertinoIcons.delete_solid,
                                    size: 18,
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      } else {
                        final TaskEntity task = box.values.toList()[index - 1];
                        return TaskItem(task: task);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  final TaskEntity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: () {
        setState(() {
          widget.task.isCompleted = !widget.task.isCompleted;
        });
      },
      child: Container(
        height: 84,
        padding: const EdgeInsets.only(left: 16, right: 16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.colorScheme.surface,
        ),
        child: Row(
          children: [
            MyCheckBox(value: widget.task.isCompleted),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 24,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;

  const MyCheckBox({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: !value ? Border.all(color: secondaryTextColor, width: 2) : null,
        color: value ? primaryColor : null,
      ),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              color: themeData.colorScheme.onPrimary,
              size: 14,
            )
          : null,
    );
  }
}

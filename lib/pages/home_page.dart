import 'package:fitlog/components/heat_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/workout_data.dart';
import 'workout_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<WorkoutData>(context, listen: false).initializeWorkoutList();
  }

  //text controller
  final newWorkoutNameController = TextEditingController();
  //create a new workout
  void createNewWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create a new Workout"),
        content: TextField(
          controller: newWorkoutNameController,
        ),
        actions: [
          // Save Button
          MaterialButton(
            onPressed: save,
            child: const Text("Save"),
          ),
          MaterialButton(
            onPressed: cancel,
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // go to workout page
  void goTotWorkoutPage(String workoutName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutPage(
            workoutName: workoutName,
          ),
        ));
  }

// save workout
  void save() {
    // get workout name from text controller
    String newWorkoutName = newWorkoutNameController.text;
    // add workout to workoutdata list
    Provider.of<WorkoutData>(context, listen: false).addWorkout(newWorkoutName);

    //pop dialog box
    Navigator.pop(context);
    clear();
  }

// cancel workout
  void cancel() {
    //pop dialog box
    Navigator.pop(context);
    clear();
  }

  void clear() {
    newWorkoutNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[500],
        appBar: AppBar(
          title: const Text('Fitlog'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewWorkout,
          child: const Icon(Icons.add),
        ),
        body: ListView(
          children: [
            // Heat Map
            MyHeatMap(
                datasets: value.heatMapDataSet,
                startDateYYYYMMDD: value.getStartDate()),
            // Workout List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.getWorkoutList().length,
              itemBuilder: (context, index) => ListTile(
                title: Text(value.getWorkoutList()[index].name),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () =>
                      goTotWorkoutPage(value.getWorkoutList()[index].name),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

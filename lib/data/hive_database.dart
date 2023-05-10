// ignore_for_file: avoid_print

import 'package:fitlog/datetime/date_time.dart';
import 'package:fitlog/models/exercise.dart';
import 'package:fitlog/models/workout.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  // reference our hive box
  final _myBox = Hive.box("workout_database");

  // check if there is already data stored, if not, record the start date
  bool previousDataExists() {
    if (_myBox.isEmpty) {
      print("previous data does not exist");
      _myBox.put("START_DATE_", todaysDateYYYYMMDD());
      return false;
    } else {
      print("previous data does exist");
      return true;
    }
  }

  // return start date as yyyy/mm/dd
  String getStartDate() {
    return _myBox.get("START_DATE");
  }

  // write data
  void saveToDatabase(List<Workout> workouts) {
    //convert workout objects into lists of strings so that we can save in hive
    final workoutList = convertObjectToWorkoutList(workouts);
    final exerciseList = covertObjectToExerciseList(workouts);

    /* 

    check if any exercises have been done 
    we will put a 0 or 1 for each yyyymmdd

    */

    if (exerciseCompleted(workouts)) {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 1);
    } else {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 0);
    }

    // save into hive
    _myBox.put("WORKOUTS", workoutList);
    _myBox.put("EXERCISES", exerciseList);
  }

  // read data amd return a list of workout
  List<Workout> readFromDatabase() {
    List<Workout> mySavedWorkouts = [];

    List<String> workoutNames = _myBox.get("WORKOUTS");
    final exerciseDetails = _myBox.get("EXERCISES");

    // create workout objects
    for (int i = 0; i < workoutNames.length; i++) {
      // each workout can have multiple exercises
      List<Exercise> exercisesInEachWorkout = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        // so add each exercise into a list
        exercisesInEachWorkout.add(
          Exercise(
            name: exerciseDetails[i][j][0],
            weight: exerciseDetails[i][j][1],
            reps: exerciseDetails[i][j][2],
            sets: exerciseDetails[i][j][3],
            isCompleted: exerciseDetails[i][j][4] == "true" ? true : false,
          ),
        );
      }
      // create individual workout
      Workout workout =
          Workout(name: workoutNames[i], exercises: exercisesInEachWorkout);

      // add individual workout to overall list
      mySavedWorkouts.add(workout);
    }
    return mySavedWorkouts;
  }

  // check if any exercise have been done
  bool exerciseCompleted(List<Workout> workouts) {
    // go thru each workout
    for (var workout in workouts) {
      // go thru each exercise in workout
      for (var exercise in workout.exercises) {
        if (exercise.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  // return completion status of a given date yyyy/mm/dd
  int getCompletionStatus(String yyyymmdd) {
    // return 0 or 1, if null then return 0
    int completionStatus = _myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }
}

// converts workout objects into a list -> eg. [upperbody, lowerbody]
List<String> convertObjectToWorkoutList(List<Workout> workouts) {
  List<String> workoutList = [
    // eg. [upperbody, lowerbody]
  ];

  for (int i = 0; i < workouts.length; i++) {
    // in each workout, add the name, followed by lists of the exercises
    workoutList.add(
      workouts[i].name,
    );
  }
  return workoutList;
}
// converts the exercises in a workout object into a list of strings

List<List<List<String>>> covertObjectToExerciseList(List<Workout> workouts) {
  List<List<List<String>>> exerciseList = [
    /*
        [

          Upper Body
          [ [biceps, 10kg, 10 reps, 3 sets], [triceps, 20kg, 10 reps, 3 sets] ],

          Lower Body
          [ [squats, 10kg, 10 reps, 3 sets], [calf, 20kg, 10 reps, 3 sets] ],

        ]
    */
  ];

  // go through each workout
  for (int i = 0; i < workouts.length; i++) {
    // get exercises from each workout
    List<Exercise> exercisesInWorkout = workouts[i].exercises;

    List<List<String>> individualWorkout = [
      // Upper Body
      // [ [biceps, 10kg, 10 reps, 3 sets], [triceps, 20kg, 10 reps, 3 sets] ],
    ];
    // go through each exercise in the exercise list
    for (int j = 0; j < exercisesInWorkout.length; j++) {
      List<String> individualExercise = [];
      individualExercise.addAll(
        [
          exercisesInWorkout[j].name,
          exercisesInWorkout[j].weight,
          exercisesInWorkout[j].reps,
          exercisesInWorkout[j].sets,
          exercisesInWorkout[j].isCompleted.toString(),
        ],
      );
      individualWorkout.add(individualExercise);
    }
    exerciseList.add(individualWorkout);
  }

  return exerciseList;
}

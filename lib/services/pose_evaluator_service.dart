import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/material.dart';

import '../evaluators/evaluator_base.dart';
import '../evaluators/seatedlegraiseevaluator.dart';
import '../evaluators/standingkneeflexionevaluator.dart';
import '../evaluators/sidelegraiseevaluator.dart';
import '../evaluators/heelraiseevaluator.dart';
import '../evaluators/shoulderrollsevaluator.dart';
import '../evaluators/shouldershrugevaluator.dart';
import '../evaluators/wallslideevaluator.dart';
import '../evaluators/shoulderabductionevaluator.dart';
import '../evaluators/armcirclesevaluator.dart';
import '../evaluators/elbowflexionevaluator.dart';
import '../evaluators/armextensionforwardevaluator.dart';
import '../evaluators/wallpushupevaluator.dart';
import '../evaluators/placeholder_evaluator.dart';


class PoseEvaluatorService {
  static final Map<String, PoseEvaluator> _evaluators = {
    'Arm Extension Forward': ArmExtensionForwardEvaluator(),
    'Shoulder Shrug': ShoulderShrugEvaluator(),
    'Shoulder Abduction': ShoulderAbductionEvaluator(),
    'Wall Push-Up': WallPushUpEvaluator(),

    'Shoulder Rolls': PlaceholderEvaluator('Shoulder Rolls'),
    'Arm Circles': PlaceholderEvaluator('Arm Circles'),
    'Elbow Flexion': PlaceholderEvaluator('Elbow Flexion'),
    'Wall Slide': PlaceholderEvaluator('Wall Slide'),
    'Side Leg Raise': PlaceholderEvaluator('Side Leg Raise'),
    'Seated Leg Raise': PlaceholderEvaluator('Seated Leg Raise'),
    'Standing Knee Flexion': PlaceholderEvaluator('Standing Knee Flexion'),
    'Heel Raise': PlaceholderEvaluator('Heel Raise'),
  };

  static PoseEvaluator? getEvaluatorByName(String name) {
    return _evaluators[name];
  }
}

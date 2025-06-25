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

class PoseEvaluatorService {
  static final Map<String, PoseEvaluator> _evaluators = {
    'Seated Leg Raise': SeatedLegRaiseEvaluator(),
    'Standing Knee Flexion': StandingKneeFlexionEvaluator(),
    'Side Leg Raise': SideLegRaiseEvaluator(),
    'Heel Raise': HeelRaiseEvaluator(),
    'Shoulder Rolls': ShoulderRollsEvaluator(),
    'Shoulder Shrug': ShoulderShrugEvaluator(),
    'Wall Slide': WallSlideEvaluator(),
    'Shoulder Abduction': ShoulderAbductionEvaluator(),
    'Arm Circles': ArmCirclesEvaluator(),
    'Elbow Flexion': ElbowFlexionEvaluator(),
    'Arm Extension Forward': ArmExtensionForwardEvaluator(),
    'Wall Push-Up': WallPushUpEvaluator(),
  };

  static PoseEvaluator? getEvaluatorByName(String name) {
    return _evaluators[name];
  }
}

import 'package:rive/rive.dart';

class ViewModelInstanceBindings {
  final ViewModelInstanceString buttonText;
  final ViewModelInstanceString buttonStatus;
  final ViewModelInstanceTrigger buttonTrigger;
  final ViewModelInstanceString outputText;
  final ViewModelInstanceString timerText;
  final ViewModelInstanceString scoreText;
  final ViewModelInstanceString roundText;
  final List<ViewModelInstanceAssetImage> cellImages;
  final List<ViewModelInstanceString> cellStatuses;
  final List<ViewModelInstanceString> skips;

  ViewModelInstanceBindings({
    required this.buttonText,
    required this.buttonStatus,
    required this.buttonTrigger,
    required this.outputText,
    required this.timerText,
    required this.scoreText,
    required this.roundText,
    required this.cellImages,
    required this.cellStatuses,
    required this.skips,
  });
}

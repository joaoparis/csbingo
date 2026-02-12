import 'package:rive/rive.dart';

class RiveBindings {
  final ViewModelInstanceString buttonText;
  final ViewModelInstanceString buttonStatus;
  final ViewModelInstanceTrigger buttonTrigger;
  final ViewModelInstanceTrigger cursorTrigger;
  final ViewModelInstanceString outputText;
  final ViewModelInstanceString outputTextInfo;
  final ViewModelInstanceString timerText;
  final ViewModelInstanceString scoreText;
  final ViewModelInstanceString roundText;
  final ViewModelInstanceString maxRoundText;
  final List<ViewModelInstanceAssetImage> cellImages;
  final List<ViewModelInstanceString> cellStatuses;
  final List<ViewModelInstanceString> cellsText;
  final List<ViewModelInstanceString> cellsAnswers;
  final List<ViewModelInstanceTrigger> cellTaps;
  final List<ViewModelInstanceBoolean> cellIsLoading;
  final List<ViewModelInstanceNumber> cellLoad;
  final List<ViewModelInstanceString> skips;
  final ViewModelInstanceString secondOutputTitleText;
  final ViewModelInstanceString secondOutputBodyText;
  final ViewModelInstanceTrigger secondOutputLoadingTrigger;
  final ViewModelInstanceTrigger secondOutputEmptyTrigger;
  final ViewModelInstanceTrigger secondOutputTextTrigger;

  RiveBindings({
    required this.buttonText,
    required this.buttonStatus,
    required this.buttonTrigger,
    required this.cursorTrigger,
    required this.outputText,
    required this.outputTextInfo,
    required this.timerText,
    required this.scoreText,
    required this.roundText,
    required this.maxRoundText,
    required this.cellImages,
    required this.cellStatuses,
    required this.cellsText,
    required this.cellsAnswers,
    required this.cellTaps,
    required this.cellIsLoading,
    required this.cellLoad,
    required this.skips,
    required this.secondOutputTitleText,
    required this.secondOutputBodyText,
    required this.secondOutputLoadingTrigger,
    required this.secondOutputEmptyTrigger,
    required this.secondOutputTextTrigger,
  });
}

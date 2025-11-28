import 'package:rive/rive.dart';

class RiveCell {
  final ViewModelInstanceAssetImage imageViewModel;
  final ViewModelInstanceString status;
  final ViewModelInstanceString text;
  final ViewModelInstanceTrigger tap;
  RiveCell(
    this.imageViewModel,
    this.status,
    this.text,
    this.tap,
  );
}

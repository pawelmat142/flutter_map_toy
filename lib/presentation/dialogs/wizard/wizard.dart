import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/presentation/dialogs/wizard/wizard_state.dart';
import 'package:flutter_map_toy/services/log.dart';

abstract class Wizard<T> {

  T? data;
  BuildContext? ctx;
  late Function(T?) onComplete;

  WizardCubit get cubit => BlocProvider.of<WizardCubit>(ctx!);

  List<WizardStep> getSteps() {
    throw 'Not implemented!';
  }

  T dataBuilder() {
    throw 'Not implemented!';
  }

  dataCompleter() {
    throw 'Not implemented!';
  }

  run(BuildContext ctx) {
    this.ctx = ctx;
    data = dataBuilder();
    _initialize();
    _start().then((x) {
      dataCompleter();
      onComplete(data);
      _stop();
      _clear(ctx);
    });
  }

  _initialize() {
    BlocProvider.of<WizardCubit>(ctx!).initialize(getSteps());
  }

  _clear(BuildContext context) {
    return BlocProvider.of<WizardCubit>(context).clear();
  }

  _start() {
    return cubit.start(ctx: ctx!);
  }

  _stop() async {
    ctx = null;
    data = null;
    Log.log('STOP!', source: runtimeType.toString());
  }
}

class WizardStep<T> {

  final int index;
  final Widget Function(BuildContext) builder;
  T? stepData;

  // final Function(T)? onSuccess;
  // final VoidCallback? onStart;
  // final VoidCallback? onStop;
  // final Function(T?)? onBack;

  bool isActive(BuildContext context) {
    return BlocProvider.of<WizardCubit>(context).state.currentIndex == index;
  }

  WizardStep({
    required this.index,
    required this.builder,
    required this.stepData,

    // this.onSuccess,
    // this.onStart,
    // this.onStop,
    // this.onBack,
  });


  //means that step is filled with data
  bool get ready => stepData is T;

}

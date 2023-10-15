import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'wizard_progress.dart';
import 'wizard_state.dart';
import 'wizard_theme.dart';

abstract class Wizard<T> {

  T? data;
  BuildContext? ctx;
  late Function(T) onComplete;

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

  WizardTheme getTheme() {
    throw 'Not implemented!';
  }

  run(BuildContext ctx) {
    this.ctx = ctx;
    data = dataBuilder();
    _initialize();
    _start().then((x) {
      dataCompleter();
      if (data != null) {
        onComplete(data as T);
      }
      _stop();
      _clear(ctx);
    });
  }

  _initialize() {
    BlocProvider.of<WizardCubit>(ctx!).initialize(getSteps(), getTheme());
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
  }
}

class WizardContent extends StatelessWidget {

  final WizardState state;

  const WizardContent(this.state,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(state.theme!.padding, 0, state.theme!.padding, state.theme!.padding),
        decoration: BoxDecoration(
          color: state.theme!.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(state.theme!.radius)),
        ),
        child: Column(
          children: [
            WizardProgress(state: state),
            state.step.builder(state.ctx!)
          ],
        ),
      ),
    );
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



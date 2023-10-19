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

  List<WizardStep> getSteps();

  T dataBuilder(T? edit);

  dataCompleter();

  WizardTheme getTheme();

  Widget getSubmitButton();

  run(BuildContext ctx, { T? edit }) {
    this.ctx = ctx;
    data = dataBuilder(edit);
    _initialize();
    _start().then((x) {
      dataCompleter();
      if (data != null && cubit.state.completed) {
        onComplete(data as T);
      }
      _stop();
      _clear(ctx);
    });
  }

  _initialize() {
    BlocProvider.of<WizardCubit>(ctx!).initialize(getSteps(), getTheme(), getSubmitButton());
  }

  _clear(BuildContext context) {
    return BlocProvider.of<WizardCubit>(context).clear();
  }

  _start() {
    return cubit.start(ctx: ctx!, nextIndex: _getIndexOfFirstIncompleteStep());
  }

  _getIndexOfFirstIncompleteStep() {
    final i = cubit.state.steps.indexWhere((step) => !step.ready);
    return i == -1 ? cubit.state.steps.length-1 : i;
  }

  _stop() async {
    ctx = null;
    data = null;
  }
}

class WizardContent extends StatelessWidget {

  const WizardContent({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WizardCubit, WizardState>(
      builder: (ctx, state) {
        if (!state.indexOk) return const SizedBox.shrink();
        return IntrinsicHeight(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(state.theme!.padding, 0, state.theme!.padding, state.theme!.padding),
            decoration: BoxDecoration(
              color: state.theme!.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(state.theme!.radius)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WizardProgress(state: state),
                state.step.builder(state.ctx!),
                if (state.completed) Padding(
                  padding: EdgeInsets.only(top: state.theme!.padding/2),
                  child: state.submitButton,
                )
              ],
            ),
          ),
        );
      }
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



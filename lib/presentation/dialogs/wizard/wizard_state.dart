import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'wizard.dart';
import 'wizard_theme.dart';

enum BlocWizardState {
  empty,
  ready,
  pending,
  progress,
  completed
}

class WizardState {

  BlocWizardState state;
  List<WizardStep> steps;
  int currentIndex;
  BuildContext? ctx;
  WizardTheme? theme;

  WizardState(this.state,
    this.steps,
    this.currentIndex,
    this.ctx,
    this.theme,
  );

  bool get initialized => steps.isNotEmpty && state != BlocWizardState.empty;
  bool get opened => initialized && ctx is BuildContext;
  bool get indexOk => currentIndex > 0 && currentIndex <= steps.length-1;

  WizardStep get step => steps[currentIndex];

  WizardState copyWith({
    BlocWizardState? state,
    List<WizardStep>? steps,
    int? currentIndex,
    BuildContext? ctx,
    bool cleanCtx = false,
    WizardTheme? theme,
  }) {
    return WizardState(
      state ?? this.state,
      steps ?? this.steps,
      currentIndex ?? this.currentIndex,
      cleanCtx ? null : ctx ?? this.ctx,
      theme ?? this.theme,
    );
  }
}

class WizardCubit extends Cubit<WizardState> {

  WizardCubit(): super(WizardState(BlocWizardState.empty, [], -1, null, null));

  initialize<T>(List<WizardStep> steps, WizardTheme theme) {
    _validateIndexes(steps);
    emit(state.copyWith(
      state: BlocWizardState.ready,
      steps: steps,
      theme: theme
    ));
  }

  clear() {
    emit(state.copyWith(
      state: BlocWizardState.empty,
      steps: [],
      currentIndex: -1,
      theme: null
    ));
  }

  _validateIndexes(List<WizardStep> steps) {
    final indexes = steps.map((step) => step.index);
    final set = indexes.toSet();
    if (set.length != steps.length) throw 'step indexes error!, $indexes';
  }

  start({ required BuildContext ctx, int nextIndex = 0 }) {
    if (!state.initialized) throw 'wizard is not initialized!';
    if (state.opened) throw 'wizard already opened';
    emit(state.copyWith(
        state: BlocWizardState.progress,
        currentIndex: nextIndex,
        ctx: ctx
    ));
    return _progressStep(ctx);
  }

  _progressStep(BuildContext ctx) {
    return showModalBottomSheet(
        context: state.ctx!,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => WizardContent(state)
    ).then((result) => _stepFinished(result));
  }

  finishStep(WizardStepResult result) {
    if (!state.opened) throw 'wizard is not opened!';
    state.step.stepData = result.data;
    Navigator.pop(state.ctx!, result); //triggers stepFinished
  }

  _stepFinished<T>(WizardStepResult<T>? result) {
    final step = state.step;
    final ctx = state.ctx!;
    _stop();
    if (result == null) return;
    if (step.ready && result.goForward) {
      if (step != state.steps.last) {
        return start(ctx: ctx, nextIndex: step.index+1);
      } else {
        return _wizardCompleted();
      }
    }
    if (!result.goForward) {
      return start(ctx: ctx, nextIndex: result.indexTo);
    }
  }

  _wizardCompleted() {
    emit(state.copyWith(
      state: BlocWizardState.completed,
      cleanCtx: true,
      ctx: null,
    ));
  }

  _stop() {
    if (!state.initialized) throw 'wizard is not initialized!';
    emit(state.copyWith(
        state: BlocWizardState.ready,
        currentIndex: -1,
        ctx: null,
        cleanCtx: true,
        steps: state.steps
    ));
  }

  onStepTap<T>(WizardStep<T> step) {
    if (_canGoToStep(step.index)) {
      finishStep(WizardStepResult<T>(state.step.stepData,
        goForward: false,
        indexTo: step.index
      ));
    }
  }

  bool _canGoToStep(int indexTo) {
    if (indexTo > state.steps.length-1 || indexTo < 0) return false;
    return state.steps
        .where((step) => step.index < indexTo)
        .every((step) => step.ready);
  }

  emitStepData<T>(T data) {
    state.step.stepData = data;
    emit(state.copyWith(
      steps: state.steps
    ));
  }

}

class WizardStepResult<T> {
  T data;
  bool goForward;
  int indexTo;

  WizardStepResult(this.data, {
    this.goForward = true,
    this.indexTo = 0
  });
}
import 'package:flutter_map_toy/presentation/dialogs/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/services/log.dart';

typedef BoolFunction = bool Function();

class ModalStepsWizard<T> {

  final BuildContext wizardContext;
  late List<WizardStep> steps;
  VoidCallback? onWizardFinish;

  ModalStepsWizard({
    required this.wizardContext,
    this.onWizardFinish
  }) {
    initSteps();
  }

  initSteps() {
    throw 'Not implemented!';
  }

  bool get complete => throw 'Not implemented!';

  int get lastStepIndex => steps.length-1;

  int currentIndex = -1;

  start(BuildContext context) async {
    _reset();
    final firstNotReadyStepIndex = steps.indexWhere((step) => step.ready);
    currentIndex = firstNotReadyStepIndex == -1 ? 0 : firstNotReadyStepIndex;
    _progressCurrentStep();
    // return steps[currentIndex].start();
  }

  _progressCurrentStep() async {
    _validateIndex(currentIndex);
    _activateCurrentStep();
    final currentStep = steps[currentIndex];

    final isStepCompleted = await currentStep._progress();

    if (isStepCompleted && !currentStep.isLastStep) {
      currentIndex++;
      return _progressCurrentStep();
    } else {
      _wizardFinished();
    }
  }

  _activateCurrentStep() {
    for (var step in steps) {
      step._active = step.index == currentIndex;
    }
  }

  _deactivateSteps() {
    for (var step in steps) {
      step._active = false;
    }
  }

  _wizardFinished() {
    _deactivateSteps();
    print('WizardFinished!!');
  }

  _reset() {
    for (var step in steps) {
      step._resetDirty();
    }
  }

  Future<void> _switchStep(int index) {
    _validateIndex(index);
    return steps[index].start();
  }

  Future<void> _nextStepOrFinish(WizardStep previousStep) {
    final previousStepIndex = previousStep.index;
    if (previousStep.index < lastStepIndex) {
      return _switchStep(previousStepIndex + 1);
    }
    Log.log('Wizard finished', source: runtimeType.toString());
    return Future(() => null);
  }

  _validateIndex(int index) {
    if (index <= lastStepIndex && index > -1) return;
    throw 'Index $index not permitted!';
  }

}

typedef WizardStepBuilder = Widget Function(BuildContext);

class WizardStep<T> {

  final T? _dataReference;
  final ModalStepsWizard parentWizard;
  final String label;
  final WizardStepBuilder builder;
  final Function(T) onSuccess;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  bool _active = false;
  bool _dirty = false;

  WizardStep(this._dataReference, {
    required this.parentWizard,
    required this.label,
    required this.builder,
    required this.onSuccess,
    this.onStart,
    this.onStop,
  });

  List<WizardStep<dynamic>> get steps => parentWizard.steps;

  //currently displayed step - should be only one active step per wizard
  bool get active => _active;

  bool get dirty => _dirty;

  //means that step is filled with property
  bool get ready => _dataReference is T;

  //means that every step before is ready
  bool get enabled => steps.every((step) => step.index < index ? step.ready : true);

  //means that step is finished with null by back
  bool backed = false;

  int get index => steps.indexWhere(_isMe);

  bool get isLastStep => parentWizard.steps.length -1 == index;

  _setDirty() => _dirty = true;

  _resetDirty() => _dirty = false;


  bool _isMe(WizardStep step) => step.label == label;

  //this method triggers open this step model
  Future<bool> start() async {
    Log.log('Start step $index', source: runtimeType.toString());
    if (onStart != null) onStart!();
    _setDirty();

    final T? result = await AppModal.show<T>(parentWizard.wizardContext, showBack: false, children: [
      WizardProgress(wizard: parentWizard),
      builder(parentWizard.wizardContext),
    ]);
    if (result is T) {
      onSuccess(result);
      return true;
    } else {
      return false;
    }
    if (onStop != null) onStop!();
    return false;
  }

  Future<bool> _progress() {
    return Future<bool>(() async {
      if (onStart != null) onStart!();
      _setDirty();

      final T? result = await AppModal.show<T>(parentWizard.wizardContext, showBack: false, children: [
        WizardProgress(wizard: parentWizard),
        builder(parentWizard.wizardContext),
      ]);

      if (result is T) {
        onSuccess(result);
        return true;
      } else {
        return false;
      }
    });
  }

}

class WizardProgress extends StatelessWidget {

  static const double _stepWidth = 24;
  static const double _stepActiveWidth = 34;

  final ModalStepsWizard wizard;
  final Color activeColor;
  final Color enabledColor;
  final Color disabledColor;

  const WizardProgress({
    required this.wizard,
    this.activeColor = AppColor.secondary,
    this.enabledColor = AppColor.blue,
    this.disabledColor = AppColor.primaryLight,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(bottom: 2*AppStyle.defaultPaddingVal, top: AppStyle.defaultPaddingVal),
        width: MediaQuery.of(context).size.width - AppStyle.defaultPaddingVal*8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180.0,
              child: Divider(
                color: disabledColor,
                thickness: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var step in wizard.steps)
                  InkWell(
                    onTap: step.enabled ? () => step.start() : null,
                    child: Icon(
                      Icons.circle,
                      color: step.active ? activeColor : step.enabled ? enabledColor : disabledColor,
                      size: step.active ? _stepActiveWidth : _stepWidth,
                    ),
                  )
              ],
            ),
          ],
        ),
    );
  }
}



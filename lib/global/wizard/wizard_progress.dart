import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'wizard.dart';
import 'wizard_state.dart';


class WizardProgress extends StatelessWidget {

  final WizardState state;

  List<WizardStep> get steps => state.steps;
  List<WizardStep> get stepsW => steps.takeWhile((value) => value.index < steps.length-1).toList();


  const WizardProgress({
    required this.state,
    Key? key
  }) : super(key: key);

  double _getSeparatorsWidth(BuildContext context, WizardState state) {
    final theme = state.theme!;
    double width = MediaQuery.of(context).size.width;
    width -= 4*theme.padding;
    width -= 3*theme.separatorsSpacing;
    width /= state.steps.length-1;
    return width;
  }

  @override
  Widget build(BuildContext context) {

    final theme = BlocProvider.of<WizardCubit>(context).state.theme!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.padding, horizontal: theme.padding),
      child: Stack(
        alignment: Alignment.center,
        children: [

          Wrap(
            spacing: theme.separatorsSpacing,
            direction: Axis.horizontal,
            children: steps.getRange(0, steps.length-1).map((step) => WizardProgressStepSeparator(step,
                width: _getSeparatorsWidth(context, state),
            )).toList(),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) => WizardProgressStep(step,
            )).toList(),
          ),

        ],
      ),
    );

  }
}

class WizardProgressStep<T> extends StatelessWidget {

  final WizardStep<T> step;

  const WizardProgressStep(this.step, {
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final theme = BlocProvider.of<WizardCubit>(context).state.theme!;

    return InkWell(
      onTap: () => BlocProvider.of<WizardCubit>(context).onStepTap(step),
      child: Padding(
        padding: EdgeInsets.all(theme.progressLineHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: theme.stepActiveSize,
              height: theme.stepActiveSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(theme.stepActiveSize/2)),
                border: Border.all(
                  width: 2,
                  color: step.isActive(context) ? theme.activeColor : Colors.transparent,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.circle,
                  color: step.isActive(context) ? theme.activeColor : step.ready ? theme.enabledColor : theme.disabledColor,
                  size: theme.stepCircleSize,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class WizardProgressStepSeparator<T> extends StatelessWidget {

  final WizardStep<T> step;
  final double width;

  const WizardProgressStepSeparator(this.step, {
    required this.width,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final theme = BlocProvider.of<WizardCubit>(context).state.theme!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(theme.radius)),
        color: step.ready ? theme.enabledColor : theme.disabledColor,
      ),
      height: theme.progressLineHeight,
      width: width,
    );
  }
}

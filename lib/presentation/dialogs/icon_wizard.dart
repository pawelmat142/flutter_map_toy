import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/wizard/wizard.dart';
import 'package:flutter_map_toy/global/wizard/wizard_state.dart';
import 'package:flutter_map_toy/global/wizard/wizard_theme.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/components/icon_tile.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';


class IconWizard extends Wizard<IconCraft> {

  @override
  IconCraft dataBuilder(IconCraft? edit) {
    return edit ?? IconCraft();
  }

  @override
  dataCompleter() {
    data = IconCraft.byWizardBlocState(ctx!);
  }

  @override
  Widget getSubmitButton() {
    return PrimaryButton('submit', onPressed: () {
      cubit.finishStep(WizardStepResult(
          cubit.state.step.stepData,
          submit: true
      ));
    });
  }

  @override
  getTheme() {
    return WizardTheme(
      activeColor: AppColor.secondary,
      disabledColor: AppColor.primary,
      enabledColor: AppColor.blue,
      backgroundColor: AppColor.primaryDark,

      padding: AppStyle.defaultPaddingVal,
      radius: AppStyle.defaultRadiusVal,
    );
  }

  @override
  List<WizardStep> getSteps() {
      final tileSize = _getModalTileSize(ctx!);
      return [
        WizardStep<IconData>(index: 0,
          stepData: data!.iconData,
          builder: (ctx) => Wrap(
            spacing: AppStyle.wrapSpacing,
            runSpacing: AppStyle.wrapSpacing,
            children: AppIcon.mapFlutterIcons.asMap()
                .map((index, icon) => MapEntry(index, IconTile(
              icon: icon,
              onPressed: () => cubit.finishStep(WizardStepResult(AppIcon.mapFlutterIcons[index])),
              size: tileSize,
              color: BlocProvider.of<WizardCubit>(ctx).state.steps[1].stepData,
            ))).values.toList(),
          ),
        ),

        WizardStep<Color>(index: 1,
          stepData: data!.color,
          builder: (ctx) => Wrap(
              spacing: AppStyle.wrapSpacing,
              runSpacing: AppStyle.wrapSpacing,
              children: AppColor.mapFlutterIconColors.asMap()
                  .map((index, color) => MapEntry(index, IconTile(
                icon: BlocProvider.of<WizardCubit>(ctx).state.steps[0].stepData,
                onPressed: () => cubit.finishStep(WizardStepResult(AppColor.mapFlutterIconColors[index])),
                size: tileSize,
                color: color,
              ))).values.toList()
          ),
        ),

        WizardStep<double>(index: 2,
            stepData: data!.size,
            builder: (ctx) => const IconWizardSizeStep()
        ),
      ];
  }

  _getModalTileSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    const itemsPerRow = 4;
    return (screenWidth - itemsPerRow*AppStyle.wrapSpacing - 2*AppStyle.defaultPaddingVal) / itemsPerRow;
  }

}

class IconWizardSizeStep extends StatelessWidget {

  const IconWizardSizeStep({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cubit = BlocProvider.of<WizardCubit>(context);

    return BlocBuilder<WizardCubit, WizardState>(builder: (ctx, state) {

      final size = state.steps[2].stepData ?? IconCraft.defaultSize;

      return WillPopScope(
        onWillPop: () async {
          cubit.finishStep(WizardStepResult(null));
          return false;
        },
        child: !state.indexOk ? const SizedBox.shrink() : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(
                width: IconCraft.maxSize,
                height: IconCraft.maxSize,
                child: Center(child: IconCraft.byWizardBlocState(context).widget),
              ),
              AppStyle.verticalDefaultDistance,

              Slider(
                value: size,
                onChanged: (value) {
                  cubit.emitStepData<double>(value);
                },
                min: IconCraft.minSize,
                max: IconCraft.maxSize,
              ),
            ]
        ),
      );
    });

  }
}
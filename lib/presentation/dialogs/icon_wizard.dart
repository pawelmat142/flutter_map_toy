import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/static.dart';
import 'package:flutter_map_toy/global/wizard/wizard.dart';
import 'package:flutter_map_toy/global/wizard/wizard_state.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';


class IconWizard extends Wizard<IconCraft> {

  static const int itemsPerRow = 4;

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
  getTheme() => Static.wizardTheme;

  @override
  List<WizardStep> getSteps() {
      final tileSize = Static.getModalTileSize(ctx!, itemsPerRow: itemsPerRow);
      return [
        WizardStep<IconData>(index: 0,
          stepData: data!.iconData, builder: (ctx) {
            final icons = AppIcon.mapFlutterIcons;
            final length = icons.length;
            final color = BlocProvider.of<WizardCubit>(ctx).state.steps[1].stepData
                ?? AppColor.mapFlutterIconDefaultColor;

            List<Widget> columns = [ const SizedBox(height: AppStyle.defaultPaddingVal) ];

            for (var from = 0; from <= length; from+=itemsPerRow) {
              int to = from + itemsPerRow;
              if (to > length) {
                to = length;
              }
              columns.add(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: icons.getRange(from, to)
                      .map((icon) => GestureDetector(
                    onTap: () => cubit.finishStep(WizardStepResult(icon)),
                    child: (IconCraft()
                      ..size = tileSize
                      ..color = color
                      ..iconData = icon).widget(),
                  )).toList()
              ));
            }
            return Column(children: columns);
        }),

        WizardStep<Color>(index: 1,
            stepData: data!.color, builder: (ctx) {
              final colors = AppColor.mapFlutterIconColors;
              final icon = BlocProvider.of<WizardCubit>(ctx).state.steps[0].stepData ??
                AppIcon.mapFlutterIcons.first;
              final length = colors.length;

              List<Widget> columns = [ const SizedBox(height: AppStyle.defaultPaddingVal) ];

              for (var from = 0; from <= length; from+=itemsPerRow) {
                int to = from + itemsPerRow;
                if (to > length) {
                  to = length;
                }
                columns.add(Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: colors.getRange(from, to)
                        .map((color) => GestureDetector(
                      onTap: () => cubit.finishStep(WizardStepResult(color)),
                      child: (IconCraft()
                        ..size = tileSize
                        ..color = color
                        ..iconData = icon).widget(),
                    )).toList()
                ));
              }
              return Column(children: columns);
            }),


        WizardStep<double>(index: 2,
            stepData: data!.size,
            builder: (ctx) => const IconWizardSizeStep()
        ),
      ];
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
                width: IconCraft.iconDisplaySize,
                height: IconCraft.iconDisplaySize,
                child: Center(child: IconCraft.byWizardBlocState(context)
                    .widget(rescaled: true)),
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
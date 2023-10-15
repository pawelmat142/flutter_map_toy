import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/components/icon_tile.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/presentation/dialogs/wizard/wizard_state.dart';
import 'package:flutter_map_toy/presentation/dialogs/wizard/wizard.dart';
import 'package:flutter_map_toy/presentation/dialogs/wizard/wizard_theme.dart';
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
            builder: (ctx) => IconWizardSizeStep(ctx: ctx)
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

  final BuildContext ctx;

  const IconWizardSizeStep({
    required this.ctx,
    Key? key}) : super(key: key);

  WizardCubit get cubit => BlocProvider.of<WizardCubit>(ctx);

  double get size => cubit.state.steps[2].stepData ?? IconCraft.defaultSize;

  _finishStep() {
    cubit.finishStep(WizardStepResult(size));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _finishStep();
        return false;
      },
      child: BlocBuilder<WizardCubit, WizardState>(
        builder: (ctx, state) {
          if (!state.indexOk) {
            return const SizedBox.shrink();
          }
          return Column(
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
                  onChanged: (value) => cubit.emitStepData<double>(value),
                  min: IconCraft.minSize,
                  max: IconCraft.maxSize,
                ),
                AppStyle.verticalDefaultDistance,

                SizedBox(
                    height: 48,
                    width: MediaQuery.of(context).size.width,
                    child: PrimaryButton('submit', onPressed: _finishStep)
                ),
              ]);
        },
      )
    );
  }
}
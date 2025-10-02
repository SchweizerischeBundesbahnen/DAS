import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_railway_undertaking_filter_controller.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/util/device_screen.dart';
import 'package:app/widgets/header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

const _inputPadding = EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing / 2);

class JourneyRailwayUndertakingInput extends StatelessWidget {
  const JourneyRailwayUndertakingInput({super.key, this.isModalVersion = false});

  final bool isModalVersion;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;

        final currentRu = model.railwayUndertaking;

        return switch (model) {
          final Selecting _ || final Error _ => _RailwayUndertakingTextField(
            selectedRailwayUndertaking: currentRu,
            isModalVersion: isModalVersion,
          ),
          _ => _RailwayUndertakingTextField(
            selectedRailwayUndertaking: currentRu,
            isModalVersion: isModalVersion,
          ),
        };
      },
    );
  }
}

class _RailwayUndertakingTextField extends StatefulWidget {
  const _RailwayUndertakingTextField({
    required this.selectedRailwayUndertaking,
    this.isModalVersion = false,
  });

  final RailwayUndertaking selectedRailwayUndertaking;
  final bool isModalVersion;

  @override
  State<_RailwayUndertakingTextField> createState() => _RailwayUndertakingTextFieldState();
}

class _RailwayUndertakingTextFieldState extends State<_RailwayUndertakingTextField> {
  late JourneyRailwayUndertakingFilterController controller;
  late TextEditingController baseTextEditingController;
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RailwayUndertakingTextField oldWidget) {
    if (widget.selectedRailwayUndertaking != oldWidget.selectedRailwayUndertaking) {
      controller.selectedRailwayUndertaking = widget.selectedRailwayUndertaking;
      baseTextEditingController.text = widget.selectedRailwayUndertaking.displayText(context);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    final localizations = AppLocalizations.of(context)!;
    final vm = context.read<JourneySelectionViewModel>();
    final onAvailableRailwayUndertakingsChanged = vm.updateAvailableRailwayUndertakings;
    final updateIsSelectingRailwayUndertaking = vm.updateIsSelectingRailwayUndertaking;

    baseTextEditingController = TextEditingController(text: widget.selectedRailwayUndertaking.displayText(context));
    controller = JourneyRailwayUndertakingFilterController(
      localizations: localizations,
      focusNode: focusNode,
      updateAvailableRailwayUndertakings: onAvailableRailwayUndertakingsChanged,
      updateIsSelectingRailwayUndertaking: updateIsSelectingRailwayUndertaking,
      initialRailwayUndertaking: widget.selectedRailwayUndertaking,
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.isModalVersion ? EdgeInsets.zero : _inputPadding,
      child: GestureDetector(
        child: SBBTextField(
          enabled: false,
          controller: baseTextEditingController,
          labelText: context.l10n.p_train_selection_ru_description,
        ),
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: SBBColors.cloud,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(sbbDefaultSpacing))),
            constraints: BoxConstraints(
              maxWidth: DeviceScreen.size.width - Header.padding.vertical,
              maxHeight: DeviceScreen.size.height - kToolbarHeight - DeviceScreen.systemStatusBarHeight,
            ),
            context: context,
            builder: (context) {
              final mediaQuery = MediaQuery.of(context);
              final bottom = mediaQuery.viewInsets.bottom;
              return Padding(
                padding: EdgeInsets.only(top: sbbDefaultSpacing, bottom: bottom),
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SBBTextField(
                                  controller: controller.textEditingController,
                                  labelText: widget.isModalVersion
                                      ? null
                                      : context.l10n.p_train_selection_ru_description,
                                  hintText: widget.isModalVersion
                                      ? context.l10n.p_train_selection_ru_description
                                      : null,
                                  keyboardType: TextInputType.text,
                                  autofocus: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing),
                                child: SBBIconButtonSmall(
                                  icon: SBBIcons.cross_medium,
                                  onPressed: () {
                                    context.router.pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: sbbDefaultSpacing),
                      sliver: SliverList.list(
                        children: RailwayUndertaking.values
                            .mapIndexed(
                              (idx, e) => Material(
                                color: SBBColors.milk,
                                child: Column(
                                  children: [
                                    SBBRadioListItem(
                                      value: e,
                                      groupValue: RailwayUndertaking.sbbP,
                                      label: e.displayText(context),
                                      isLastElement: idx == RailwayUndertaking.values.length,
                                      onChanged: (_) {},
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
            // header: SBBTextField(
            //   controller: controller.textEditingController,
            //   labelText: widget.isModalVersion ? null : context.l10n.p_train_selection_ru_description,
            //   hintText: widget.isModalVersion ? context.l10n.p_train_selection_ru_description : null,
            //   keyboardType: TextInputType.text,
            //   autofocus: true,
            // ),
            // child: ,
            // showCloseButton: false,
          );
        },
      ),
    );
  }
}

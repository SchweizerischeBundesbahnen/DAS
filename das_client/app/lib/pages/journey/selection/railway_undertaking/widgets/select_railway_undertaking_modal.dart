import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/railway_undertaking/select_railway_undertaking_modal_controller.dart';
import 'package:app/theme/theme_util.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class SelectRailwayUndertakingModal extends StatefulWidget {
  static Key get modalKey => Key('SelectRailwayUndertakingModal');

  static Key get filterFieldKey => Key('SelectRailwayUndertakingModalFilterField');

  static ShapeBorder get shapeBorder =>
      RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SBBSpacing.medium)));

  const SelectRailwayUndertakingModal({
    required this.selectedRailwayUndertaking,
    required this.updateRailwayUndertaking,
    super.key,
    this.allowMultiSelect = false,
  });

  final List<RailwayUndertaking> selectedRailwayUndertaking;
  final void Function(List<RailwayUndertaking>) updateRailwayUndertaking;
  final bool allowMultiSelect;

  @override
  State<SelectRailwayUndertakingModal> createState() => _SelectRailwayUndertakingModalState();
}

class _SelectRailwayUndertakingModalState extends State<SelectRailwayUndertakingModal> {
  SelectRailwayUndertakingModalController? controller;
  late AppLocalizations _appLocalizations;
  final ScrollController scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant SelectRailwayUndertakingModal oldWidget) {
    if (widget.selectedRailwayUndertaking != oldWidget.selectedRailwayUndertaking) {
      controller?.selectedRailwayUndertaking = widget.selectedRailwayUndertaking;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    final appLocalizations = AppLocalizations.of(context)!;
    if (controller == null || _appLocalizations != appLocalizations) {
      _appLocalizations = appLocalizations;

      controller = SelectRailwayUndertakingModalController(
        localizations: _appLocalizations,
        updateRailwayUndertaking: widget.updateRailwayUndertaking,
        initialRailwayUndertaking: widget.selectedRailwayUndertaking,
      );
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottom = mediaQuery.viewInsets.bottom;
    return StreamBuilder(
      stream: controller?.availableRailwayUndertakings,
      builder: (context, snap) {
        final localizedFilteredRus = snap.data ?? [];
        final resolvedForegroundColor = ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight);
        return Padding(
          padding: .only(bottom: bottom),
          child: CustomScrollView(
            key: SelectRailwayUndertakingModal.modalKey,
            controller: scrollController,
            physics: ClampingScrollPhysics(),
            slivers: [
              PinnedHeaderSliver(
                child: Material(
                  shape: SelectRailwayUndertakingModal.shapeBorder,
                  color: resolvedForegroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(SBBSpacing.medium).copyWith(left: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SBBTextField(
                            key: SelectRailwayUndertakingModal.filterFieldKey,
                            controller: controller?.textEditingController,
                            labelText: context.l10n.p_train_selection_ru_description,
                            keyboardType: .text,
                            suffixIcon: IconButton(
                              icon: Icon(SBBIcons.cross_small),
                              onPressed: () => controller?.textEditingController.clear(),
                            ),
                            autofocus: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsetsGeometry.symmetric(vertical: SBBSpacing.medium),
                sliver: SliverList.list(
                  children: localizedFilteredRus
                      .mapIndexed(
                        (idx, e) => Material(
                          color: resolvedForegroundColor,
                          child: Column(
                            children: [
                              if (widget.allowMultiSelect)
                                SBBCheckboxListItem(
                                  key: ValueKey(e),
                                  value: widget.selectedRailwayUndertaking.contains(e),
                                  label: e.displayText(context),
                                  isLastElement: idx == localizedFilteredRus.length - 1,
                                  onChanged: (isSelected) {
                                    final newSelectedRus = [...widget.selectedRailwayUndertaking];
                                    if (isSelected != null && isSelected) {
                                      newSelectedRus.add(e);
                                    } else {
                                      newSelectedRus.remove(e);
                                    }
                                    controller?.selectedRailwayUndertaking = newSelectedRus;
                                  },
                                )
                              else
                                SBBRadioListItem<RailwayUndertaking>(
                                  key: ValueKey(e),
                                  value: e,
                                  groupValue: widget.selectedRailwayUndertaking.firstOrNull,
                                  label: e.displayText(context),
                                  isLastElement: idx == localizedFilteredRus.length - 1,
                                  onChanged: (selectedRu) {
                                    if (selectedRu != null) controller?.selectedRailwayUndertaking = [selectedRu];
                                    context.router.pop(selectedRu);
                                  },
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
    );
  }
}

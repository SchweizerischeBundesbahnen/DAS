import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/railway_undertaking/select_railway_undertaking_modal_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class SelectRailwayUndertakingModal extends StatefulWidget {
  static const modalKey = Key('SelectRailwayUndertakingModal');
  static const filterFieldKey = Key('SelectRailwayUndertakingModalFilterField');

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
        allowMultiSelect: widget.allowMultiSelect,
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
        final backgroundColor = ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight);
        return Padding(
          padding: .only(bottom: bottom),
          // TODO: SBBRadioGroup currently doesn't support Slivers so it needs to be wrapped around whole list.
          // Also see: https://github.com/flutter/flutter/issues/174753
          child: SBBRadioGroup<RailwayUndertaking>(
            groupValue: widget.selectedRailwayUndertaking.firstOrNull,
            onChanged: (selectedRu) {
              if (selectedRu != null) controller?.selectedRailwayUndertaking = [selectedRu];
              context.router.pop(selectedRu);
            },
            child: CustomScrollView(
              key: SelectRailwayUndertakingModal.modalKey,
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              slivers: [
                _sliverHeader(backgroundColor),
                SliverPadding(
                  padding: const .symmetric(vertical: SBBSpacing.medium),
                  sliver: SliverList.list(
                    children: SBBDivider.divideItems(
                      context: context,
                      items: localizedFilteredRus
                          .map(
                            (ru) => widget.allowMultiSelect
                                ? _checkboxListItem(ru, backgroundColor)
                                : _radioListItem(ru, backgroundColor),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PinnedHeaderSliver _sliverHeader(Color backgroundColor) {
    return PinnedHeaderSliver(
      child: Material(
        shape: SelectRailwayUndertakingModal.shapeBorder,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(SBBSpacing.medium).copyWith(left: 0),
          child: Row(
            spacing: SBBSpacing.medium,
            children: [
              Expanded(
                child: SBBTextInput(
                  decoration: SBBInputDecoration(labelText: context.l10n.p_train_selection_ru_description),
                  key: SelectRailwayUndertakingModal.filterFieldKey,
                  controller: controller?.textEditingController,
                  keyboardType: .text,
                  autofocus: true,
                ),
              ),
              SBBTertiaryButtonSmall(
                onPressed: () => Navigator.of(context).pop(),
                iconData: SBBIcons.cross_small,
              ),
            ],
          ),
        ),
      ),
    );
  }

  SBBRadioListItem<RailwayUndertaking> _radioListItem(RailwayUndertaking element, Color backgroundColor) {
    return SBBRadioListItem<RailwayUndertaking>(
      key: ValueKey(element),
      value: element,
      titleText: element.displayText(context),
      listItemStyle: SBBListItemStyle(backgroundColor: WidgetStatePropertyAll(backgroundColor)),
    );
  }

  SBBCheckboxListItem _checkboxListItem(RailwayUndertaking element, Color backgroundColor) {
    return SBBCheckboxListItem(
      key: ValueKey(element),
      value: widget.selectedRailwayUndertaking.contains(element),
      titleText: element.displayText(context),
      onChanged: (isSelected) {
        if (isSelected != null && isSelected) {
          widget.selectedRailwayUndertaking.add(element);
        } else {
          widget.selectedRailwayUndertaking.remove(element);
        }
        controller?.selectedRailwayUndertaking = widget.selectedRailwayUndertaking;
        setState(() {});
      },
      listItemStyle: SBBListItemStyle(backgroundColor: WidgetStatePropertyAll(backgroundColor)),
    );
  }
}

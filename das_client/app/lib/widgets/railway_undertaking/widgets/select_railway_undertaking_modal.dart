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
        final resolvedForegroundColor = ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight);
        return Padding(
          padding: .only(bottom: bottom),
          child: CustomScrollView(
            key: SelectRailwayUndertakingModal.modalKey,
            controller: scrollController,
            physics: ClampingScrollPhysics(),
            slivers: [
              _sliverHeader(context, resolvedForegroundColor),
              SliverPadding(
                padding: EdgeInsetsGeometry.symmetric(vertical: SBBSpacing.medium),
                sliver: SliverList.list(
                  children: localizedFilteredRus
                      .mapIndexed(
                        (idx, e) => Material(
                          color: resolvedForegroundColor,
                          child: widget.allowMultiSelect
                              ? _checkboxListItem(context, e, idx, idx == localizedFilteredRus.length - 1)
                              : _radioListItem(context, e, idx, idx == localizedFilteredRus.length - 1),
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

  PinnedHeaderSliver _sliverHeader(BuildContext context, Color resolvedForegroundColor) {
    return PinnedHeaderSliver(
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
                  suffixIcon: !widget.allowMultiSelect
                      ? IconButton(
                          icon: Icon(SBBIcons.cross_small),
                          onPressed: () => controller?.textEditingController.clear(),
                        )
                      : null,
                  autofocus: true,
                ),
              ),
              if (widget.allowMultiSelect)
                IconButton(
                  icon: Icon(SBBIcons.cross_small),
                  onPressed: () => context.router.pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  SBBRadioListItem<RailwayUndertaking> _radioListItem(
    BuildContext context,
    RailwayUndertaking element,
    int idx,
    bool isLastElement,
  ) {
    return SBBRadioListItem<RailwayUndertaking>(
      key: ValueKey(element),
      value: element,
      groupValue: widget.selectedRailwayUndertaking.firstOrNull,
      label: element.displayText(context),
      isLastElement: isLastElement,
      onChanged: (selectedRu) {
        if (selectedRu != null) controller?.selectedRailwayUndertaking = [selectedRu];
        context.router.pop(selectedRu);
      },
    );
  }

  SBBCheckboxListItem _checkboxListItem(
    BuildContext context,
    RailwayUndertaking element,
    int idx,
    isLastElement,
  ) {
    return SBBCheckboxListItem(
      key: ValueKey(element),
      value: widget.selectedRailwayUndertaking.contains(element),
      label: element.displayText(context),
      isLastElement: isLastElement,
      onChanged: (isSelected) {
        if (isSelected != null && isSelected) {
          widget.selectedRailwayUndertaking.add(element);
        } else {
          widget.selectedRailwayUndertaking.remove(element);
        }
        controller?.selectedRailwayUndertaking = widget.selectedRailwayUndertaking;
        setState(() {});
      },
    );
  }
}

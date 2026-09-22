import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/company_selection/select_company_modal_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SelectCompanyModal extends StatefulWidget {
  static const modalKey = Key('SelectCompanyModal');
  static const filterFieldKey = Key('SelectCompanyModalFilterField');
  static const confirmButtonKey = Key('SelectCompanyModalConfirmButton');
  static const shapeBorder = RoundedRectangleBorder(borderRadius: .vertical(top: .circular(SBBSpacing.medium)));

  const SelectCompanyModal({
    required this.availableCompanies,
    required this.selectedCompanyCodes,
    required this.onCompaniesUpdated,
    super.key,
    this.multiSelect = false,
  });

  final List<Company> availableCompanies;
  final List<String> selectedCompanyCodes;
  final void Function(List<Company>) onCompaniesUpdated;
  final bool multiSelect;

  @override
  State<SelectCompanyModal> createState() => _SelectCompanyModalState();
}

class _SelectCompanyModalState extends State<SelectCompanyModal> {
  late final SelectCompanyModalController controller;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    controller = SelectCompanyModalController(
      availableCompanies: widget.availableCompanies,
      onCompaniesUpdated: widget.onCompaniesUpdated,
      initialCompanyCodes: widget.selectedCompanyCodes,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SelectCompanyModal oldWidget) {
    if (!const ListEquality().equals(widget.selectedCompanyCodes, oldWidget.selectedCompanyCodes)) {
      controller.selectedCompanyCodes = widget.selectedCompanyCodes;
    }
    if (!const ListEquality().equals(widget.availableCompanies, oldWidget.availableCompanies)) {
      controller.availableCompanies = widget.availableCompanies;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    return StreamBuilder(
      stream: controller.filteredCompanies,
      builder: (context, snap) {
        final filteredCompanies = snap.data ?? [];
        final backgroundColor = ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight);
        return Padding(
          padding: .only(bottom: bottomInsets),
          child: SBBRadioGroup<String>(
            groupValue: controller.selectedCompanyCodes.firstOrNull,
            onChanged: (selectedCompany) {
              if (selectedCompany != null) controller.selectedCompanyCodes = [selectedCompany];
              controller.confirmSelection();
              context.router.pop(selectedCompany);
            },
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    key: SelectCompanyModal.modalKey,
                    controller: scrollController,
                    physics: ClampingScrollPhysics(),
                    slivers: [
                      _sliverHeader(backgroundColor),
                      SliverList.list(
                        children: SBBDivider.divideItems(
                          context: context,
                          items: filteredCompanies
                              .map(
                                (company) => widget.multiSelect
                                    ? _checkboxListItem(company, backgroundColor)
                                    : _radioListItem(company, backgroundColor),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.multiSelect) _confirmButton(context),
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
        shape: SelectCompanyModal.shapeBorder,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(SBBSpacing.medium).copyWith(left: 0),
          child: Row(
            spacing: SBBSpacing.medium,
            children: [
              Expanded(
                child: SBBTextInput(
                  decoration: SBBInputDecoration(leadingIconData: SBBIcons.filter_small),
                  key: SelectCompanyModal.filterFieldKey,
                  controller: controller.textEditingController,
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

  Widget _confirmButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.xSmall).copyWith(bottom: SBBSpacing.medium),
      child: SBBPrimaryButton(
        key: SelectCompanyModal.confirmButtonKey,
        labelText: context.l10n.c_button_confirm,
        onPressed: () {
          controller.confirmSelection();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _radioListItem(Company element, Color backgroundColor) {
    return SBBRadioListItem<String>(
      key: ValueKey(element),
      value: element.code,
      titleText: element.shortName,
      listItemStyle: SBBListItemStyle(backgroundColor: WidgetStatePropertyAll(backgroundColor)),
    );
  }

  Widget _checkboxListItem(Company element, Color backgroundColor) {
    return SBBCheckboxListItem(
      key: ValueKey(element),
      value: controller.selectedCompanyCodes.contains(element.code),
      titleText: element.shortName,
      onChanged: (isSelected) {
        controller.toggleCompany(element.code, isSelected: isSelected ?? false);
        setState(() {});
      },
      listItemStyle: SBBListItemStyle(backgroundColor: WidgetStatePropertyAll(backgroundColor)),
    );
  }
}

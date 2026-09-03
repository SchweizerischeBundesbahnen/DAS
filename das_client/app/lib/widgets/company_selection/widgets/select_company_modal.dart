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
  static const shapeBorder = RoundedRectangleBorder(borderRadius: .vertical(top: .circular(SBBSpacing.medium)));

  const SelectCompanyModal({
    required this.availableCompanies,
    required this.selectedCompanyCodes,
    required this.updateCompanies,
    super.key,
    this.allowMultiSelect = false,
  });

  final List<Company> availableCompanies;
  final List<String> selectedCompanyCodes;
  final void Function(List<Company>) updateCompanies;
  final bool allowMultiSelect;

  @override
  State<SelectCompanyModal> createState() => _SelectCompanyModalState();
}

class _SelectCompanyModalState extends State<SelectCompanyModal> {
  SelectCompanyModalController? controller;
  final ScrollController scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant SelectCompanyModal oldWidget) {
    if (widget.selectedCompanyCodes != oldWidget.selectedCompanyCodes) {
      controller?.selectedCompanyCodes = widget.selectedCompanyCodes;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    controller ??= SelectCompanyModalController(
      availableCompanies: widget.availableCompanies,
      updateCompanies: widget.updateCompanies,
      initialCompanyCodes: widget.selectedCompanyCodes,
      allowMultiSelect: widget.allowMultiSelect,
    );
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
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    return StreamBuilder(
      stream: controller?.filteredCompanies,
      builder: (context, snap) {
        final filteredCompanies = snap.data ?? [];
        final backgroundColor = ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight);
        return Padding(
          padding: .only(bottom: bottomInsets),
          child: SBBRadioGroup<String>(
            groupValue: widget.selectedCompanyCodes.firstOrNull,
            onChanged: (selectedCompany) {
              if (selectedCompany != null) controller?.selectedCompanyCodes = [selectedCompany];
              context.router.pop(selectedCompany);
            },
            child: CustomScrollView(
              key: SelectCompanyModal.modalKey,
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              slivers: [
                _sliverHeader(backgroundColor),
                SliverPadding(
                  padding: const .symmetric(vertical: SBBSpacing.medium),
                  sliver: SliverList.list(
                    children: SBBDivider.divideItems(
                      context: context,
                      items: filteredCompanies
                          .map(
                            (company) => widget.allowMultiSelect
                                ? _checkboxListItem(company, backgroundColor)
                                : _radioListItem(company, backgroundColor),
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
        shape: SelectCompanyModal.shapeBorder,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(SBBSpacing.medium).copyWith(left: 0),
          child: Row(
            spacing: SBBSpacing.medium,
            children: [
              Expanded(
                child: SBBTextInput(
                  decoration: SBBInputDecoration(labelText: context.l10n.p_train_selection_company_description),
                  key: SelectCompanyModal.filterFieldKey,
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
      value: widget.selectedCompanyCodes.contains(element.code),
      titleText: element.shortName,
      onChanged: (isSelected) {
        if (isSelected != null && isSelected) {
          widget.selectedCompanyCodes.add(element.code);
        } else {
          widget.selectedCompanyCodes.remove(element.code);
        }
        controller?.selectedCompanyCodes = widget.selectedCompanyCodes;
        setState(() {});
      },
      listItemStyle: SBBListItemStyle(backgroundColor: WidgetStatePropertyAll(backgroundColor)),
    );
  }
}

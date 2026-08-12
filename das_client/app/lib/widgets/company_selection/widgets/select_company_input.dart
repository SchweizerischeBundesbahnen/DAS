import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/device_screen.dart';
import 'package:app/widgets/company_selection/select_company_input_view_model.dart';
import 'package:app/widgets/company_selection/widgets/select_company_modal.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const _inputPadding = EdgeInsets.fromLTRB(SBBSpacing.medium, 0, 0, SBBSpacing.xSmall);

class SelectCompanyInput extends StatelessWidget {
  const SelectCompanyInput({
    required this.selectedCompanyCodes,
    required this.updateCompanies,
    super.key,
    this.isModalVersion = false,
    this.allowMultiSelect = false,
    this.addClearButton = false,
    this.borderType = .boxedOrListed,
  });

  final List<String> selectedCompanyCodes;
  final void Function(List<Company>) updateCompanies;
  final bool isModalVersion;
  final bool allowMultiSelect;
  final bool addClearButton;
  final SBBInputBorderType borderType;

  @override
  Widget build(BuildContext context) {
    return Provider<SelectCompanyInputViewModel>(
      create: (_) => SelectCompanyInputViewModel(settingsRepository: DI.get()),
      dispose: (_, vm) => vm.dispose(),
      builder: (context, _) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final viewModel = context.read<SelectCompanyInputViewModel>();
    return StreamBuilder<List<Company>>(
      stream: viewModel.companies,
      builder: (context, snapshot) {
        final companies = snapshot.data ?? [];
        final selectedValues = _selectedCompanies(companies).map((it) => it.shortName).join(', ');

        return Padding(
          padding: isModalVersion ? .zero : _inputPadding,
          child: Row(
            children: [
              Expanded(
                child: SBBDecoratedText(
                  onTap: () => _onTap(context, companies),
                  decoration: SBBInputDecoration(
                    borderType: borderType,
                    labelText: isModalVersion ? null : context.l10n.p_train_selection_company_description,
                    placeholderText: isModalVersion ? context.l10n.p_train_selection_company_description : null,
                  ),
                  value: selectedValues,
                ),
              ),
              if (selectedValues.isNotEmpty && addClearButton)
                Padding(
                  padding: .symmetric(horizontal: isModalVersion ? SBBSpacing.xSmall : SBBSpacing.medium),
                  child: InkWell(
                    borderRadius: .circular(SBBSpacing.small),
                    onTap: () => updateCompanies([]),
                    child: const Icon(SBBIcons.cross_tiny_small),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onTap(BuildContext context, List<Company> availableCompanies) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: .hardEdge,
      backgroundColor: ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.charcoal),
      shape: SelectCompanyModal.shapeBorder,
      constraints: _modalConstraints,
      builder: (_) => SelectCompanyModal(
        availableCompanies: availableCompanies,
        selectedCompanyCodes: selectedCompanyCodes,
        allowMultiSelect: allowMultiSelect,
        updateCompanies: updateCompanies,
      ),
    );
  }

  List<Company> _selectedCompanies(List<Company> availableCompanies) => availableCompanies
      .where((company) => selectedCompanyCodes.contains(company.code))
      .sortedBy((company) => company.shortName)
      .toList();

  BoxConstraints get _modalConstraints => BoxConstraints(
    maxWidth: DeviceScreen.width - SBBSpacing.medium,
    maxHeight: _maxModalHeight,
  );

  double get _maxModalHeight {
    final topModalMargin = isModalVersion
        ? DeviceScreen.systemStatusBarHeight
        : kToolbarHeight + DeviceScreen.systemStatusBarHeight;
    return DeviceScreen.size.height - topModalMargin;
  }
}

import 'package:das_client/bloc/fahrbild_cubit.dart';
import 'package:das_client/i18n/i18n.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainSelection extends StatefulWidget {
  const TrainSelection({super.key});

  @override
  State<TrainSelection> createState() => _TrainSelectionState();
}

class _TrainSelectionState extends State<TrainSelection> {
  late TextEditingController _trainNumberController;
  late TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _trainNumberController = TextEditingController(text: "9232");
    _companyController = TextEditingController(text: "1088");

    context.fahrbildCubit.updateTrainNumber(_trainNumberController.text);
    context.fahrbildCubit.updateCompany(_companyController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FahrbildCubit, FahrbildState>(
      builder: (context, state) {
        return Align(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, sbbDefaultSpacing, 0),
                  child: SBBTextField(
                    onChanged: (value) => _onCompanyChanged(context, value),
                    controller: _companyController,
                    labelText: context.l10n.p_train_selection_company_description,
                    icon: SBBIcons.building_tree_small,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(height: sbbDefaultSpacing),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, sbbDefaultSpacing, 0),
                  child: SBBTextField(
                    onChanged: (value) => _onTrainNumberChanged(context, value),
                    controller: _trainNumberController,
                    labelText: context.l10n.p_train_selection_trainnumber_description,
                    icon: SBBIcons.train_small,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(height: sbbDefaultSpacing * 2),
                _loadButton(context, state),
                const SizedBox(height: sbbDefaultSpacing * 2),
                _errorWidget(context, state),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _errorWidget(BuildContext context, FahrbildState state) {
    if (state is SelectingFahrbildState && state.errorCode != null) {
      return Text("${state.errorCode}", style: SBBTextStyles.mediumBold);
    }
    return Container();
  }

  Widget _loadButton(BuildContext context, FahrbildState state) {
    return SBBPrimaryButton(
      label: context.l10n.p_train_selection_load,
      onPressed: _canContinue(state)
          ? () {
              context.fahrbildCubit.loadFahrbild();
            }
          : null,
    );
  }

  bool _canContinue(FahrbildState state) {
    if (state is SelectingFahrbildState) {
      return state.trainNumber != null &&
          state.trainNumber!.isNotEmpty &&
          state.company != null &&
          state.company!.isNotEmpty;
    }
    return false;
  }

  void _onTrainNumberChanged(BuildContext context, String value) {
    context.fahrbildCubit.updateTrainNumber(value);
  }

  void _onCompanyChanged(BuildContext context, String value) {
    context.fahrbildCubit.updateCompany(value);
  }
}

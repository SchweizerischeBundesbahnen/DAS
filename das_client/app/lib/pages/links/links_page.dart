import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/links/links_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:external_links/component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class LinksPage extends StatelessWidget implements AutoRouteWrapper {
  const LinksPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return Provider<LinksViewModel>(
      create: (_) => LinksViewModel(externalLinksRepository: DI.get(), userSettings: DI.get(), launcher: DI.get()),
      dispose: (_, vm) => vm.dispose(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
      drawer: const DASNavigationDrawer(),
    );
  }

  SBBHeaderSmall _appBar(BuildContext context) {
    return SBBHeaderSmall(
      titleText: context.l10n.c_app_name,
      actions: const [], // removes SBB logo
      bottom: SBBHeaderBoxPreferredSize(
        titleText: context.l10n.w_navigation_drawer_links_title,
        textScaler: MediaQuery.textScalerOf(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final viewModel = context.read<LinksViewModel>();
    return StreamBuilder<List<ExternalLink>>(
      stream: viewModel.links,
      initialData: viewModel.linksValue,
      builder: (context, snapshot) {
        final links = snapshot.data ?? const <ExternalLink>[];

        if (links.isEmpty) {
          return Center(child: Text(context.l10n.p_links_no_content));
        }

        return _linksList(context, links);
      },
    );
  }

  Widget _linksList(BuildContext context, List<ExternalLink> links) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.small, vertical: SBBSpacing.small),
      child: Column(
        spacing: SBBSpacing.xSmall,
        children: links.map((link) {
          return SBBContentBox(
            child: SBBListItem(
              title: Text(link.title.localized, style: SBBTextStyles.mediumLight),
              trailingIconButton: SBBTertiaryButtonSmall(
                onPressed: () => _openLink(context, link),
                iconData: SBBIcons.link_external_medium,
              ),
              onTap: () => _openLink(context, link),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openLink(BuildContext context, ExternalLink link) async {
    final viewModel = context.read<LinksViewModel>();
    final isOpened = await viewModel.openExternalLink(link.link.localized);
    if (!isOpened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.c_something_went_wrong)),
      );
    }
  }
}

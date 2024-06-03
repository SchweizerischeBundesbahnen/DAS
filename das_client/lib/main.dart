import 'package:das_client/app.dart';
import 'package:das_client/auth/auth_cubit.dart';
import 'package:das_client/di.dart';
import 'package:das_client/flavor.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> start(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFimber();
  await _initDependencyInjection(flavor);
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => AuthCubit(DI.get())..init()),
    ],
    child: App(),
  ));
}

Future<void> _initFimber() async {
  final tree = DebugTree(useColors: true);
  Fimber.plantTree(tree);
}

Future<void> _initDependencyInjection(Flavor flavor) async {
  await DI.init(flavor);
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: .center,
      color: Colors.blue,
      child: const Column(
        mainAxisAlignment: .center,
        children: [
          CircularProgressIndicator(
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

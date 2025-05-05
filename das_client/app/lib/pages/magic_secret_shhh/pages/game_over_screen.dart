import 'package:app/pages/magic_secret_shhh/widgets/custom_appbar.dart';
import 'package:app/pages/magic_secret_shhh/pages/flappy_screen.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    required this.score,
    required this.devScore,
    super.key,
  });

  final int score;
  final int devScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'You lost, too bad',
      ),
      body: _body(context),
      backgroundColor: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
    );
  }

  Widget _body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Oops, you died. That\'s too bad',
            style: TextStyle(
              fontSize: 25,
              color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.white),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'You died with the score: $score',
            style: TextStyle(
              fontSize: 30,
              color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.white),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'The dev of this feature had $devScore. ${score < devScore ? 'You are too bad' : 'Ok your better.'}',
            style: TextStyle(
              fontSize: 10,
              color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.white),
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => FlappyScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SBBColors.royal150,
            ),
            child: Text(
              'Play again',
              style: TextStyle(
                fontSize: 20,
                color: SBBColors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

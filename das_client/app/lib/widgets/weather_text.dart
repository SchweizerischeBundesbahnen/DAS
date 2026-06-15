import 'package:app/di/di.dart';
import 'package:app/weather/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class WeatherText extends StatefulWidget {
  const WeatherText({required this.color, super.key});

  final Color color;

  @override
  State<WeatherText> createState() => _WeatherTextState();
}

class _WeatherTextState extends State<WeatherText> {
  late final WeatherService _weatherService;

  @override
  void initState() {
    super.initState();
    _weatherService = DI.get<WeatherService>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _weatherService.getWeatherStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final weather = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather',
                style: sbbTextStyle.lightStyle.xSmall.copyWith(color: widget.color),
              ),
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: sbbTextStyle.boldStyle.small.copyWith(color: widget.color),
              ),
              Text(
                weather.condition,
                style: sbbTextStyle.lightStyle.xSmall.copyWith(color: widget.color),
              ),
            ],
          );
        }

        // Loading or error state
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather',
              style: sbbTextStyle.lightStyle.xSmall.copyWith(color: widget.color),
            ),
            Text(
              '--°C',
              style: sbbTextStyle.boldStyle.small.copyWith(color: widget.color),
            ),
          ],
        );
      },
    );
  }
}


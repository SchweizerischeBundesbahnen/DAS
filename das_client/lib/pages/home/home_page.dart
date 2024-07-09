import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/di.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = "Connection: None";

  final client = MqttServerClient.withPort('wss://das-poc.messaging.solace.cloud',
      'd1027b71-55ab-4478-838d-85150e2c52f7', 8443); // Replace with your broker's address

  //await client.connect();
  //client.subscribe('testtopic/flutterapp', MqttQos.atLeastOnce);

  void _connect() async {
    Authenticator authenticator = DI.get();

    final token = await authenticator.token();
    client.useWebSocket = true;

    var mqttClientConnectionStatus =
        await client.connect("thomas.bomatter@sbb.ch", "OAUTH~azureAd~${token.accessToken}");
    Fimber.i("connectionState $mqttClientConnectionStatus");

    var subscribe =
        client.subscribe("90940/2/G2B/1085/2019-03-21_das/fa6e0e68-63b6-4b13-8e9c-74e9a66dd1f9", MqttQos.exactlyOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      Fimber.i(c!.last.payload.toString());
      final recMess = c.last.payload as MqttPublishMessage;
      final message = utf8.decode(recMess.payload.message);
      Fimber.i(message);

      setState(() {
        status = message;
      });
    });
    setState(() {
      status = mqttClientConnectionStatus.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("DAS Client Home Page!"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              status,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connect,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

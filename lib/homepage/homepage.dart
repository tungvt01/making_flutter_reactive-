import 'package:flutter/material.dart';
import 'package:flutter_weather_demo/homepage/weather_list_view.dart';
import 'package:flutter_weather_demo/keys.dart';
import 'package:flutter_weather_demo/model_provider.dart';
import 'package:rx_widgets/rx_widgets.dart';

import '../service/weather_entry.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("WeatherDemo")),
      resizeToAvoidBottomPadding: false,
      body: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new TextField(
              key: AppKeys.textField,
              autocorrect: false,
              controller: _controller,
              decoration: new InputDecoration(
                hintText: "Filter cities",
              ),
              style:  TextStyle(
                fontSize: 20.0,
              ),
              onChanged: ModelProvider.of(context).textChangedCommand,
            ),
          ),
          new Expanded(
            child: new RxLoader<List<WeatherEntry>>(
              key: AppKeys.loadingSpinner,
              radius: 25.0,
              commandResults: ModelProvider.of(context).updateWeatherCommand,
              dataBuilder: (context, data) => new WeatherListView(data ,key: AppKeys.weatherList),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  // We use a stream builder to toggle the enabled state of the
                  // button. StreamBuilder rebuilds its subtree on every item
                  // the stream issues
                  child: new StreamBuilder<bool>(
                    stream: ModelProvider
                        .of(context)
                        .updateWeatherCommand
                        .canExecute,
                    // We access our ViewModel through the inherited Widget
                    builder: (context, snapshot) {
                      return new RaisedButton(
                        key: AppKeys.updateButton,
                        child: new Text("Update"),
                        onPressed: snapshot.hasData && snapshot.data
                            ? () => ModelProvider
                                .of(context)
                                .updateWeatherCommand(_controller.text)
                            : null,
                      );
                    },
                  ),
                ),
                new StateFullSwitch(
                  state: true,
                  onChanged: ModelProvider.of(context).switchChangedCommand,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// As the normal switch does not even remember and display its current state
/// we us this one
class StateFullSwitch extends StatefulWidget {
  final bool state;
  final ValueChanged<bool> onChanged;

  StateFullSwitch({this.state, this.onChanged});

  @override
  StateFullSwitchState createState() {
    return new StateFullSwitchState(state, onChanged);
  }
}

class StateFullSwitchState extends State<StateFullSwitch> {
  bool state;
  ValueChanged<bool> handler;

  StateFullSwitchState(this.state, this.handler);

  @override
  Widget build(BuildContext context) {
    return new Switch(
      key: AppKeys.updateSwitch,
      value: state,
      onChanged: (b) {
        setState(() => state = b);
        handler(b);
      },
    );
  }
}

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cuba_weather_dart/cuba_weather_dart.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuba Weather',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Cuba Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final CubaWeather _cubaWeather = CubaWeather();
  final GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  final List<String> _locations = locations..sort();
  final TextEditingController _textController = TextEditingController();
  DateFormat _dateFormat;
  bool _error = false;
  bool _loading = true;
  WeatherModel _weather;

  MyHomePageState() {
    _start();
  }

  void _start() async {
    String _value;
    try {
      await initializeDateFormatting('es');
      _dateFormat = DateFormat.jm('es').add_yMMMMEEEEd();
    } catch (e) {
      log(e);
      _dateFormat = DateFormat.jm().add_yMMMMEEEEd();
    }
    try {
      var prefs = await SharedPreferences.getInstance();
      _value = prefs.getString('location') ?? _locations[0];
    } catch (e) {
      log(e);
      _value = _locations[0];
    }
    setState(() {
      _textController.text = _value;
    });
    try {
      _weather = await _cubaWeather.get(_value);
      setState(() {
        _error = false;
        _loading = false;
      });
    } catch (e) {
      log(e);
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Widget _buildCard(String key, String value, {double fondSize = 14}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
          children: <Widget>[
            Text(key,
                style:
                    TextStyle(fontSize: fondSize, fontWeight: FontWeight.bold)),
            Expanded(child: Text(value, style: TextStyle(fontSize: fondSize))),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: SimpleAutoCompleteTextField(
                  key: key,
                  controller: _textController,
                  suggestions: _locations,
                  clearOnSubmit: false,
                  textSubmitted: (text) => setState(() {
                    _submit(text);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildError() {
    return Center(
        child: Text(
            'Ha ocurrido un error.\nSeleccione nuevamente una localización',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16)));
  }

  Widget _buildWeather() {
    return ListView(
      children: <Widget>[
        _buildCard('Resumen: ', '${_weather.descriptionWeather}'),
        _buildCard('Temperatura: ', '${_weather.temp}°C'),
        _buildCard('Humedad: ', '${_weather.humidity}%'),
        _buildCard('Presión: ', '${_weather.pressure} hpa'),
        _buildCard('Vientos: ', '${_weather.windstring}'),
        _buildCard('Fecha: ', '${_dateFormat.format(_weather.dt.date)}'),
        Image.network(_weather.iconWeather),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        _buildTop(),
        Expanded(
          child: _loading
              ? _buildLoading()
              : _error ? _buildError() : _buildWeather(),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            _showInformation(context);
          },
        ),
      ],
    );
  }

  void _showInformation(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Información"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text('La información del clima mostrada en esta '
                        'aplicación proviene del sitio web redcuba.cu que solo '
                        'se puede hacer desde la red nacional cubana.'),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text('Esta aplicación es software libre, cualquier '
                        'ayuda es bienvenida. Para ver el código fuente, '
                        'contribuir o interactuar con la comunidad de Cuba'
                        ' Weather puede utilizar el siguiente botón.'),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Text('Repositorio en GitHub',
                            textAlign: TextAlign.center),
                      ),
                      onPressed: () async {
                        const url =
                            'https://github.com/leynier/cuba-weather-flutter';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text('Para visitar el sitio web oficial del '
                        'desarrollador de esta aplicacíon puede utilizar el '
                        'siguiente botón.'),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 0),
                    child: RaisedButton(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Text('Sitio Web del Desarrollador',
                            textAlign: TextAlign.center),
                      ),
                      onPressed: () async {
                        const url = 'https://leynier.github.io';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Cerrar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _submit(value) async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('location', value);
    } catch (e) {
      log(e);
    }
    try {
      log(value);
      _weather = await _cubaWeather.get(value);
      setState(() {
        _error = false;
        _loading = false;
        _textController.text = _weather.cityName;
      });
    } catch (e) {
      log(e);
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }
}

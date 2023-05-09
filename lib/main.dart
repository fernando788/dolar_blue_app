import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response =
      await http.get(Uri.parse('https://api.bluelytics.com.ar/v2/latest'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final double value_avg;
  final double value_sell;
  final double value_buy;

  const Album({
    required this.value_avg,
    required this.value_sell,
    required this.value_buy,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      value_avg: json['blue']['value_avg'],
      value_sell: json['blue']['value_sell'],
      value_buy: json['blue']['value_buy'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cotizacion Dolar Blue'),
        ),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    'Dolar promedio: ${snapshot.data!.value_avg.toStringAsFixed(2)}\n'
                    'Dolar venta: ${snapshot.data!.value_sell.toStringAsFixed(2)}\n'
                    'Dolar compra: ${snapshot.data!.value_buy.toStringAsFixed(2)}',
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 2.0));
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

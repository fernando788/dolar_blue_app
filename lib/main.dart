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

  final double o_value_avg;
  final double o_value_sell;
  final double o_value_buy;

  const Album({
    required this.value_avg,
    required this.value_sell,
    required this.value_buy,
    required this.o_value_avg,
    required this.o_value_sell,
    required this.o_value_buy,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      value_avg: json['blue']['value_avg'],
      value_sell: json['blue']['value_sell'],
      value_buy: json['blue']['value_buy'],
      o_value_avg: json['oficial']['value_avg'],
      o_value_sell: json['oficial']['value_sell'],
      o_value_buy: json['oficial']['value_buy'],
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
      debugShowCheckedModeBanner: false,
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cotizacion Dolar Blue'),
        ),
        body: ListView(children: <Widget>[
          Container(
            child: Image.network(
                "https://img.decrypt.co/insecure/rs:fill:1024:512:1:0/plain/https://cdn.decrypt.co/wp-content/uploads/2020/10/Webp.net-resizeimage-70-gID_1.jpg@png"),
            height: 198,
          ),
          Container(
            color: Color.fromARGB(255, 227, 232, 227),
            child: FutureBuilder<Album>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      'Dolar Oficial:\n'
                      '* Promedio: ${snapshot.data!.o_value_avg.toStringAsFixed(2)}\n'
                      '* Venta: ${snapshot.data!.o_value_sell.toStringAsFixed(2)}\n'
                      '* Compra: ${snapshot.data!.o_value_buy.toStringAsFixed(2)}\n\n\n'
                      'Dolar Blue:\n'
                      '* Promedio: ${snapshot.data!.value_avg.toStringAsFixed(2)}\n'
                      '* Venta: ${snapshot.data!.value_sell.toStringAsFixed(2)}\n'
                      '* Compra: ${snapshot.data!.value_buy.toStringAsFixed(2)}',
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
          )
        ]),
      ),
    );
  }
}

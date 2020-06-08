import 'package:flutter/material.dart';
import 'package:uplan_v2/widgets/ajouterEspace.dart';
import 'package:uplan_v2/widgets/creationCompte.dart';
import 'package:uplan_v2/widgets/listerEspace.dart';
import 'package:uplan_v2/widgets/home.dart';
import 'package:uplan_v2/widgets/accueil.dart';
import 'package:uplan_v2/widgets/recupererCompte.dart';
import 'package:uplan_v2/widgets/sauvegarder.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uplan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Connexion'),
      routes: {
        '/accueil': (context) => Accueil(),
        '/creationCompte': (context) => CreationCompte(),
        '/listerEspaces': (context) => ListerEspace(),
        '/ajouterEspace': (context) => AjouterEspace(),
        '/sauvegarder': (context) => Sauvegarder(),
        '/recupererCompte': (context) => RecupererCompte(),
      },
    );
  }
}
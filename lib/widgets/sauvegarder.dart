import 'package:flutter/material.dart';
import 'package:uplan_v2/db_helper/espace_helper.dart';
import 'package:uplan_v2/db_helper/indicateur_helper.dart';
import 'package:uplan_v2/db_helper/utilisateur_helper.dart';
import 'package:uplan_v2/db_helper/valeur_helper.dart';
import 'package:uplan_v2/globals.dart' as globals;

class Sauvegarder extends StatefulWidget {
  @override
  _SauvegarderState createState() => _SauvegarderState();
}

class _SauvegarderState extends State<Sauvegarder> {

  var dbHelperUtilisateur;
  var dbHelperEspace;
  var dbHelperIndicateur;
  var dbHelperValeur;


  @override
  void initState() {
    super.initState();
    dbHelperUtilisateur = DBHelperUtilisateur();
    dbHelperEspace = DBHelperEspace();
    dbHelperIndicateur = DBHelperIndicateur();
    dbHelperValeur = DBHelperValeur();
  }

  sauvegardeUtilisateur(){
    //dbHelperUtilisateur.saveUtilisateur(globals.idUtilisateur);
    dbHelperEspace.saveEspaceOnline(globals.idUtilisateur);
    dbHelperIndicateur.saveIndicateurOnline(globals.idUtilisateur);
    dbHelperValeur.saveValeurOnline(globals.idUtilisateur);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text('sauvegarder')),
        body: Center(
          child: FlatButton(
          onPressed: () {
            sauvegardeUtilisateur();
          },
          child: Text(
            "Sauvegarder l'utilisateur",
          ),
        )));
  }
}

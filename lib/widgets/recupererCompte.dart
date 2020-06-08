import 'package:flutter/material.dart';
import 'package:uplan_v2/db_helper/espace_helper.dart';
import 'package:uplan_v2/db_helper/indicateur_helper.dart';
import 'package:uplan_v2/db_helper/utilisateur_helper.dart';
import 'package:uplan_v2/db_helper/valeur_helper.dart';
import 'package:uplan_v2/globals.dart' as globals;

class RecupererCompte extends StatefulWidget {
  @override
  _RecupererCompteState createState() => _RecupererCompteState();
}

class _RecupererCompteState extends State<RecupererCompte> {

  final _formKey = GlobalKey<FormState>();

  String login;
  String password;

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
    dbHelperUtilisateur.saveUtilisateur(globals.idUtilisateur);
    dbHelperEspace.saveEspace(globals.idUtilisateur);
    dbHelperIndicateur.saveIndicateur(globals.idUtilisateur);
    dbHelperValeur.saveValeur(globals.idUtilisateur);
  }

  recuperationCompte(){
    dbHelperUtilisateur.getUtilisateurOnline(login, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text('Retrouver mon compte')),
        body: Center(

        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter your login',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your login';
                    }
                    return null;
                  },
                  onSaved: (value) => login = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'password',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value,
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        recuperationCompte();
                      }
                    },
                    child: Text('Rechercher mon compte'),
                  ),
                ),
              ],
            ),
          ),
        ),
        ));
  }
}

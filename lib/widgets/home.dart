import 'package:flutter/material.dart';
import 'package:uplan_v2/data_table/utilisateur.dart';
import 'package:uplan_v2/db_helper/espace_helper.dart';
import 'package:uplan_v2/db_helper/indicateur_helper.dart';
import 'package:uplan_v2/db_helper/utilisateur_helper.dart';
import 'package:uplan_v2/db_helper/valeur_helper.dart';
import 'package:uplan_v2/globals.dart' as globals;
import 'dart:io';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Utilisateur>> utilisateurs;
  final snackBar = SnackBar(content: Text('La récuperation de compte necessite un accès internet !'));

  String login;
  String password;

  var dbHelper;
  var dbHelperEspace;
  var dbHelperIndicateur;
  var dbHelperValeur;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelperUtilisateur();
    dbHelperEspace = DBHelperEspace();
    dbHelperIndicateur = DBHelperIndicateur();
    dbHelperValeur = DBHelperValeur();
    isUpdating = false;
    refreshList();
  }

  @override
  void dispose() {
    super.dispose();
    refreshList();
  }

  refreshList() {
    // setState(() {
    utilisateurs = dbHelper.getUtilisateurs();
    // });
  }

  SingleChildScrollView dataTable(List<Utilisateur> utilisateurs) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('ID'),
          ),
          DataColumn(
            label: Text('LOGIN'),
          ),
          DataColumn(
            label: Text('SUPPRIMER'),
          )
        ],
        rows: utilisateurs
            .map(
              (utilisateur) => DataRow(cells: [
                DataCell(
                  Text(utilisateur.id.toString()),
                ),
                DataCell(
                  Text("'" + utilisateur.login + "'"),
                ),
                DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.delete(utilisateur.id);
                        dbHelperEspace.deleAllEspace(utilisateur.id);
                        dbHelperIndicateur.deleteAllIndicateur(utilisateur.id);
                        dbHelperValeur.deleteAllValeur(utilisateur.id);
                        refreshList();
                      },
                    )),
              ]),
            )
            .toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: utilisateurs,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  Future<void> verifiedLogin(Utilisateur utilisateur, BuildContext contextSnack) async {
    globals.idUtilisateur = await dbHelper.checkUtilisateur(utilisateur);
    if (globals.idUtilisateur != 0) {
      Navigator.pushNamed(context, '/accueil');
    }else{
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          //print('connected');
          dbHelper.getAndSaveUtilisateur(utilisateur.login, utilisateur.password);
        }
      } on SocketException catch (_) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
                        Utilisateur u =
                            Utilisateur(null, login, password, null, 0);
                        verifiedLogin(u, context);
                        refreshList();
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
                list(),
                new Text('Vous n\'avez pas de compte ?'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/creationCompte')
                          .then((value) {
                        setState(() {
                          refreshList();
                        });
                      });
                    },
                    child: Text('Créer un compte'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

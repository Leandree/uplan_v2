import 'package:flutter/material.dart';
import 'package:uplan_v2/data_table/indicateur.dart';
import 'package:uplan_v2/data_table/valeur.dart';
import 'package:uplan_v2/db_helper/indicateur_helper.dart';
import 'package:uplan_v2/db_helper/valeur_helper.dart';
import 'package:uplan_v2/globals.dart' as globals;

class AjouterValeur extends StatefulWidget {
  AjouterValeur({Key key, @required this.idEspace}) : super(key: key);

  final int idEspace;

  @override
  _AjouterValeurState createState() => _AjouterValeurState();
}

class _AjouterValeurState extends State<AjouterValeur> {
  final _formKey = GlobalKey<FormState>();
  var dbHelper;
  var dbHelperValeur;
  Future<List<Indicateur>> indicateurs;
  Future<List<Valeur>> valeurs;
  final Map listeReponse = {};

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelperIndicateur();
    dbHelperValeur = DBHelperValeur();
    refreshList();
    rechercheValeurs();
  }


  rechercheValeurs() {
    valeurs = dbHelperValeur.getValeursFromDate(widget.idEspace, globals.dateSelect, globals.idUtilisateur);
  }

  refreshList() {
    // setState(() {
    indicateurs = dbHelper.getIndicateursFromSpace(widget.idEspace);
    // });
  }

  Widget dataTable(List<Indicateur> indicateurs, List<Valeur> valeurs) {
    List listings = new List<Widget>();
    //print(valeurs[0]);
    valeurs.forEach((valeur) => listeReponse[valeur.idIndicateur.toString()] = valeur.valeur);
    //print(valeurs[0].valeur);

    //print(listeReponse[1]);

    indicateurs
        .map((indicateur) => {
              listings.add(
                new Text(indicateur.nom),
              ),
              if (indicateur.type == 'Texte')
                {
                  listings.add(
                    TextFormField(
                      initialValue: listeReponse[indicateur.id.toString()],
                      decoration: const InputDecoration(
                        hintText: 'Entrée la valeur',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your login';
                        }
                        return null;
                      },
                      onSaved: (value) =>
                          listeReponse[indicateur.id.toString()] = value,
                    ),
                  ),
                },
              if (indicateur.type == 'Nombre')
                {
                  listings.add(
                    TextFormField(
                        
                        initialValue: listeReponse[indicateur.id.toString()],
                        decoration: const InputDecoration(
                          hintText: 'Entrer la valeur',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your login';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            listeReponse[indicateur.id.toString()] = value,
                        keyboardType: TextInputType.number),
                  ),
                },
              if (indicateur.type == 'vrai/faux')
                {
                  listings.add(new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Radio(
                        value: (() {
                          if(listeReponse[indicateur.id.toString()] == '0'){
                            return listeReponse[indicateur.id.toString()];
                          }
                          return 0;
                        }()),
                        groupValue: listeReponse[indicateur.id.toString()],
                        onChanged: (value) {
                          setState(() {
                            listeReponse[indicateur.id.toString()] = value;
                          });
                        },
                      ),
                      new Text(
                        'Vrai',
                        style: new TextStyle(fontSize: 16.0),
                      ),
                      new Radio(
                        value: (() {
                          if(listeReponse[indicateur.id.toString()] == '1'){
                            return listeReponse[indicateur.id.toString()];
                          }
                          return 1;
                        }()),
                        groupValue: listeReponse[indicateur.id.toString()],
                        onChanged: (value) {
                          setState(() {
                            listeReponse[indicateur.id.toString()] = value;
                          });
                        },
                      ),
                      new Text(
                        'Faux',
                        style: new TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ))
                }
            })
        .toList();

    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(children: listings);
      },
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: Future.wait([indicateurs, valeurs]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            //initialisation tableau réponse
            return dataTable(snapshot.data[0], snapshot.data[1]);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("Vous n'avez pas d'indicateur");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text('remplir les indicateurs')),
        body: new Center(
            child: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  list(),
                  RaisedButton(
                    onPressed: () {
                      _formKey.currentState.save();
                      print(listeReponse);
                      dbHelperValeur.ajouterMapValeur(
                          listeReponse, globals.idUtilisateur, widget.idEspace, globals.dateSelect);
                    },
                    child: Text('Submit'),
                  ),
                ],
              )),
        )));
  }
}

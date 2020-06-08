import 'package:flutter/material.dart';
import 'package:uplan_v2/data_table/indicateur.dart';
import 'package:uplan_v2/db_helper/indicateur_helper.dart';
import 'package:uplan_v2/globals.dart' as globals;

class AjouterIndicateur extends StatefulWidget {
  AjouterIndicateur({Key key, @required this.idEspace}) : super(key: key);

  final int idEspace;

  @override
  _AjouterIndicateurState createState() => _AjouterIndicateurState();
}

class _AjouterIndicateurState extends State<AjouterIndicateur> {
  final _formKey = GlobalKey<FormState>();

  String dropdownValue = 'Texte';
  String nom;
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelperIndicateur();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Créer un indicateur')
      ),
      body: Center(
        child: Form(
        key: _formKey,
        child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: ListView(
          children: <Widget>[
            TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Nom de l\'indicateur',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Entrez le nom de l\'indicateur';
                    }
                    return null;
                  },
                  onSaved: (value) => nom = value,
                ),
                DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>['Texte', 'Nombre', 'vrai/faux']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        Indicateur e = new Indicateur(null, nom, dropdownValue, widget.idEspace, globals.idUtilisateur, 0);
                        dbHelper.save(e);
                        Navigator.pop(context);
                      }
                      
                    },
                    child: Text('Créer l\'indicateur'),
                  ),
                )
          ],
        ),
      ),
      )
      )
    );
  }
}
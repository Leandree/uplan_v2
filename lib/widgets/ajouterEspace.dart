import 'package:flutter/material.dart';
import 'package:uplan_v2/data_table/espace.dart';
import 'package:uplan_v2/db_helper/espace_helper.dart';
import 'package:uplan_v2/globals.dart' as globals;

class AjouterEspace extends StatefulWidget {
  @override
  _AjouterEspaceState createState() => _AjouterEspaceState();
}

class _AjouterEspaceState extends State<AjouterEspace> {
  final _formKey = GlobalKey<FormState>();

  String nom;
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelperEspace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Créer un espace')
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
                    hintText: 'Nom de l\'espace',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Entrez le nom de l\'esapce';
                    }
                    return null;
                  },
                  onSaved: (value) => nom = value,
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        Espace e = new Espace(null, nom, globals.idUtilisateur, 0);
                        dbHelper.save(e);
                        Navigator.pop(context);
                      }
                      
                    },
                    child: Text('Créer l\'esapce'),
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
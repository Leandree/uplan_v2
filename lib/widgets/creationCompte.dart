import 'package:flutter/material.dart';
import 'package:uplan_v2/data_table/utilisateur.dart';
import 'package:uplan_v2/db_helper/utilisateur_helper.dart';

class CreationCompte extends StatefulWidget {
  @override
  _CreationCompteState createState() => _CreationCompteState();
}

class _CreationCompteState extends State<CreationCompte> {

    final _formKey = GlobalKey<FormState>();

    String login;
    String password;
    String email;

  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelperUtilisateur();
    isUpdating = false;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Création son compte'),
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
                    hintText: 'Login',
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
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'email',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        Utilisateur u = Utilisateur(null, login, password, email, 0);
                        dbHelper.create(u);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Créer'),
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
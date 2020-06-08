import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uplan_v2/data_table/utilisateur.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uplan_v2/db_helper/espace_helper.dart';
import 'package:uplan_v2/db_helper/indicateur_helper.dart';
import 'package:uplan_v2/db_helper/valeur_helper.dart';
import 'package:uplan_v2/globals.dart';

class DBHelperUtilisateur {
  static Database _db;
  static const String ID = 'id';
  static const String LOGIN = 'login';
  static const String PASSWORD = 'password';
  static const String EMAIL = 'email';
  static const String ISONLINE = 'isOnline';
  static const String TABLE = 'Utilisateur';
  static const String DB_NAME = 'uplan14.db';

  //other DBhelper
  var dbHelperEspace = DBHelperEspace();
  var dbHelperIndicateur = DBHelperIndicateur();
  var dbHelperValeur = DBHelperValeur();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Utilisateur (id INTEGER PRIMARY KEY, login TEXT, password TEXT, email TEXT, isOnline INTEGER)");
    await db.execute(
        "CREATE TABLE Espace (id INTEGER PRIMARY KEY, nom TEXT, idUtilisateur INTEGER, isOnline INTEGER)");
    await db.execute(
        "CREATE TABLE Indicateur (id INTEGER PRIMARY KEY, nom TEXT, type TEXT, idEspace INTEGER, idUtilisateur INTEGER, isOnline INTEGER)");
    await db.execute(
        "CREATE TABLE Valeur (id INTEGER PRIMARY KEY, idIndicateur INTEGER, valeur TEXT, date TEXT, idEspace, INTEGER, idUtilisateur INTEGER, isOnline INTEGER)");
  }

  Future<Utilisateur> create(Utilisateur utilisateur) async {
    var idUtilisateur = await this.saveUtilisateurOnline(utilisateur);
    print("id utilisateur : " + idUtilisateur.toString());
    utilisateur.id = idUtilisateur;
    var dbClient = await db;
    utilisateur.id = await dbClient.insert(TABLE, utilisateur.toMap());
    return utilisateur;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

   Future<Utilisateur> save(Utilisateur utilisateur) async {
    var dbClient = await db;
    utilisateur.id = await dbClient.insert(TABLE, utilisateur.toMap());
    return utilisateur;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  Future<List<Utilisateur>> getUtilisateurs() async {
    var dbClient = await db;
    List<Map> maps =
        await dbClient.query(TABLE, columns: [ID, LOGIN, PASSWORD, EMAIL]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Utilisateur> utilisateurs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        utilisateurs.add(Utilisateur.fromMap(maps[i]));
      }
    }
    return utilisateurs;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> update(Utilisateur utilisateur) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, utilisateur.toMap(),
        where: '$ID = ?', whereArgs: [utilisateur.id]);
  }

  Future<int> checkUtilisateur(Utilisateur utilisateur) async {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID],
        where: '$LOGIN = ? AND $PASSWORD = ?',
        whereArgs: [utilisateur.login, utilisateur.password]);

    if (maps.isNotEmpty) {
      var _list = maps[0];
      return _list['id'];
    }

    return 0;
  }

  Future<Utilisateur> getUtilisateurOnline(
      String login, String password, List<Utilisateur> utilisateurs) async {
    // a enlever !!!!
    //this.delete(1);
    final response = await http.get(
        'http://10.0.2.2:8888/api_android/utilisateur/search_user.php?login=' +
            login +
            '&password=' +
            password);

    if (response.statusCode == 200) {
      //vidadge de toutes les tables
      if (utilisateurs.isNotEmpty) {
        print(utilisateurs);
        this.delete(utilisateurs[0].id);
        dbHelperEspace.deleteAllEspace(utilisateurs[0].id);
        dbHelperIndicateur.deleteAllIndicateur(utilisateurs[0].id);
        dbHelperValeur.deleteAllValeur(utilisateurs[0].id);
      }

      // If the server did return a 200 OK response,
      // then parse the JSON.
      Utilisateur utilisateur =
          Utilisateur.fromJson(json.decode(response.body)['utilisateur']);
      this.save(utilisateur);
      dbHelperEspace.saveAll(json.decode(response.body)['espace']);
      dbHelperIndicateur.saveAll(json.decode(response.body)['indicateur']);
      dbHelperValeur.saveAll(json.decode(response.body)['valeur']);
      return utilisateur;
    }
    return null;
  }

  Future<int> saveUtilisateur(int idUtilisateur) async {
    var dbClient = await db;
    int isUpdate;

    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, LOGIN, PASSWORD, EMAIL, ISONLINE],
        where: '$ID = ?',
        whereArgs: [idUtilisateur]);

    if (maps.isNotEmpty) {
      var _list = maps[0];
      if (_list['isOnline'] == 0) {
        final http.Response response = await http.post(
          'http://10.0.2.2:8888/api_android/utilisateur/create.php',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'login': _list['login'],
            'password': _list['password'],
            'email': _list['email'],
            'id': _list['id'].toString(),
          }),
        );

        if (response.statusCode == 201) {
          //print(json.decode(response.body));
          Utilisateur utilisateurUpdate = Utilisateur(_list['id'],
              _list['login'], _list['password'], _list['email'], 1);
          isUpdate = await dbClient.update(TABLE, utilisateurUpdate.toMap(),
              where: '$ID = ?', whereArgs: [utilisateurUpdate.id]);
          print(isUpdate);
          return 1;
        } else {
          throw Exception('Failed to save User.');
        }
      }
      //ajout en base externe

      //return _list['id'];
    }

    return 0;
  }

  Future<int> saveUtilisateurOnline(Utilisateur utilisateur) async {
    var dbClient = await db;
    int isUpdate;

        final http.Response response = await http.post(
          'http://10.0.2.2:8888/api_android/utilisateur/create.php',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'login': utilisateur.login,
            'password': utilisateur.password,
            'email': utilisateur.email,
          }),
        );

        if (response.statusCode == 201) {
          
          // print(json.decode(response.body)['id']);
          // print(isUpdate);
          return json.decode(response.body)['id'];
        } else {
          throw Exception('Failed to save User.');
        }
      
      //ajout en base externe

      //return _list['id'];
  
  }

  getAndSaveUtilisateur(String login, String password) async {
    var dbClient = await db;
    List<Map> maps =
        await dbClient.query(TABLE, columns: [ID, LOGIN, PASSWORD, EMAIL]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Utilisateur> utilisateurs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        utilisateurs.add(Utilisateur.fromMap(maps[i]));
      }
      dbHelperEspace.saveEspaceOnline(utilisateurs[0].id);
      dbHelperIndicateur.saveIndicateurOnline(utilisateurs[0].id);
      dbHelperValeur.saveValeurOnline(utilisateurs[0].id);
    }
    //print(utilisateurs[0].id);
    this.getUtilisateurOnline(login, password, utilisateurs);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

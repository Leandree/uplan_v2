import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uplan_v2/data_table/indicateur.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uplan_v2/globals.dart' as globals;

class DBHelperIndicateur {
  static Database _db;
  static const String ID = 'id';
  static const String NOM = 'nom';
  static const String TYPE = 'type';
  static const String IDESPACE = 'idEspace';
  static const String IDUTILISATEUR = 'idUtilisateur';
  static const String ISONLINE = 'isOnline';
  static const String TABLE = 'Indicateur';
  static const String DB_NAME = 'uplan14.db';

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
  }

  Future<Indicateur> save(Indicateur indicateur) async {
    var dbClient = await db;
    indicateur.id = await dbClient.insert(TABLE, indicateur.toMap());
    return indicateur;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  saveAll(List listeIndicateur){
    listeIndicateur.forEach((element) {
      Indicateur indicateur = Indicateur(int.parse(element['id']), element['nom'], element['type'], int.parse(element['idEspace']), int.parse(element['idUtilisateur']), 1);
      this.save(indicateur);
    });

  }

  Future<List<Indicateur>> getIndicateurs() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, NOM, TYPE, IDESPACE]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Indicateur> indicateurs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        indicateurs.add(Indicateur.fromMap(maps[i]));
      }
    }
    return indicateurs;
  }


  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> deleteAllIndicateur(int idUtilisateur) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$IDUTILISATEUR = ?', whereArgs: [idUtilisateur]);
  }

  Future<int> update(Indicateur indicateur) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, indicateur.toMap(),
        where: '$ID = ?', whereArgs: [indicateur.id]);
  }

  Future<List<Indicateur>> getIndicateursFromSpace(int idEspace) async {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE, columns: [ID, NOM, TYPE, IDESPACE], where: '$IDESPACE = ? AND $IDUTILISATEUR = ?',
      whereArgs: [idEspace, globals.idUtilisateur]);

    List<Indicateur> indicateurs = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        indicateurs.add(Indicateur.fromMap(maps[i]));
      }
    }
    return indicateurs;

  }

    Future<int> saveIndicateurOnline(int idUtilisateur) async {
    var dbClient = await db;
    int isUpdate;

    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, NOM, TYPE, IDESPACE, IDUTILISATEUR, ISONLINE],
        where: '$IDUTILISATEUR = ?',
        whereArgs: [idUtilisateur]);

        final http.Response response = await http.post(
            'http://10.0.2.2:8888/api_android/indicateur/delete.php',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'idUtilisateur': idUtilisateur.toString(),
            }),
          );

          if (response.statusCode == 200) {

          } else {
            throw Exception('Failed to delete espace.');
          }

    if (maps.isNotEmpty) {
      maps.forEach((indicateur) async {
          final http.Response response = await http.post(
            'http://10.0.2.2:8888/api_android/indicateur/create.php',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'nom': indicateur['nom'],
              'type': indicateur['type'],
              'idEspace': indicateur['idEspace'].toString(),
              'idUtilisateur': indicateur['idUtilisateur'].toString(),
              'id': indicateur['id'].toString(),
            }),
          );

          if (response.statusCode == 201) {
            //print(json.decode(response.body));
            Indicateur indicateurUpdate = Indicateur(indicateur['id'],
                indicateur['nom'], indicateur['type'], indicateur['idEspace'], indicateur['idUtilisateur'], 1);
            isUpdate = await dbClient.update(TABLE, indicateurUpdate.toMap(),
                where: '$ID = ?', whereArgs: [indicateurUpdate.id]);
            print(isUpdate);
          } else {
            throw Exception('Failed to save indicateur.');
          }
        
        //ajout en base externe

        //return espace['id'];
      });
    }
    if(isUpdate == 1){
      return 1;
    }

    return 0;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

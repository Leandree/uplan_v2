import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uplan_v2/data_table/espace.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uplan_v2/data_table/utilisateur.dart';

class DBHelperEspace {
  static Database _db;
  static const String ID = 'id';
  static const String NOM = 'nom';
  static const String IDUTILISATEUR = 'idUtilisateur';
  static const String ISONLINE = 'isOnline';
  static const String TABLE = 'Espace';
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

  _onCreate(Database db, int version) async {}

  Future<Espace> save(Espace espace) async {
    var dbClient = await db;
    espace.id = await dbClient.insert(TABLE, espace.toMap());
    return espace;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  saveAll(List listeEspace){
    print(listeEspace);
    listeEspace.forEach((element) {
      Espace espace = Espace(int.parse(element['id']), element['nom'], int.parse(element['idUtilisateur']), 1);
      this.save(espace);
    });

  }

  Future<List<Espace>> getEspaces() async {
    var dbClient = await db;
    List<Map> maps =
        await dbClient.query(TABLE, columns: [ID, NOM, IDUTILISATEUR]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Espace> espaces = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        espaces.add(Espace.fromMap(maps[i]));
      }
    }
    return espaces;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> deleteAllEspace(int idUtilisateur) async {
    var dbClient = await db;
    // await dbClient.rawQuery("delete from sqflite_sequence where name='Espace'");
    return await dbClient.delete(TABLE, where: '$IDUTILISATEUR = ?', whereArgs: [idUtilisateur]);
  }

  Future<int> update(Espace espace) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, espace.toMap(),
        where: '$ID = ?', whereArgs: [espace.id]);
  }

  Future<List<Espace>> getEspaceFromUtilisateur(int idUtilisateur) async {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, NOM],
        where: '$IDUTILISATEUR = ?',
        whereArgs: [idUtilisateur]);

    List<Espace> espaces = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        espaces.add(Espace.fromMap(maps[i]));
      }
    }
    return espaces;
  }

  Future<int> saveEspaceOnline(int idUtilisateur) async {
    var dbClient = await db;
    int isUpdate;

    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, NOM, IDUTILISATEUR, ISONLINE],
        where: '$IDUTILISATEUR = ?',
        whereArgs: [idUtilisateur]);

        final http.Response response = await http.post(
            'http://10.0.2.2:8888/api_android/espace/delete.php',
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
        

    if(maps.isNotEmpty) {
      maps.forEach((espace) async {
          final http.Response response = await http.post(
            'http://10.0.2.2:8888/api_android/espace/create.php',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'nom': espace['nom'],
              'id': espace['id'].toString(),
              'idUtilisateur': espace['idUtilisateur'].toString(),
            }),
          );

          if (response.statusCode == 201) {
            //print(json.decode(response.body));
            Espace espaceUpdate = Espace(espace['id'],
                espace['nom'], espace['idUtilisateur'], 1);
            isUpdate = await dbClient.update(TABLE, espaceUpdate.toMap(),
                where: '$ID = ?', whereArgs: [espaceUpdate.id]);
            print(isUpdate);
          } else {
            throw Exception('Failed to save espace.');
          }
        
        // ajout en base externe

        return espace['id'];
      });
    }
    if(isUpdate == 1){
      return 1;
    }

    return 0;
  }

  Future<int> getEspaceOnline(int idUtilisateur){

  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

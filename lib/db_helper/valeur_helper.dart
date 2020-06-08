import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uplan_v2/data_table/valeur.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DBHelperValeur {
  static Database _db;
  static const String ID = 'id';
  static const String IDINDICATEUR = 'idIndicateur';
  static const String VALEUR = 'valeur';
  static const String DATE = 'date';
  static const String IDESPACE = 'idEspace';
  static const String IDUTILISATEUR = 'idUtilisateur';
  static const String ISONLINE = 'isOnline';
  static const String TABLE = 'Valeur';
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

  saveAll(List listeValeur){
    listeValeur.forEach((element) {
      Valeur valeur = Valeur(int.parse(element['id']), int.parse(element['idIndicateur']), element['valeur'], element['date'], int.parse(element['idEspace']), int.parse(element['idUtilisateur']), 1);
      this.save(valeur);
    });

  }

  Future<Valeur> save(Valeur valeur) async {
    var dbClient = await db;
    valeur.id = await dbClient.insert(TABLE, valeur.toMap());
    //print(valeur.id);
    return valeur;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  Future<List<Valeur>> getValeurs() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, IDINDICATEUR, VALEUR, DATE, IDESPACE]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Valeur> valeurs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        valeurs.add(Valeur.fromMap(maps[i]));
      }
    }
    return valeurs;
  }


  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> deleteAllValeur(int idUtilisateur) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$IDUTILISATEUR = ?', whereArgs: [idUtilisateur]);
  }

  Future<int> update(Valeur valeur) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, valeur.toMap(),
        where: '$ID = ?', whereArgs: [valeur.id]);
  }

  Future<int> ajouterMapValeur(Map listeValeur, int idUtilisateur, int idEspace, DateTime date) async{
    Valeur valeur;
    DateTime nouvelleDate = DateTime(date.year,date.month,date.day);

    listeValeur.forEach((key, value) {
      valeur = Valeur(null, int.parse(key), value.toString(), nouvelleDate.toString(), idEspace, idUtilisateur,0);
      save(valeur);
    });

    return 1;
  }

  Future<List<Valeur>> getValeursFromDate(int idEspace, DateTime date, int idUtilisateur) async {
    var dbClient = await db;
    DateTime nouvelleDate = DateTime(date.year,date.month,date.day);

    List<Map> maps = await dbClient.query(TABLE, columns: [ID, IDINDICATEUR, VALEUR, DATE], where: '$IDESPACE = ? AND $DATE = ? AND $IDUTILISATEUR = ?',
      whereArgs: [idEspace, nouvelleDate.toString(),idUtilisateur]);

    List<Valeur> valeurs = [];

    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        valeurs.add(Valeur.fromMap(maps[i]));
      }
    }
    else{
      print('tableau vide');
    }

    return valeurs;
  }

    Future<int> saveValeurOnline(int idUtilisateur) async {
    var dbClient = await db;
    int isUpdate;

    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, IDINDICATEUR, VALEUR, DATE, IDESPACE, IDUTILISATEUR, ISONLINE],
        where: '$IDUTILISATEUR = ?',
        whereArgs: [idUtilisateur]);

        final http.Response response = await http.post(
            'http://10.0.2.2:8888/api_android/valeur/delete.php',
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
      maps.forEach((valeur) async {
          final http.Response response = await http.post(
            'http://10.0.2.2:8888/api_android/valeur/create.php',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'idIndicateur': valeur['idIndicateur'].toString(),
              'id': valeur['id'].toString(),
              'valeur': valeur['valeur'].toString(),
              'date': valeur['date'],
              'idEspace': valeur['idEspace'].toString(),
              'idUtilisateur': valeur['idUtilisateur'].toString(),
            }),
          );

          if (response.statusCode == 201) {
            //print(json.decode(response.body));
            Valeur valeurUpdate = Valeur(valeur['id'],
                valeur['idIndicateur'], valeur['valeur'], valeur['date'], valeur['idEspace'], valeur['idUtilisateur'], 1);
            isUpdate = await dbClient.update(TABLE, valeurUpdate.toMap(),
                where: '$ID = ?', whereArgs: [valeurUpdate.id]);
            print(isUpdate);
          } else {
            print(json.decode(response.body));
            throw Exception('Failed to save valeur.');
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

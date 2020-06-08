import 'package:flutter/material.dart';
import 'package:uplan_v2/data_table/espace.dart';
import 'package:uplan_v2/db_helper/espace_helper.dart';
import 'package:uplan_v2/widgets/listerIndicateur.dart';
import 'package:uplan_v2/globals.dart' as globals;

class ListerEspace extends StatefulWidget {
  @override
  _ListerEspaceState createState() => _ListerEspaceState();
}

class _ListerEspaceState extends State<ListerEspace> {

  int _selectedIndex = 1;
  var dbHelper;

    void _onItemTapped(int index) {
      if(index == 0){
        Navigator.pop(context);
      }
      if (index == 2) {
      Navigator.pushNamed(context, '/sauvegarder');
    }
    }

    Future<List<Espace>> espaces;

    @override
    void initState() {
      super.initState();
      dbHelper = DBHelperEspace();
      refreshList();
    }

    refreshList() async {
      print("testest");
    // setState(() {
    espaces = dbHelper.getEspaceFromUtilisateur(globals.idUtilisateur);
    // });
  }

    SingleChildScrollView dataTable(List<Espace> espaces) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('nom'),
          ),
          DataColumn(
            label: Text(''),
          ),
          DataColumn(
            label: Text(''),
          ),
        ],
        rows: espaces
            .map(
              (espace) => DataRow(cells: [
                DataCell(
                  Text("'" + espace.nom + "'"),
                ),
                DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.delete(espace.id);
                        refreshList();
                      },
                    )),
                DataCell(IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ListerIndicateur(idEspace: espace.id),
                        ));
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
        future: espaces,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('je passe');
            return dataTable(snapshot.data);
          }
          print('je passe 2');
          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Liste des espaces')
          ),
        body: Center(
            child: Column(
          children: <Widget>[
            list(),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/ajouterEspace').then((value) {
                  setState(() {
                    refreshList();
                  });
                });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Accueil'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Esapces'),
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            title: Text('Save'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

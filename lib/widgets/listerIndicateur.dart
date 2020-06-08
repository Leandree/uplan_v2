import 'package:flutter/material.dart';
import 'package:uplan_v2/data_table/indicateur.dart';
import 'package:uplan_v2/db_helper/indicateur_helper.dart';
import 'package:uplan_v2/widgets/ajouterIndicateur.dart';

class ListerIndicateur extends StatefulWidget {
  ListerIndicateur({Key key, @required this.idEspace}) : super(key: key);

  final int idEspace;
  @override
  _ListerIndicateurState createState() => _ListerIndicateurState();
}

class _ListerIndicateurState extends State<ListerIndicateur> {

    int _selectedIndex = 1;
    var dbHelper;

    void _onItemTapped(int index) {
      if (index == 2) {
      Navigator.pushNamed(context, '/sauvegarder');
    }
    }

    Future<List<Indicateur>> indicateurs;

    @override
    void initState() {
      super.initState();
      dbHelper = DBHelperIndicateur();
      refreshList();
    }

    refreshList() {
    // setState(() {
    indicateurs = dbHelper.getIndicateursFromSpace(widget.idEspace);
    // });
  }

    SingleChildScrollView dataTable(List<Indicateur> indicateurs) {
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
        rows: indicateurs
            .map(
              (indicateur) => DataRow(cells: [
                DataCell(
                  Text("'" + indicateur.nom + "'"),
                ),
                DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.delete(indicateur.id);
                        refreshList();
                      },
                    )),
                DataCell(IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AjouterIndicateur(idEspace: widget.idEspace),
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
        future: indicateurs,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('modification de l\'espace')
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
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => AjouterIndicateur(idEspace: widget.idEspace),
          )).then((value) {
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
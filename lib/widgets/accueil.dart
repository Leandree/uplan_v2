import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:uplan_v2/data_table/espace.dart';
import 'package:uplan_v2/db_helper/espace_helper.dart';
import 'package:uplan_v2/widgets/ajouterValeur.dart';
import 'package:uplan_v2/globals.dart' as globals;

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  var _currentDate;
  Future<List<Espace>> espaces;
  var dbHelper;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/listerEspaces').then((value) {
       setState(() {
          refreshList();
       });
     });
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/sauvegarder').then((value) {
       setState(() {
          refreshList();
       });
     });
    }
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelperEspace();
    globals.dateSelect = DateTime.now();
    refreshList();
  }

  refreshList() {
    // setState(() {
    espaces = dbHelper.getEspaceFromUtilisateur(globals.idUtilisateur);
    // });
  }

  SingleChildScrollView dataTable(List<Espace> espaces) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowHeight: 0,
        columns: [
          DataColumn(
            label: Text('Espaces'),
          ),
        ],
        rows: espaces
            .map(
              (espace) => DataRow(cells: [
                DataCell(
                  Text(espace.nom),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AjouterValeur(idEspace: espace.id),
                    ));
                  },
                ),
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
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(title: new Text('Accueil')),
      body: new Center(
          child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CalendarCarousel<Event>(
            onDayPressed: (DateTime date, List<Event> events) {
              this.setState(() => _currentDate = date);
              globals.dateSelect = date;
            },
            weekendTextStyle: TextStyle(
              color: Colors.red,
            ),
            thisMonthDayBorderColor: Colors.grey,
            //      weekDays: null, /// for pass null when you do not want to render weekDays
            //      headerText: Container( /// Example for rendering custom header
            //        child: Text('Custom Header'),
            //      ),
            customDayBuilder: (
              /// you can provide your own build function to make custom day containers
              bool isSelectable,
              int index,
              bool isSelectedDay,
              bool isToday,
              bool isPrevMonthDay,
              TextStyle textStyle,
              bool isNextMonthDay,
              bool isThisMonthDay,
              DateTime day,
            ) {
              /// If you return null, [CalendarCarousel] will build container for current [day] with default function.
              /// This way you can build custom containers for specific days only, leaving rest as default.

              // Example: every 15th of month, we have a flight, we can place an icon in the container like that:
              if (day.day == 15) {
                return Center(
                  child: Icon(Icons.local_airport),
                );
              } else {
                return null;
              }
            },
            weekFormat: false,
            showHeader: true,
            height: 320.0,
            width: 290,
            selectedDateTime: _currentDate,
            daysHaveCircularBorder: false,

            /// null for not rendering any border, true for circular border, false for rectangular border
          ),
          list(),
        ],
      )),
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

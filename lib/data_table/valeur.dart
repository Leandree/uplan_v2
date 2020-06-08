class Valeur {
  int id;
  int idIndicateur;
  String valeur;
  String date;
  int idEspace;
  int idUtilisateur;
  int isOnline;
 
  Valeur(this.id, this.idIndicateur, this.valeur, this.date, this.idEspace, this.idUtilisateur, this.isOnline);
 
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'idIndicateur': idIndicateur,
      'valeur': valeur,
      'date': date,
      'idEspace': idEspace,
      'idUtilisateur': idUtilisateur,
      'isOnline': isOnline
    };
    return map;
  }
 
  Valeur.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    idIndicateur = map['idIndicateur'];
    valeur = map['valeur'];
    date = map['date'];
    idEspace = map['idEspace'];
    idUtilisateur = map['idUtilisateur'];
    isOnline = map['isOnline'];
  }
}
class Indicateur {
  int id;
  String nom;
  String type;
  int idEspace;
  int idUtilisateur;
  int isOnline;
 
  Indicateur(this.id, this.nom, this.type, this.idEspace, this.idUtilisateur, this.isOnline);
 
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nom': nom,
      'type': type,
      'idEspace': idEspace,
      'idUtilisateur': idUtilisateur,
      'isOnline': isOnline
    };
    return map;
  }
 
  Indicateur.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nom = map['nom'];
    type = map['type'];
    idEspace = map['idEspace'];
    idUtilisateur = map['idUtilisateur'];
    isOnline = map['isOnline'];
  }
}
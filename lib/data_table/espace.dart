class Espace {
  int id;
  String nom;
  int idUtilisateur;
  int isOnline;
 
  Espace(this.id, this.nom, this.idUtilisateur, this.isOnline);
 
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nom': nom,
      'idUtilisateur': idUtilisateur,
      'isOnline': isOnline
    };
    return map;
  }
 
  Espace.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nom = map['nom'];
    idUtilisateur = map['idUtilisateur'];
    isOnline = map['isOnline'];
  }
}
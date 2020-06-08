class Utilisateur {
  int id;
  String login;
  String password;
  String email;
  int isOnline;
 
  Utilisateur(this.id, this.login, this.password, this.email, this.isOnline);
 
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'login': login,
      'password': password,
      'email': email,
      'isOnline': isOnline
    };
    return map;
  }
 
  Utilisateur.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    login = map['login'];
    password = map['password'];
    email = map['email'];
    isOnline = map['isOnline'];
  }

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      int.parse(json['id']),
      json['login'],
      json['password'],
      json['email'],
      1,
    );
  }

}
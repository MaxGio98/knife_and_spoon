class Utente {
  String id;
  String immagine;
  String mail;
  String nome;
  List<String> preferiti;
  bool isAdmin;

  Utente(this.id,this.immagine, this.mail, this.nome, this.preferiti, this.isAdmin);
}

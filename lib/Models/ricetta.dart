import 'package:cloud_firestore/cloud_firestore.dart';

class Ricetta {
  String id;
  String authorId;
  String thumbnail;
  String title;
  String persone;
  String tempo;
  List<Map<String, dynamic>> ingredienti;
  List<String> steps;
  bool isApproved;
  Timestamp timestamp;
  String categoria;

  Ricetta(
      this.id,
      this.authorId,
      this.thumbnail,
      this.title,
      this.persone,
      this.tempo,
      this.ingredienti,
      this.steps,
      this.isApproved,
      this.timestamp,
      this.categoria);
}

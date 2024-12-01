import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  String? id; // ID dari dokumen Firestore
  String? title;
  String? content;
  List<String>? tags;
  String? userId;
  Timestamp? timestamp;
  Timestamp? updatedAt;

  NoteModel({
    this.id,
    this.title,
    this.content,
    this.tags,
    this.userId,
    this.timestamp,
    this.updatedAt,
  });

  // Factory untuk membuat NoteModel dari JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        tags: json["tags"] != null ? List<String>.from(json["tags"]) : null,
        userId: json["userId"],
        timestamp: json["timestamp"],
        updatedAt: json["updatedAt"],
      );

  // Factory untuk membuat NoteModel dari dokumen Firestore
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data["title"],
      content: data["content"],
      tags: data["tags"] != null ? List<String>.from(data["tags"]) : null,
      userId: data["userId"],
      timestamp: data["timestamp"],
      updatedAt: data["updatedAt"],
    );
  }

  // Fungsi untuk mengonversi NoteModel menjadi JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "tags": tags,
        "userId": userId,
        "timestamp": timestamp,
        "updatedAt": updatedAt,
      };
}

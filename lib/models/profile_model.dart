import 'document_model.dart';

class ProfileModel {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String? photoURL;
  final String? docURL;
  final List<DocumentModel> documents;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    this.photoURL,
    this.docURL,
    this.documents = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    List<DocumentModel> parsedDocuments = [];
    if (map['documents'] != null) {
      parsedDocuments = (map['documents'] as List)
          .map((doc) => DocumentModel.fromMap(doc as Map<String, dynamic>))
          .toList();
    }

    return ProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      photoURL: map['photoURL'],
      docURL: map['docURL'],
      documents: parsedDocuments,
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'photoURL': photoURL,
      'docURL': docURL,
      'documents': documents.map((doc) => doc.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    String? photoURL,
    String? docURL,
    List<DocumentModel>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      photoURL: photoURL ?? this.photoURL,
      docURL: docURL ?? this.docURL,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

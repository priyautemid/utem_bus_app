import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? id;
  String? email;
  String? userType;

  UserModel({
    this.id,
    this.email,
    this.userType,
  });

  UserModel.fromSnapshot(DataSnapshot snap){
    id= snap.key;
    email=(snap.value as dynamic)["email"];
    userType=(snap.value as dynamic)["userType"];
  }
}
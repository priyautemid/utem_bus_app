import 'package:firebase_database/firebase_database.dart';
import 'package:utembusapp/Firebase/global.dart';
import 'package:utembusapp/Firebase/usermodel.dart';

class AssistantMethods {

  static void readCurrentOnLineUserInfo() async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }
}
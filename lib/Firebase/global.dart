import 'package:firebase_auth/firebase_auth.dart';
import 'package:utembusapp/Firebase/usermodel.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;
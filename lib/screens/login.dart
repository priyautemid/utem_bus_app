import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:utembusapp/driver/HomeScreen/driverhomescreen.dart';


import 'package:utembusapp/student/studenthomepage.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(
                                  color: Colors.indigo[900],
                                ),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                    Icons.email, color: Colors.black),
                              ),
                              autovalidateMode: AutovalidateMode
                                  .onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Invalid Email';
                                }
                                if (EmailValidator.validate(text) == true) {
                                  return null;
                                }
                                if (text.length > 99) {
                                  return 'Invalid Email';
                                }
                              },
                              onChanged: (text) =>
                                  setState(() {
                                    emailTextEditingController.text = text;
                                  }),
                            ),
                            SizedBox(height: 10,),

                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(
                                  color: Colors.indigo[900],
                                ),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                    Icons.password, color: Colors.black),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons
                                        .visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              autovalidateMode: AutovalidateMode
                                  .onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Invalid Password';
                                }
                                if (text.length < 6) {
                                  return 'Password should be less than 6 characters';
                                }
                                if (text.length > 50) {
                                  return 'Password should not be more than 50 characters';
                                }
                                return null;
                              },
                              onChanged: (text) =>
                                  setState(() {
                                    passwordTextEditingController.text = text;
                                  }),
                            ),
                            SizedBox(height: 10,),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.indigo[900],
                                onPrimary: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),

                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                _submit();
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            SizedBox(height: 10,),


                            SizedBox(height: 20,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Doesn't have an account?",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 5,),

                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo[900],
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        );

        DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(userCredential.user!.uid);
        DataSnapshot dataSnapshot = (await userRef.once()).snapshot;

        if (dataSnapshot.value != null) {
          Map<String, dynamic>? userData =
          (dataSnapshot.value as Map<Object?, Object?>?)?.cast<String, dynamic>();

          if (userData != null && userData.containsKey('userType')) {
            String userType = userData['userType'];

            if (userType == 'userType.driver') {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => DriverMainScreen()));
            } else if (userType == 'userType.student') {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => StudentMainScreen()));
            } else {
              // Handle other user types or show an error message
              // You can also redirect to a common home page or display an error message
              print('Unknown user type');
            }
          } else {
            // Handle the case where 'userType' is not present in the user data
            print('User type not found in user data');
          }
        } else {
          // Handle the case where user data is not available
          print('User data not found');
        }
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: "Login failed. Check your email and password.");
        print('Login failed: $e');
      }
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }
}


import 'package:flash_chat/components/round_button.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance; // for signing users
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    //Do something with the user input.
                  },
                  decoration: KTextFieldDecoration.copyWith(
                    hintText: 'Enter your Email',
                  )),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  //Do something with the user input.
                },
                decoration: KTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundButton(
                color: Colors.lightBlueAccent,
                title: 'Login',
                onPressed: () {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    _auth
                        .signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        )
                        .then(
                          (value) =>
                              Navigator.pushNamed(context, ChatScreen.id),
                        );
                    setState(() {
                      showSpinner = false;
                    });
                  } on FirebaseAuthException catch (e) {
                    print(e.toString());
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

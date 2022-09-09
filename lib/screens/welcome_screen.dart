import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';

import '../components/round_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animeController;
  Animation? animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(animeController!);

    animeController?.forward();
    animeController?.addListener(
      () {
         setState(() {});
        // print(animation?.value);
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animeController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation?.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 60,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chat',
                      cursor: '',
                      textStyle: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black),
                      // Change this to make it faster or slower
                      speed: Duration(milliseconds: 350),

                    ),
                  ],
                  // You could replace repeatForever to a fixed number of repeats
                  // with totalRepeatCount: X, where X is the repeats you want.
                  repeatForever: true,
                ),
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            RoundButton(
              color: Colors.lightBlueAccent,
              title: 'Login',
                onPressed:  () {
                //Go to login screen.
                Navigator.pushNamed(context, LoginScreen.id );
              },
            ),
            RoundButton(
              title: 'Register',
               onPressed:  () {
                 //Go to login screen.
                 Navigator.pushNamed(context, RegistrationScreen.id);
               },
              color: Colors.blueAccent,
            )
          ],
        ),
      ),
    );
  }
}


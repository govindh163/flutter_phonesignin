import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
final GoogleSignIn _googleSignIn = GoogleSignIn();

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '';
  String email='';
  String url='';

  @override
  void initState() {
    this.name = '';
    this.email='';
    this.url='';
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        this.name = val.displayName;
        this.email = val.email;
        this.url=val.uid;

      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final alucard = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircleAvatar(
          radius: 72.0,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/alucard.jpg'),
        ),
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Welcome You are now logged in as $name',
        style: TextStyle(fontSize: 28.0, color: Colors.white),
      ),
    );

    final lorem = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'your Email is $url',
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );
    void _signOut() {
      _googleSignIn.signOut();
      print("User Signed out");
    }
    final forgotLabel = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed:  ()    {_signOut();
        Navigator.of(context).pop();
        },
        padding: EdgeInsets.all(16),
        color: Colors.lightBlueAccent,
        child: Text('Log Out', style: TextStyle(color: Colors.white)),
      ),
    );
    final image = Padding(
      padding: EdgeInsets.all(8.0),
      child:  CircleAvatar(
        backgroundImage:NetworkImage( '$url' ),
        radius: 50.0,
      ),
    );
    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue,
          Colors.lightBlueAccent,
        ]),
      ),
      child: Column(
        children: <Widget>[alucard, welcome, lorem,forgotLabel,image],
      ),
    );
    return Scaffold(
      body: body,

    );
  }
}


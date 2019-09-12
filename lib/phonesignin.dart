import'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';

String accountStatus = '******';
final FirebaseAuth _auth = FirebaseAuth.instance;



class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _message = '';
  String uid = '';
  String smsCode = '';
  String verificationId;
  String phoneNumber;
  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child:SizedBox(
        child: Image.network(
            'https://images.pexels.com/photos/2150/sky-space-dark-galaxy.jpg?cs=srgb&dl=astronomy-black-wallpaper-constellation-2150.jpg&fm=jpg'),
        height: 200,
        width: 200,
      ) ,
    );

    final email =  TextFormField(
      controller: _phoneNumberController,
      decoration:
      InputDecoration(labelText: 'Phone number (+x xxx-xxx-xxxx)'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Phone number (+x xxx-xxx-xxxx)';
        }
        return null;
      },
    );

    final forgotLabel = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed:  ()    {_signInWithPhoneNumber();
        Navigator.push(context,MaterialPageRoute(builder: (context)=> HomePage()));

        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log in', style: TextStyle(color: Colors.white)),
      ),
    );
    final widget=Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: RaisedButton(
        onPressed: () async {
          verifyPhone();
        },
        child: const Text('Verify phone number'),
      ),
    );
      final text=  TextField(
        controller: _smsController,
        decoration: InputDecoration(labelText: 'Verification code'),
    );
      final message= Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          _message,
          style: TextStyle(color: Colors.red),
        ),
      );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            forgotLabel,
            SizedBox(height: 24.0),
            widget,
            SizedBox(height: 8.0),
            text,
            SizedBox(height: 8.0),
            message,
          ],
        ),
      ),
    );
  }

  Future verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        print("Signed In");
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser) {
      print("verified");
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print("${exception.message}");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber:  _phoneNumberController.text,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  Future smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Sms Code"),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: [
              FlatButton(
                child: Text("Done"),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=> HomePage()));
                    } else {
                      Navigator.of(context).pop();

                      FirebaseAuth.instance
                          .signInWithCredential(PhoneAuthProvider.getCredential(
                        verificationId:
                        _LoginPageState().verificationId,
                        smsCode: smsCode,
                      ))
                          .then((user) {
                        Navigator.push(context,MaterialPageRoute(builder: (context)=> HomePage()));
                      }).catchError((e) {
                        print(e);
                      });
                    }
                  });
                },
              )
            ],
          );
        });
  }
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: _smsController.text,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _message = 'Successfully signed in, uid: ' + user.uid;
      } else {
        _message = 'Sign in failed';
      }
    });
  }
}







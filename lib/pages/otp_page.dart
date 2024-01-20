import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPVerify extends StatefulWidget {
  OTPVerify({
    super.key,
    required this.phone,
    required this.verify,
  });
  final String phone;

  String verify;
  @override
  State<OTPVerify> createState() =>
      _OTPVerifyState(phone: phone, verify: verify);
}

class _OTPVerifyState extends State<OTPVerify> {
  String verify;
  String phone;
  _OTPVerifyState({
    required this.phone,
    required this.verify,
  });
  // DatabaseReference ref = FirebaseDatabase.instance.ref();
  
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  final FirebaseAuth auth = FirebaseAuth.instance;
  String message = '';
  bool iserr = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> signInWithPhoneNumber() async {
    try {
      setState(() {});
      String smsCode = otpControllers.fold(
          '', (previous, controller) => previous + controller.text);

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verify, smsCode: smsCode);

      await auth.signInWithCredential(credential);

    
      // final snapshot = await ref.child('users').get();
      // dynamic map = snapshot.value;
      // if (map is Map<Object?, Object?>) {
      //   Map<Object?, Object?> item = map;
      //   if (item.containsKey(phone)) {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => Home(

          //         phone: phone,
          //       ),
          //     ));
        // } else {
          // await ref.child('users').child(phone).set({
          //   'phone': phone,
          //   'username': randomNames.manName(),
          //   'profilePic':
          //       'https://firebasestorage.googleapis.com/v0/b/flyin-79b30.appspot.com/o/836-removebg-preview.png?alt=media&token=bc4cbb5c-4c04-407c-bffd-12f60718c8fe'
          // });
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => Home(
           
          //         phone: phone,
          //       ),
          //     ));
        // }
      // }
      //
    } catch (e) {
      print('Failed to sign in: $e');
      setState(() {});
    }
  }

  List<Widget> _buildOTPFields() {
    List<Widget> otpFields = [];

    for (int i = 0; i < 6; i++) {
      otpFields.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: TextFormField(
              controller: otpControllers[i],
              obscureText: true,
              maxLength: 1,
              maxLines: 1,
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 1,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 2,
                    )),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 2,
                    )),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.length == 1) {
                  if (i < 5) {
                    FocusScope.of(context).nextFocus();
                  }
                }
              },
            ),
          ),
        ),
      );
    }

    return otpFields;
  }

  void handleResend() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          verify = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight * 0.015,
            ),
            Center(
              child: Container(
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                // color: const Color.fromARGB(255, 72, 71, 71)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 100),
                  child: Column(
                    children: [
                      // Image.asset('./assets/logo.png'),
                      Row(
                        children: _buildOTPFields(),
                      ),
                      SizedBox(
                        height: screenHeight * 0.08,
                      ),
                      iserr
                          ? Text(
                              "$message",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            )
                          : SizedBox(),
                      iserr
                          ? SizedBox(
                              height: screenHeight * 0.02,
                            )
                          : SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Did not get otp,',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: screenHeight * 0.02,
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                handleResend();
                              },
                              child: Text(
                                '  Resend ?',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: screenHeight * 0.022),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      InkWell(
                        onTap: () {
                          signInWithPhoneNumber();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: screenWidth,
                          height: screenHeight * 0.06,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 113, 15, 251),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text("Get Started",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
            bottom: screenHeight * 0.035,
            right: screenWidth * 0.045,
            child: InkWell(
              onTap: () {
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //   builder: (context) => LoginPage(
                //     cameras: widget.cameras,
                //   ),
                // ));
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 30,
              ),
            ))
        // Positioned(
        //   top: screenHeight * 0.037,
        //   left: screenWidth * 0.05,
        //   child: InkWell(
        //     onTap: () {
        //       // isteach
        //       //     ? Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       //         builder: (context) => TeachCourse(
        //       //           username: username,
        //       //           name: name,
        //       //           approved: true,
        //       //         ),
        //       //       ))
        //       //     : Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       //         builder: (context) => StudCourse(
        //       //           username: username,
        //       //           name: name,
        //       //         ),
        //       //       ));
        //     },
        //     child: Row(
        //       children: [
        //         Container(
        //           width: screenWidth * 0.15,
        //           height: screenWidth * 0.15,
        //           decoration: BoxDecoration(
        //               color: Color(0xff686262),
        //               shape: BoxShape.circle,
        //               border: Border.all(color: Colors.white, width: 2)),
        //           child: Icon(
        //             Icons.arrow_back_sharp,
        //             color: Color.fromARGB(255, 255, 255, 255),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ]),
    );
  }

  @override
  void dispose() {
    // Dispose the controllers to avoid memory leaks
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

import 'package:ecommerce/pages/otp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key? key, }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();

  void handleClick() async {
    if (_formKey.currentState!.validate()) {
      // Do something with the validated data
      print('Phone Number: ${_phoneNumberController.text}');

      String phoneNumber = _phoneNumberController.text.trim();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => OTPVerify(
                phone: phoneNumber, verify: verificationId),
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    double screenWidth = queryData.size.width;
    double screenHeight = queryData.size.height;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('./assets/images/logo.png'),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 211, 94, 232),
                      style: BorderStyle.none,
                    ),
                  ),
                  label: Text(
                    'Mobile No',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  hintText: 'Enter Your Mobile No',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  } else if (!isValidPhoneNumber(value)) {
                    return 'Please enter a valid mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: handleClick,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 184, 42, 255),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    Size(screenWidth * 0.9, 50),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Text(
                  'Next    ➤',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidPhoneNumber(String value) {
    // Add your phone number validation logic here
    // You can use regular expressions or any other method
    return value.length == 10 && int.tryParse(value) != null;
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }
}

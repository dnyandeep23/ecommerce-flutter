import 'dart:convert';

import 'package:ecommerce/models/cart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/store.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key, required this.value1});
  final String value1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.canvasColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: "Cart".text.make(),
        ),
        body: Column(
          children: [
            _CartList().p32().expand(),
            Divider(),
            _CartTotal(
              value1: value1,
            ),
          ],
        ));
  }
}

class _CartTotal extends StatefulWidget {
  _CartTotal({super.key, required this.value1});
  final String value1;

  @override
  State<_CartTotal> createState() => _CartTotalState();
}

class _CartTotalState extends State<_CartTotal> {
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initPaymentSheet();
  }

  Future<void> stripeMakePayment() async {
    try {
      paymentIntent = await createPaymentIntent('100', 'INR');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  billingDetails: BillingDetails(
                      name: 'YOUR NAME',
                      email: 'YOUREMAIL@gmail.com',
                      phone: 'YOUR NUMBER',
                      address: Address(
                          city: 'YOUR CITY',
                          country: 'YOUR COUNTRY',
                          line1: 'YOUR ADDRESS 1',
                          line2: 'YOUR ADDRESS 2',
                          postalCode: 'YOUR PINCODE',
                          state: 'YOUR STATE')),
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Ikay'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  

  displayPaymentSheet() async {
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();

      // Fluttertoast.showToast(msg: 'Payment succesfully completed');
    } on Exception catch (e) {
      if (e is StripeException) {
        // Fluttertoast.showToast(
        // msg: 'Error from Stripe: ${e.error.localizedMessage}');
      } else {
        // Fluttertoast.showToast(msg: 'Unforeseen error: ${e}');
      }
    }
  }

//create Payment
  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer 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',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

//calculate Amount
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    // final _cart = CartModel();
    final CartModel _cart = (VxState.store as MyStore).cart;

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          VxConsumer(
            notifications: {},
            builder: (context, status, _) {
              // Assuming "totalPrice" is a property in the "Cart" class
              return "\$${_cart.totalPrice}"
                  .text
                  .xl5
                  .color(context.theme.colorScheme.secondary)
                  .make();
            },
            mutations: {RemoveMutation},
          ),
          30.widthBox,
          ElevatedButton(
            onPressed: () {
              print(_cart.items[0].id);
              var uuid = Uuid();
              var a = uuid.v1();

              if (_cart.items.length != 0) {
                FirebaseDatabase.instance.ref('users/${widget.value1}/order/$a').update({
                  'order_id': a,
                  'customer_name': widget.value1,
                  'status': 'Un-Paid',
                });

                _cart.items.forEach((element) {
                  FirebaseDatabase.instance
                      .ref('users/${widget.value1}/order/$a/items/${element.id}')
                      .update({
                    'name': element.name,
                    'desc': element.desc,
                    'price': element.price,
                    'id': element.id,
                    'image': element.image,
                    'color': element.color
                  });
                });
                stripeMakePayment();
                // startStripeCheckout(context);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: "Buying not supported yet... ".text.white.make()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: "Please select item first... ".text.white.make()));
              }
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(context.theme.highlightColor)),
            child: "Buy".text.white.make(),
          ).w32(context),
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  // final _cart = CartModel();
  @override
  Widget build(BuildContext context) {
    VxState.watch(context, on: [RemoveMutation]);
    final CartModel _cart = (VxState.store as MyStore).cart;

    return _cart.items.isEmpty
        ? "Your Cart is an Empty".text.xl3.makeCentered()
        : ListView.builder(
            itemCount: _cart.items?.length,
            itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.done),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      // _cart.remove(_cart.items[index]);

                      RemoveMutation(_cart.items[index]);
                    },
                  ),
                  title: _cart.items[index].name.text.make(),
                ));
  }
}

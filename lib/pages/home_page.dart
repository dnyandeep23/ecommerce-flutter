// ignore_for_file: avoid_print

import 'package:ecommerce/core/store.dart';
import 'package:ecommerce/models/cart.dart';
import 'package:ecommerce/models/catelog.dart';
import 'package:ecommerce/pages/cart_page.dart';
import 'package:ecommerce/pages/home_detail_page.dart';
import 'package:ecommerce/widgets/drawer.dart';
import 'package:ecommerce/widgets/home_widgets/catalog_header.dart';
import 'package:ecommerce/widgets/home_widgets/catalog_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.value1});
  final String value1;
  @override
  State<HomePage> createState() => _HomePageState(value1: value1);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({required this.value1});
  final String value1;
  int days = 2;
  String name = "Dnyan";
  String search = '';
  final url = "https://api.jsonbin.io/v3/b/64c139ec8e4aa6225ec4f105";
  // Map<String, String> headers = {
  //   'User-Agent': '\$2b\$10\$6TKJ8ByLeU.J7LSEnOGRm.i9/6FVNdcUQRbNrPsGOmfxs80e9UPwS',  // Replace with your desired user-agent header
  //   'Authorization': 'Bearer \$2b\$10\$fpmZY7ZNKM0DbM6fEWASQ.WvHNlaeUk2qIb6SRzaPxzpgbhfKehS.',  // Replace with any authorization header you need
  //   // Add other headers as needed
  // };
  bool searchClicked = false;
  bool setShow = false;
  List<Item> searched = [];

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    print("entered");

    final ref = FirebaseDatabase.instance.ref();
    final event = await ref.child('products').once(DatabaseEventType.value);
    print(event);
    final data = event?.snapshot.value;
    print(data);
    print('work');

    if (data != null) {
      print("Data is not null");
      print("Type of data: ${data.runtimeType}");

      if (data is List<Object?>) {
        final List<Item> items = [];

        for (var element in data) {
          // print(element);
          // Check if the element is a Map
          if (element is Map<Object?, Object?>) {
            // Check if the required keys are present in the map
            if (element.containsKey('id') &&
                element.containsKey('name') &&
                element.containsKey('price') &&
                element.containsKey('image') &&
                element.containsKey('desc') &&
                element.containsKey('color')) {
              print("ee");
              print(element);
              if (element['id'] is int && element['price'] is int) {
                items.add(Item.fromMap(Map<String, dynamic>.from(element)));
              } else {
                print("Invalid data types for element: $element");
              }
            } else {
              print("Incomplete data format for element: $element");
            }
          } else {
            print("Invalid data format for element: $element");
          }
        }

        print(items);

        CatalogModel.items = items;

        setState(() {});
      } else {
        print("Data is not of type List<Object>");
      }
    } else {
      print("Data is null");
    }

    await Future.delayed(Duration(seconds: 2));
  }

  void searchHandle() {
    List<Item> items = CatalogModel.items;
    searched.clear();
    items.forEach((element) {
      String x = element.name.toLowerCase();
      if (x.contains(search.toLowerCase())) {
        searched.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _cart = (VxState.store as MyStore).cart;

    return Scaffold(
      backgroundColor:
          context.cardColor, // no vx -- Theme.of(context).cardColor
      floatingActionButton: VxBuilder(
        mutations: const {RemoveMutation, AddMutation},
        builder: (ctx, status, _) => FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartPage(value1: value1)));
          },
          backgroundColor: context.theme.highlightColor,
          child: Icon(CupertinoIcons.cart),
        ).badge(
            color: Vx.indigo900,
            size: 22,
            count: _cart.items.length,
            textStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Container(
          padding: Vx.m20,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CatalogHeader(),
                          !searchClicked
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchClicked = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color:
                                            Color.fromARGB(255, 228, 223, 223)),
                                    padding: EdgeInsets.all(8),
                                    child: Hero(
                                      tag: 'search',
                                      child: Icon(
                                        CupertinoIcons.search,
                                        size: 35,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                      searchClicked
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 221, 218, 218),
                                  borderRadius: BorderRadius.circular(40)),
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: 'search',
                                    child: Icon(
                                      CupertinoIcons.search,
                                      size: 35,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: TextField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        onChanged: (value) {
                                          setState(() {
                                            search = value;

                                            searchHandle();
                                            setShow = true;
                                          });
                                          if (value.isEmpty) {
                                            setState(() {
                                              searched.clear();
                                              setShow = false;
                                            });
                                          }
                                        },
                                      )),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          searchClicked = false;
                                          setShow = false;
                                        });
                                      },
                                      child: Icon(Icons.clear))
                                ],
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  if (CatalogModel.items != null &&
                      CatalogModel.items.isNotEmpty)
                    CatalogList(
                      value1: value1,
                    ).py16().expand()
                  else
                    CircularProgressIndicator().centered().expand(),
                ],
              ),
              setShow
                  ? Column(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: 350,
                                width: 350,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 223, 212, 212),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: (searched.isNotEmpty)
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: searched.length,
                                          itemBuilder: (context, index) {
                                            final catalog = searched[index];
                                            return InkWell(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HomeDetailPage(
                                                                catalog: catalog,
                                                                value1: value1))),
                                                child: CatalogItem(
                                                  catalog: catalog,
                                                  value1: value1,
                                                ));
                                          })
                                      : Container(
                                          child: Image.asset(
                                              './assets/images/search.png'),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                  : SizedBox()
            ],
          ),
        ),
      ),
      drawer: MyDrawer(
        value1: value1,
      ),
    );
  }
}

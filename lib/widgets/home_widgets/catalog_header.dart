import 'package:ecommerce/models/catelog.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CatalogHeader extends StatefulWidget {
  CatalogHeader({super.key});

  @override
  State<CatalogHeader> createState() => _CatalogHeaderState();
}

class _CatalogHeaderState extends State<CatalogHeader> {
  final catalog = CatalogModel.items;
  @override
  void initState() {
    super.initState();
    print('ym $catalog');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          "E-commerce App"
              .text
              .xl4
              .bold
              .color(context.theme.colorScheme.secondary)
              .make(),
          "Trending products".text.xl2.make(),
        ],
      ),
    );
  }
}

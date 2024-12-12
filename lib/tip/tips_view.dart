
import 'package:fitness/tip/tip_row.dart';
import 'package:flutter/material.dart';
import 'package:fitness/tip/tips_details_view.dart';

import '../../tip/color_extension.dart';

class TipsView extends StatefulWidget {
  const TipsView({super.key});

  @override
  State<TipsView> createState() => _TipsViewState();
}

class _TipsViewState extends State<TipsView> {
  List tipsArr = [
    {"name": "About Traning"},
    {"name": "How to weight loss ?"},
    {"name": "Introducing about meal plan "},
    {"name": "Water and Food"},
    {"name": "Drink water"},
    {"name": "How many times a day to eat"},
    {"name": "Become stronger"},
    {"name": "Shoes To Training"},
    {"name": "Appeal Tips"}
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        centerTitle: true,
        elevation: 0.1,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset(
              "assets/img/black_white.png",
              width: 25,
              height: 25,
            )),
        title: Text(
          "Tips",
          style: TextStyle(
              color: TColor.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemBuilder: (context, index) {
            var tObj = tipsArr[index] as Map? ?? {};
            return TipRow(
              tObj: tObj ,
              isActive: index == 0,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TipsDetailView(tObj: tObj,) ));
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              color: Colors.black26,
              height: 1,
            );
          },
          itemCount: tipsArr.length),
      
    );
  }
}

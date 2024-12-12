import 'package:flutter/material.dart';

import '../../tip/color_extension.dart';

class TipsDetailView extends StatefulWidget {
  final Map tObj;
  const TipsDetailView({super.key, required this.tObj});

  @override
  State<TipsDetailView> createState() => _TipsDetailViewState();
}

class _TipsDetailViewState extends State<TipsDetailView> {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/img/1.png",
              width: media.width,
              height: media.width * 0.55,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.tObj["name"],
                    style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                "Drink water",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Drink 8-10 glasses of water daily to stay hydrated and maintain energy levels.\nStart your day with a glass of water to boost metabolism and detoxify your body. ",
                style: TextStyle(color: TColor.secondaryText, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                "Calories",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Track your daily calorie intake to ensure it aligns with your fitness goals.\nOpt for nutrient-dense, low-calorie foods like fruits, vegetables, and lean proteins. ",
                style: TextStyle(color: TColor.secondaryText, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
     
    );
  }
}

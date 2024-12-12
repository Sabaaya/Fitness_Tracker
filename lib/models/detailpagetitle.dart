// ignore: file_names
// ignore: file_names
import 'package:flutter/material.dart';

class Detailpagetitle extends StatelessWidget {
  final String text;
  final String title;
  final Color color;
  const Detailpagetitle( {super.key, required this.title, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double screenWidth =size.width;
    double paddingValue = screenWidth*0.05;
    return Column(
      children: [
        SizedBox(
          height: size.height*0.1,
        ),
        Align(
          alignment: Alignment.center,
          child: Text(title.toUpperCase(),
              style:TextStyle(
                color:color,
                fontSize: screenWidth*0.07,fontWeight: FontWeight.bold
              ) ,
              textAlign: TextAlign.center,),
        ),
            SizedBox(
              height: size.height*0.01,
              
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: paddingValue),
             child:  Text(text,
              style: TextStyle(
                color: color, fontSize: screenWidth*0.04,
              ),
              textAlign: TextAlign.center,),
              ),])
    ;
    
  }
}
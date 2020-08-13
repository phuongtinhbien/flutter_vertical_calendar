import 'package:flutter/material.dart';

class DayMonthDetailModel {
  dynamic day;
  int month, year;
  String weekDay;
  BorderRadius borderRadius = BorderRadius.all(Radius.circular(40));
  BorderRadius backgroundBorderRadius = BorderRadius.all(Radius.circular(40));
  Color selectedColor = Colors.white;
  Color backgroundSelectedColor = Colors.white;
  Color selectedTextColor = Colors.black;
  @override
  String toString() {
    // TODO: implement toString

    return DateTime(year, month, day).toString();
  }
}

class TempMonthDetails{
  String month;
  int year;
}

class YearCallback{
  void yearResult(int year){}
}




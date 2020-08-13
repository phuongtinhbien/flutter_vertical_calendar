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


  DayMonthDetailModel({this.day, this.month, this.year, this.weekDay});

  @override
  String toString() {
    // TODO: implement toString
    return DateTime(year, month, day).toString();
  }

  DateTime get dateTime  => DateTime(year, month, day);
}

class TempMonthDetails{
  String month;
  int year;
}

class YearCallback{
  void yearResult(int year){}
}




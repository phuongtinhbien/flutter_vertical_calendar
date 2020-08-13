import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'day_details_model.dart';
import 'scrolling_years_calendar.dart';

enum Calendar {
  BIRTHDAY,
  BOOKING,
  BOOKING_RANGE,
  FUTUREYEARS,
}

class CalendarChoose extends StatefulWidget {
  Calendar type;
  Color currentDateBackgroundColor = Colors.redAccent;
  Color currentDateFontColor = Colors.black;
  Color rangeStartEndBackgroundColor;
  Color innerRangeBackgroundColor = Colors.lightBlueAccent;
  Color selectionBackgroundColor = Colors.blue;
  Color selectionFontColor = Colors.white;

  CalendarChoose(this.type,
      {this.currentDateBackgroundColor = Colors.redAccent,
      this.currentDateFontColor = Colors.black,
      this.selectionBackgroundColor = Colors.blue,
      this.selectionFontColor = Colors.white});

  CalendarChoose.range(
      {this.currentDateBackgroundColor = Colors.redAccent,
      this.currentDateFontColor,
      this.rangeStartEndBackgroundColor = Colors.blue,
      this.innerRangeBackgroundColor = Colors.lightBlueAccent,
      this.selectionFontColor = Colors.white}) {
    type = Calendar.BOOKING_RANGE;
  }

  @override
  State<StatefulWidget> createState() {
    return CalendarChooseState();
  }
}

class CalendarChooseState extends State<CalendarChoose>
    implements YearCallback {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool rangeDate = false;
  VoidCallback _showPersBottomSheetCallBack;
  List weeks = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
  List days_in_month = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<List<DayMonthDetailModel>> daysOfMonth;
  List<int> dayCodeList = List();
  int dayCode;
  double currentMonth = 0.0;
  ScrollController scrollController;
  int lastSelectedMonth, lastSelectedDay;
  bool isLastSelected = false;
  String selectedDate;
  int tempStartMonthIndex = 0;
  int startMonthIndex = 0;
  int startDayIndex = 0;
  int endMonthIndex = 0;
  int endDayIndex = 0;
  int selectedYear = DateTime.now().year;
  List<TempMonthDetails> tempMonths;
  int bookingFistIteration = 1;
  int tapIncrement = 1;
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  DateTime startDateTime;

  @override
  void initState() {
    daysOfMonth = List();
    tempMonths = List();
    determineLeapYear(selectedYear);
    scrollController = new ScrollController(initialScrollOffset: 11.0);
    if (widget.type == Calendar.BIRTHDAY ||
        widget.type == Calendar.FUTUREYEARS) {
      rangeDate = false;
      for (int i = 1; i <= 12; i++) {
        calendarMonth(selectedYear, i);
      }
    } else if (widget.type == Calendar.BOOKING) {
      rangeDate = false;
      bookingCalendarLogic();
    } else if (widget.type == Calendar.BOOKING_RANGE) {
      rangeDate = true;
      bookingCalendarLogic();
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (Calendar.BOOKING_RANGE != widget.type ||
            Calendar.BOOKING != widget.type) {}
        scrollController.jumpTo(currentMonth * 300);
      });
    });
    _showPersBottomSheetCallBack = _showBottomSheet;
    super.initState();
  }

  void bookingCalendarLogic() {
    int tmonth = DateTime.now().month - 1;
    for (int i = DateTime.now().month; i <= 12; i++) {
      calendarMonth(selectedYear, i);
      TempMonthDetails tmds = TempMonthDetails();
      tmds.month = months[tmonth];
      tmds.year = selectedYear;
      tempMonths.add(tmds);
      tmonth = tmonth + 1;
    }
    tmonth = 0;
    selectedYear = selectedYear + 1;
    for (int j = 1; j < DateTime.now().month; j++) {
      TempMonthDetails tmds = TempMonthDetails();
      tmds.month = months[tmonth];
      tmds.year = selectedYear;
      calendarMonth(selectedYear, j);
      tempMonths.add(tmds);
      tmonth = tmonth + 1;
    }
  }

  void _showBottomSheet() {
    setState(() {
      _showPersBottomSheetCallBack = null;
    });

    _scaffoldKey.currentState
        .showBottomSheet((context) {
          return new Container(
            height: 300.0,
            color: Colors.greenAccent,
            child: new Center(
              child: new Text("Hi BottomSheet"),
            ),
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _showPersBottomSheetCallBack = _showBottomSheet;
            });
          }
        });
  }

  void _showBirthdayPastYearsModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            color: Colors.white,
            child: Center(
              child: ScrollingYearsCalendar(
                calendarInstance: this,
                initialDate: DateTime.now(),
//                firstDate: DateTime.now().subtract(Duration(days: 1)), //for future date
                firstDate: DateTime.now().subtract(Duration(days: 36500)),
                // for past dates
//                lastDate: DateTime.now().add(Duration(days: 36500)),// for future date
                lastDate: DateTime.now().add(Duration(days: 0)),
                // for past dates
                currentDateColor: Colors.blue,
              ),
            ),
          );
        });
  }

  void _showFutureYearsModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            color: Colors.white,
            child: Center(
              child: ScrollingYearsCalendar(
                calendarInstance: this,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 1)),
                //for future date
//              firstDate: DateTime.now().subtract(Duration(days: 36500)), // for past dates
                lastDate: DateTime.now().add(Duration(days: 36500)),
                // for future date
//              lastDate: DateTime.now().add(Duration(days:0)), // for past dates
                currentDateColor: Colors.blue,
              ),
            ),
          );
        });
  }

  Widget appBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0), // here the desired height
        child: AppBar(
          title: Text("Selecte date"),
          actions: <Widget>[
            GestureDetector(
                onTap: () {
                  print("startDate: " + daysOfMonth[startMonthIndex][startDayIndex].toString());
                  print("endDate: " + daysOfMonth[endMonthIndex][endDayIndex].toString());
                },
                child: Image.asset(
                  "images/tick.png",
                  color: Colors.white,
                ))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(),
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return monthList(index);
                    }, childCount: daysOfMonth.length),
                  )
                ],
              )),
            ],
          ),
        ));
  }

  Widget showMonthTitle(index) {
    if (widget.type == Calendar.BIRTHDAY ||
        widget.type == Calendar.FUTUREYEARS) {
      return Text("${months[index]}",
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold));
    } else if (widget.type == Calendar.BOOKING ||
        widget.type == Calendar.BOOKING_RANGE) {
      return Text("${tempMonths[index].month}",
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold));
    } else
      return Text("null");
  }

  Widget showYearTitle(index) {
    if (widget.type == Calendar.BIRTHDAY ||
        widget.type == Calendar.FUTUREYEARS) {
      return Text("${selectedYear}",
          style: TextStyle(
              color: Color(0xff626262),
              fontSize: 16,
              fontWeight: FontWeight.w500));
    } else if (widget.type == Calendar.BOOKING ||
        widget.type == Calendar.BOOKING_RANGE) {
      return Text("${tempMonths[index].year}",
          style: TextStyle(
              color: Color(0xff626262),
              fontSize: 16,
              fontWeight: FontWeight.w500));
    } else {
      return Text("null");
    }
  }

  Widget monthList(indexMonth) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Column(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.type == Calendar.BIRTHDAY) {
                  _showBirthdayPastYearsModalSheet();
                } else if (widget.type == Calendar.FUTUREYEARS) {
                  _showFutureYearsModalSheet();
                }
              },
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showMonthTitle(indexMonth),
                    SizedBox(
                      width: 3,
                    ),
                    showYearTitle(indexMonth)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 30,
              child: Center(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemExtent: (MediaQuery.of(context).size.width) / 7,
                  itemCount: weeks.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        height: 30,
                        child: Center(
                            child: Text(
                          "${weeks[index]}",
                          style: TextStyle(
                              color: Color(0xff626262),
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        )));
                  },
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: daysOfMonth[indexMonth].length != 0
                      ? daysOfMonth[indexMonth].length
                      : 0,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, mainAxisSpacing: 8.0),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () async {
                          dateOnTapSelection(indexMonth, index);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: daysOfMonth[indexMonth][index]
                                  .backgroundSelectedColor,
                              borderRadius: daysOfMonth[indexMonth][index]
                                  .backgroundBorderRadius),
                          child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                  color: daysOfMonth[indexMonth][index]
                                      .selectedColor,
                                  borderRadius: daysOfMonth[indexMonth][index]
                                      .borderRadius),
                              child: Center(
                                  child: Text(
                                "${daysOfMonth[indexMonth][index].day}",
                                style: TextStyle(
                                    color: daysOfMonth[indexMonth][index]
                                        .selectedTextColor,
                                    fontSize: 14),
                              ))),
                        ));
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void setColorToDay(indexMonth, index) {
    daysOfMonth[indexMonth][index].selectedColor =
        widget.rangeStartEndBackgroundColor;
    daysOfMonth[indexMonth][index].backgroundSelectedColor =
        widget.innerRangeBackgroundColor;

    daysOfMonth[indexMonth][index].selectedTextColor = Colors.white;
  }

  void setColorLightBlueToDay(indexMonth, index) {
    if (daysOfMonth[indexMonth][index].day != "") {
      int beforeIndex = index - 1;
      if (beforeIndex < 0) {
        beforeIndex = 0;
      }
      int afterIndex = index + 1;
      if (afterIndex > daysOfMonth[indexMonth].length - 1) {
        afterIndex = daysOfMonth[indexMonth].length - 1;
      }
      if ([0, 7, 14, 21, 28].contains(index) ||
          daysOfMonth[indexMonth][beforeIndex].day == "" ||
          daysOfMonth[indexMonth][beforeIndex].day == null) {
        daysOfMonth[indexMonth][index].borderRadius = BorderRadius.only(
            topLeft: Radius.circular(30), bottomLeft: Radius.circular(30));
      } else if ([6, 13, 20, 27, 34].contains(index) ||
          index == afterIndex) {
        daysOfMonth[indexMonth][index].borderRadius = BorderRadius.only(
            topRight: Radius.circular(30), bottomRight: Radius.circular(30));
      } else {
        daysOfMonth[indexMonth][index].borderRadius =
            BorderRadius.all(Radius.circular(0));
      }

      daysOfMonth[indexMonth][index].selectedColor =
          widget.innerRangeBackgroundColor;
      daysOfMonth[indexMonth][index].selectedTextColor =
          widget.selectionFontColor;
    }
  }

  void backToNormal(indexMonth, dayIndex) {
    daysOfMonth[indexMonth][dayIndex].selectedColor = Colors.white;
    daysOfMonth[indexMonth][dayIndex].selectedTextColor =
        widget.selectionFontColor;
    daysOfMonth[indexMonth][dayIndex].backgroundSelectedColor =
        Colors.transparent;
    daysOfMonth[indexMonth][dayIndex].borderRadius =
        BorderRadius.all(Radius.circular(30));
    daysOfMonth[indexMonth][dayIndex].backgroundBorderRadius =
        BorderRadius.all(Radius.circular(30));
  }

  void showRangeSelection() {
    print("startMonthIndex: "+ startMonthIndex.toString());
    print("endMonthIndex: "+ endMonthIndex.toString());

    if (startMonthIndex == endMonthIndex) {
      /* birthday, future years, booking*/
      int tempDate = startDayIndex;
      print("object");
      while (tempDate != endDayIndex) {
        if (startDayIndex != tempDate)
          setColorLightBlueToDay(startMonthIndex, tempDate);
        else {
          daysOfMonth[startMonthIndex][tempDate].borderRadius =
              BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30));
          daysOfMonth[startMonthIndex][tempDate].backgroundBorderRadius =
              BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(0));
        }
        tempDate++;
      }
    } else {
      /*booking_range*/
      int tempStartDayIndex = startDayIndex;
      int tempStartMonthIndex = startMonthIndex;
      for (int j = tempStartDayIndex;
          j < daysOfMonth[tempStartMonthIndex].length;
          j++) {
        if (j != tempStartDayIndex)
          setColorLightBlueToDay(tempStartMonthIndex, j);
        else
          daysOfMonth[tempStartMonthIndex][j].borderRadius = BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30));
        daysOfMonth[startMonthIndex][startDayIndex].backgroundBorderRadius =
            BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0));
      }
      tempStartMonthIndex = tempStartMonthIndex + 1;

      while (tempStartMonthIndex != endMonthIndex) {
        for (int k = 0; k < daysOfMonth[tempStartMonthIndex].length; k++) {
          setColorLightBlueToDay(tempStartMonthIndex, k);
        }
        tempStartMonthIndex++;
      }

      for (int l = 0; l < endDayIndex; l++) {
        setColorLightBlueToDay(tempStartMonthIndex, l);
      }
    }
  }

  void firstTapOnly(indexMonth, index) {
    if (daysOfMonth[indexMonth][index].day != "" &&
        daysOfMonth[indexMonth][index].selectedTextColor != Colors.black12) {
      startDateTime = dateFormat.parse(
          "${daysOfMonth[indexMonth][index].day}-${daysOfMonth[indexMonth][index].month}-${daysOfMonth[indexMonth][index].year}");

      selectedDate = "";
      selectedDate =
          "${daysOfMonth[indexMonth][index].day}/${daysOfMonth[indexMonth][index].month}/${daysOfMonth[indexMonth][index].year}";
      setColorToDay(indexMonth, index);
      startMonthIndex = indexMonth;
      startDayIndex = index;
      lastSelectedMonth = indexMonth;
      lastSelectedDay = index;
      tempStartMonthIndex = indexMonth;
      tapIncrement = tapIncrement + 1;
    }
  }

  void dateOnTapSelection(indexMonth, index) {
    setState(() {
      if (rangeDate) {
        if (tapIncrement == 1) {
          firstTapOnly(indexMonth, index);
        } else if (tapIncrement == 2) {
          if (daysOfMonth[indexMonth][index].day != "" &&
              daysOfMonth[indexMonth][index].selectedTextColor !=
                  Colors.black12) {
            endMonthIndex = indexMonth;
            endDayIndex = index;

            DateTime endDateTime = dateFormat.parse(
                "${daysOfMonth[indexMonth][index].day}-${daysOfMonth[indexMonth][index].month}-${daysOfMonth[indexMonth][index].year}");

//            bool isAfterStatDate=endDateTime.isAfter(startDateTime);
            bool isAfterStartDate = startDateTime.isBefore(endDateTime);
            if (isAfterStartDate) {
              selectedDate +=
                  "  ${daysOfMonth[indexMonth][index].day}/${daysOfMonth[indexMonth][index].month}/${daysOfMonth[indexMonth][index].year}";
              setColorToDay(indexMonth, index);
              daysOfMonth[indexMonth][index].borderRadius = BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30));
              daysOfMonth[indexMonth][index].backgroundBorderRadius =
                  BorderRadius.only(
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30));

              showRangeSelection();
              tapIncrement = tapIncrement + 1;
            } else {
              if (daysOfMonth[indexMonth][index].day != "" &&
                  daysOfMonth[indexMonth][index].selectedTextColor !=
                      Colors.black12) {
                daysOfMonth[lastSelectedMonth][lastSelectedDay].selectedColor =
                    Colors.white;
                daysOfMonth[lastSelectedMonth][lastSelectedDay]
                    .selectedTextColor = Colors.black;
                tapIncrement = 1;
                firstTapOnly(indexMonth, index);
              }
            }
          }
        } else if (tapIncrement == 3) {
          if (daysOfMonth[indexMonth][index].day != "" &&
              daysOfMonth[indexMonth][index].selectedTextColor !=
                  Colors.black12) {
            for (int i = 0; i < daysOfMonth[tempStartMonthIndex].length; i++) {
              backToNormal(tempStartMonthIndex, i);
            }

            while (tempStartMonthIndex != endMonthIndex) {
              for (int k = 0;
                  k < daysOfMonth[tempStartMonthIndex].length;
                  k++) {
                backToNormal(tempStartMonthIndex, k);
              }
              tempStartMonthIndex++;
            }

            for (int l = 0; l < endDayIndex + 1; l++) {
              backToNormal(tempStartMonthIndex, l);
            }

            tapIncrement = 1;
            firstTapOnly(indexMonth, index);
          }
        }
      } else {
        if (daysOfMonth[indexMonth][index].day != "" &&
            daysOfMonth[indexMonth][index].selectedTextColor !=
                Colors.black12) {
          daysOfMonth[indexMonth][index].selectedColor =
              widget.selectionBackgroundColor;
          daysOfMonth[indexMonth][index].selectedTextColor =
              widget.selectionFontColor;
          selectedDate =
              "${daysOfMonth[indexMonth][index].day}/${daysOfMonth[indexMonth][index].month}/${daysOfMonth[indexMonth][index].year}";
          if (isLastSelected) {
            daysOfMonth[lastSelectedMonth][lastSelectedDay].selectedColor =
                Colors.white;
            daysOfMonth[lastSelectedMonth][lastSelectedDay].selectedTextColor =
                Colors.black;
          }
          isLastSelected = true;
          lastSelectedDay = index;
          lastSelectedMonth = indexMonth;
        }
      }
    });
  }

  void determineLeapYear(int year) {
    if (year % 4 == 0 && year % 100 != 0 || year % 400 == 0) {
      days_in_month[2] = 29;
    } else {
      days_in_month[2] = 28;
    }
  }

  calendarMonth(int year, indexMonth) async {
    List<DayMonthDetailModel> dmdmList = List();
    int month = indexMonth, day;
    dayCode = dayOfWeek(1, month, year);
    if (indexMonth == 2) {
      determineLeapYear(selectedYear);
    }
    // Correct the position for the first date
    for (day = 1; day <= dayCode; day++) {
      DayMonthDetailModel localDMDM = DayMonthDetailModel();
      localDMDM.day = "";
      localDMDM.month = 0;
      localDMDM.weekDay = "";
      dmdmList.add(localDMDM);
    }

    // Print all the dates for one month
    for (day = 1; day <= days_in_month[month]; day++) {
      DayMonthDetailModel localDMDM = DayMonthDetailModel();
      localDMDM.day = day;
      localDMDM.month = month;
      localDMDM.year = year;
      DateTime eachDate = dateFormat.parse("$day-$indexMonth-$year");
      if (Calendar.BOOKING_RANGE == widget.type) {
        if (eachDate.isBefore(DateTime.now())) {
          localDMDM.selectedTextColor = Colors.black12;
        }
      } else if (Calendar.BIRTHDAY == widget.type) {
        if (eachDate.isAfter(DateTime.now())) {
          localDMDM.selectedTextColor = Colors.black12;
        }
      }

      // current date start
//      if (DateTime.now().month == indexMonth && DateTime.now().day == day) {
//        localDMDM.selectedColor = widget.currentDateBackgroundColor;
//        localDMDM.selectedTextColor = widget.currentDateFontColor;
//        currentMonth = indexMonth.toDouble();
//      }
      //current date end

      dmdmList.add(localDMDM);
    }
    // Set position for next month
    dayCodeList.add(dayCode);
    daysOfMonth.add(dmdmList);
  }

  int dayOfWeek(int d, int m, int y) {
    List<int> t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
    y -= (m < 3) ? 1 : 0;
    return (y +
            (y / 4).floor() -
            (y / 100).floor() +
            (y / 400).floor() +
            t[m - 1] +
            d) %
        7;
  }

  @override
  void yearResult(int year) {
    setState(() {
      selectedYear = year;
      daysOfMonth.clear();
      determineLeapYear(selectedYear);
      dayCodeList.clear();
      for (int i = 1; i <= 12; i++) {
        calendarMonth(selectedYear, i);
      }
    });
  }
}

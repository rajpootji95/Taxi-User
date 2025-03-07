import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:why_taxi_user/BookRide/payment_dailog.dart';
import 'package:why_taxi_user/BookRide/rate_ride_dialog.dart';
import 'package:why_taxi_user/BookRide/search_location_page.dart';
import 'package:why_taxi_user/Components/entry_field.dart';
import 'package:why_taxi_user/DrawerPages/Rides/ride_info_page.dart';
import 'package:why_taxi_user/Model/latlng_model.dart';
import 'package:why_taxi_user/Model/my_ride_model.dart';
import 'package:why_taxi_user/Model/reason_model.dart';
import 'package:why_taxi_user/Model/rides_model.dart';
import 'package:why_taxi_user/Theme/style.dart';
import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/PushNotificationService.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/colors.dart';
import 'package:why_taxi_user/utils/common.dart';
import 'package:why_taxi_user/utils/referCodeService.dart';
import 'package:why_taxi_user/utils/widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:why_taxi_user/Assets/assets.dart';
import 'package:why_taxi_user/Locale/locale.dart';
import 'package:why_taxi_user/Locale/strings_enum.dart';
import 'package:why_taxi_user/Routes/page_routes.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:social_share/social_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../utils/constant.dart';

class RentalRides extends StatefulWidget {
  final bool selected;
  const RentalRides({Key? key, this.selected = true}) : super(key: key);
  @override
  State<RentalRides> createState() => _RentalRidesState();
}

class _RentalRidesState extends State<RentalRides> {
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = true;
  bool loading1 = true;
  List<MyRideModel> rideList = [];
  String km = "", time = "";
  int? indexSelected;
  double driveLat = 0, driveLng = 0;
  Timer? timer;
  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  getRides(type) async {
    try {
      setState(() {
        loading = true;
      });
      Map params = {
        "user_id": curUserId,
        "type": type,
      };

      print("ALL COMPLETE RIDE PARAM ====== $params");
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/rental_Bookint_by_user_id"), params);
      setState(() {
        loading = false;
        rideList.clear();
        _globalKey.clear();
      });
      if (response['status']) {
        print(response['data']);
        for (var v in response['data']) {
          setState(() {
            rideList.add(MyRideModel.fromJson(v));
            _globalKey.add(new GlobalKey());
          });
        }
        print("RideStatus${rideList.first.acceptReject}");
        if (type == "1") {
          indexSelected =
              rideList.indexWhere((element) => element.acceptReject == "6");
          if (indexSelected != -1) {
            if (timer != null) {
              timer!.cancel();
            }
            timer = Timer.periodic(Duration(seconds: 10), (timer) {
              if (rideList.length > 0) {
                getDriver(rideList[indexSelected!].driverId);
              }
            });
          }
        }
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selected != null) {
      setState(() {
        selected = widget.selected!;
      });
    }
    if (widget.selected) {
      getRides("3");
    } else {
      getRides("1");
    }
    PushNotificationService notificationService = new PushNotificationService(
        context: context,
        onResult: (result) {
          if (selected) {
            getRides("3");
          } else {
            getRides("1");
          }
        });
    notificationService.initialise();
    getReason();
    getRides("3");
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getDriver(String? driverId) async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "driver_id": driverId.toString(),
        };
        Map response = await apiBase.postAPICall(
            Uri.parse(baseUrl1 + "Payment/get_driver_details"), data);
        if (indexSelected != null &&
            indexSelected != -1 &&
            rideList.length > 0) {
          Map data1 = {
            "booking_id": rideList[indexSelected!].bookingId.toString(),
          };
          Map response1 = await apiBase.postAPICall(
              Uri.parse(baseUrl1 + "Payment/driver_latitude_logitude"), data1);
          print(response1);
          List<LatLngModel> tempList = [];
          if (response1['status']) {
            for (var v in response1['booking_id']) {
              tempList.add(LatLngModel.fromJson(v));
            }
            double totalDistance = 0;
            for (var i = 0; i < tempList.length - 1; i++) {
              totalDistance += calculateDistance(tempList[i].lat,
                  tempList[i].lang, tempList[i + 1].lat, tempList[i + 1].lang);
            }
            km = totalDistance.toStringAsFixed(2);
            print("total" + totalDistance.toString());
          }
        }
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        // UI.setSnackBar(msg, context);
        if (response['status']) {
          Map data = response['data'];
          if (mounted)
            setState(() {
              driveLat = double.parse(data['latitude']);
              driveLng = double.parse(data['longitude']);
              print(indexSelected);
              if (indexSelected != null &&
                  indexSelected != -1 &&
                  rideList.length > 0) {
                List<String> calTime =
                    rideList[indexSelected!].start_time!.split(":");
                DateTime firstTime = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    int.parse(calTime[0]),
                    int.parse(calTime[1]));
                print(calTime.toString());
                time = durationToString(
                    DateTime.now().difference(firstTime).inMinutes);
              }
            });
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  bool selected = true;

  List<String> filter = ["All", "Today", "Weekly", "Monthly"];
  String selectedFil = "All";

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }

  Future<bool> onWill() {
    Navigator.pop(context, true);
    /* Navigator.popUntil(
      context,
      ModalRoute.withName('/'),
    );*/
    /*Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SearchLocationPage()),
        (route) => false);*/

    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: onWill,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: getWidth(375),
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  getTranslated(context, 'MY_RIDES')!,
                  style: theme.textTheme.headline4,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                width: getWidth(375),
                child: Text(
                  getTranslated(context, 'LIST_OF_RIDES')!,
                  style: theme.textTheme.bodyText2!
                      .copyWith(color: theme.hintColor, fontSize: 12),
                ),
              ),
              Container(
                width: getWidth(322.1),
                decoration: boxDecoration(
                  bgColor: Colors.white,
                  radius: 10,
                  showShadow: true,
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          selected = true;
                        });
                        getRides("3");
                      },
                      child: Container(
                        height: getHeight(49),
                        width: getWidth(160),
                        decoration: selected
                            ? BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(52, 61, 164, 139),
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 8.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).primaryColor,
                              )
                            : BoxDecoration(),
                        child: Center(
                          child: text(
                            getTranslated(context, "COMPLETED")!,
                            fontFamily: fontSemibold,
                            fontSize: 11.sp,
                            textColor:
                                selected ? Colors.white : Color(0xff37778A),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selected = false;
                        });
                        getRides("1");
                      },
                      child: Container(
                        height: getHeight(49),
                        width: getWidth(160),
                        decoration: !selected
                            ? BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(52, 61, 164, 139),
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 8.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).primaryColor,
                              )
                            : BoxDecoration(),
                        child: Center(
                          child: text(
                            getTranslated(context, "UPCOMING")!,
                            fontFamily: fontSemibold,
                            fontSize: 11.sp,
                            textColor:
                                !selected ? Colors.white : Color(0xff37778A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              boxHeight(19),
              Wrap(
                spacing: 3.w,
                children: filter.map((e) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedFil = e.toString();
                      });
                      var now = new DateTime.now();
                      var now_1w = now.subtract(Duration(days: 7));
                      var now_1m =
                          new DateTime(now.year, now.month - 1, now.day);
                      if (selectedFil == "Today") {
                        for (int i = 0; i < rideList.length; i++) {
                          DateTime date = DateTime.parse(
                              rideList[i].createdDate.toString());
                          if (now.day == date.day && now.month == date.month) {
                            setState(() {
                              rideList[i].show = true;
                            });
                          } else {
                            setState(() {
                              rideList[i].show = false;
                            });
                          }
                        }
                      }
                      if (selectedFil == "Weekly") {
                        for (int i = 0; i < rideList.length; i++) {
                          DateTime date = DateTime.parse(
                              rideList[i].createdDate.toString());
                          if (now_1w.isBefore(date)) {
                            setState(() {
                              rideList[i].show = true;
                            });
                          } else {
                            setState(() {
                              rideList[i].show = false;
                            });
                          }
                        }
                      }
                      if (selectedFil == "Monthly") {
                        for (int i = 0; i < rideList.length; i++) {
                          DateTime date = DateTime.parse(
                              rideList[i].createdDate.toString());
                          if (now_1m.isBefore(date)) {
                            setState(() {
                              rideList[i].show = true;
                            });
                          } else {
                            setState(() {
                              rideList[i].show = false;
                            });
                          }
                        }
                      }
                      if (selectedFil == "All") {
                        for (int i = 0; i < rideList.length; i++) {
                          setState(() {
                            rideList[i].show = true;
                          });
                        }
                      }
                    },
                    child: Chip(
                      side: BorderSide(color: MyColorName.primaryLite),
                      backgroundColor: selectedFil == e
                          ? MyColorName.primaryLite
                          : Colors.transparent,
                      shadowColor: Colors.transparent,
                      label: text(e,
                          fontFamily: fontMedium,
                          fontSize: 10.sp,
                          textColor:
                          selectedFil == e ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
              ),
              boxHeight(19),
              !loading
                  ? rideList.length > 0
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: rideList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => rideList[index]
                                          .status !=
                                      "Cancelled" &&
                                  rideList[index].show!
                              ? GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (context) =>
                                            PaymentDialog(rideList[index],from: true,));
                                    /*   var result =await Navigator.push(context, MaterialPageRoute(builder: (
                          context) => RideInfoPage(rideList[index])));
                      if(result!=null){
                        selected ? getRides("3") : getRides("1");
                      }*/
                                  },
                                  child: Container(
                                    decoration: boxDecoration(
                                        bgColor: Colors.white,
                                        showShadow: true,
                                        radius: 10),
                                    margin: EdgeInsets.all(5.0),
                                    child: Column(
                                      children: [
                                        RepaintBoundary(
                                          key: _globalKey[index],
                                          child: Container(
                                            decoration: boxDecoration(
                                                bgColor: Colors.white,
                                                radius: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                indexSelected != null &&
                                                        indexSelected != -1 &&
                                                        indexSelected == index
                                                    ? Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5,
                                                                horizontal: 5),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Time- $time/min.',
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyText1,
                                                            ),
                                                            Text(
                                                              'Km- $km/Km.',
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyText1,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Extra Time- \u{20B9}${rideList[index].extra_time_charge.toString()}/min.',
                                                        style: theme.textTheme
                                                            .bodyText1,
                                                      ),
                                                      Text(
                                                        'Extra Km- \u{20B9}${rideList[index].extra_km_charge.toString()}/Km.',
                                                        style: theme.textTheme
                                                            .bodyText1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Divider(),
                                                Container(
                                                  height: 100,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 14),
                                                  child: Row(
                                                    children: [
                                                      rideList[index]
                                                                  .driverName !=
                                                              null
                                                          ? Container(
                                                              height: 60,
                                                              width: 60,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Image.network(imagePath +
                                                                    rideList[
                                                                            index]
                                                                        .driverImage
                                                                        .toString()),
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            rideList[index]
                                                                .driverName !=
                                                                null
                                                                ? Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    '${rideList[index].driverName}',
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodyText2,
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                    onTap:
                                                                        () {
                                                                      showDialog(context: context, builder: (context)=>AlertDialog(
                                                                        title: Text("Confirmation"),
                                                                        content: Text("Do you want to confirm call?"),
                                                                        actions: [
                                                                          TextButton(onPressed: (){
                                                                            Navigator.pop(context);
                                                                          }, child: Text("Cancel")),
                                                                          TextButton(onPressed: (){
                                                                            Navigator.pop(context);
                                                                            launch(
                                                                                "tel://${rideList[index].driverContact}");
                                                                          }, child: Text("Confirm")),
                                                                        ],
                                                                      ));
                                                                    },
                                                                    child: Icon(Icons
                                                                        .call,color: AppTheme.primaryColor,)),
                                                              ],
                                                            )
                                                                : Text(
                                                              '${getTranslated(context, "TRIP_ID")} - ${rideList[index].uneaqueId.toString()}',
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyText1,
                                                            ),
                                                            rideList[index]
                                                                        .driverName !=
                                                                    null
                                                                ? Text(
                                                                    '${getTranslated(context, "TRIP_ID")} - ${rideList[index].uneaqueId.toString()}',
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodyText1,
                                                                  )
                                                                : SizedBox(),
                                                            Spacer(flex: 2),
                                                            Container(
                                                              width:
                                                                  getWidth(150),
                                                              child: Text(
                                                                '${rideList[index].hours} mins\n${rideList[index].dateAdded}',
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: theme
                                                                    .textTheme
                                                                    .caption,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              '\u{20B9}${rideList[index].amount}',
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyText2!
                                                                  .copyWith(
                                                                      color: theme
                                                                          .primaryColor),
                                                            ),
                                                            Spacer(flex: 2),
                                                            rideList[index]
                                                                        .bookingType ==
                                                                    "Rental Booking"
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Text(
                                                                    "${rideList[index].transaction}",
                                                                    // + '\n' +
                                                                    // "${rideList[index].bookingType}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style: theme
                                                                        .textTheme
                                                                        .caption,
                                                                  ),
                                                            Text(
                                                              rideList[index]
                                                                          .acceptReject ==
                                                                      "6"
                                                                  ? "Trip End OTP : ${rideList[index].bookingOtp.toString()}"
                                                                  : "Start OTP : ${rideList[index].bookingOtp.toString()}",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      Colors.blue,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "${rideList[index].bookingType}",
                                                              textAlign:
                                                                  TextAlign.right,
                                                              style: theme
                                                                  .textTheme
                                                                  .caption,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ListTile(
                                                  horizontalTitleGap: 0,
                                                  leading: Icon(
                                                    Icons.location_on,
                                                    color: theme.primaryColor,
                                                    size: 20,
                                                  ),
                                                  title: Text(
                                                    '${rideList[index].pickupAddress}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  dense: true,
                                                  tileColor: theme.cardColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                        !rideList[index]
                                                .bookingType!
                                                .contains("Point")
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AnimatedTextKit(
                                                    animatedTexts: [
                                                      ColorizeAnimatedText(
                                                        rideList[index]
                                                                .bookingType
                                                                .toString()
                                                                .contains(
                                                                    "Rental Booking")
                                                            ? "Rental Booking\n${rideList[index].start_time} - ${rideList[index].end_time}"
                                                            : "${getTranslated(context, "SCHEDULE")} - ${rideList[index].pickupDate} ${rideList[index].pickupTime}",
                                                        textStyle:
                                                            colorizeTextStyle,
                                                        colors: colorizeColors,
                                                      ),
                                                    ],
                                                    pause: Duration(
                                                        milliseconds: 100),
                                                    isRepeatingAnimation: true,
                                                    totalRepeatCount: 100,
                                                    onTap: () {
                                                      print("Tap Event");
                                                    },
                                                  ),
                                                  AnimatedTextKit(
                                                    animatedTexts: [
                                                      ColorizeAnimatedText(
                                                        rideList[index]
                                                                .bookingType
                                                                .toString()
                                                                .contains(
                                                                    "Rental Booking")
                                                            ? "Allow Time/KM\n${rideList[index].hours}min. - ${rideList[index].km}KM"
                                                            : "",
                                                        textStyle:
                                                            colorizeTextStyle,
                                                        colors: colorizeColors,
                                                      ),
                                                    ],
                                                    pause: Duration(
                                                        milliseconds: 100),
                                                    isRepeatingAnimation: true,
                                                    totalRepeatCount: 100,
                                                    onTap: () {
                                                      print("Tap Event");
                                                    },
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                        /* !rideList[index].bookingType!.contains("Point")?Text(
                            'Schedule - ${rideList[index].pickupDate} ${rideList[index].pickupTime}',
                            style: theme.textTheme.bodyText2,
                          ):SizedBox(),*/
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            selected
                                                ? InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              RateRideDialog(
                                                                rideList[index],
                                                                check: true,
                                                              ));
                                                      // showBottom(rideList[index].driverId,rideList[index].bookingId);
                                                    },
                                                    child: Container(
                                                      width: 30.w,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 16),
                                                      height: 5.h,
                                                      decoration: boxDecoration(
                                                          radius: 5,
                                                          bgColor: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                      child: Center(
                                                          child: loading1
                                                              ? text(
                                                                  getTranslated(
                                                                      context,
                                                                      "RATING")!,
                                                                  fontFamily:
                                                                      fontMedium,
                                                                  fontSize:
                                                                      10.sp,
                                                                  isCentered:
                                                                      true,
                                                                  textColor:
                                                                      Colors
                                                                          .white)
                                                              : CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                    ),
                                                  )
                                                : rideList[index]
                                                            .acceptReject ==
                                                        "1"
                                                    ? InkWell(
                                                        onTap: () {
                                                          showBottom1(
                                                              rideList[index]
                                                                  .id,
                                                              rideList[index]
                                                                  .createdDate,
                                                              index);
                                                        },
                                                        child: Container(
                                                          width: 30.w,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      16),
                                                          height: 5.h,
                                                          decoration: boxDecoration(
                                                              radius: 5,
                                                              bgColor: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          child: Center(
                                                              child: loading1
                                                                  ? text(
                                                                      getTranslated(context,
                                                                          "CANCEL")!,
                                                                      fontFamily:
                                                                          fontMedium,
                                                                      fontSize:
                                                                          10.sp,
                                                                      isCentered:
                                                                          true,
                                                                      textColor:
                                                                          Colors
                                                                              .white)
                                                                  : CircularProgressIndicator(
                                                                      color: Colors
                                                                          .white,
                                                                    )),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                            rideList[index].payment_status !=
                                                    "1"
                                                ? InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        loading1 = false;
                                                      });
                                                      final dynamicLinkParams =
                                                          DynamicLinkParameters(
                                                        link: Uri.parse(
                                                            "https://alphataxi.productsalphawizz.com/?${rideList[index].bookingId}"),
                                                        uriPrefix:
                                                            "https://sahayatri.page.link",
                                                        androidParameters:
                                                            const AndroidParameters(
                                                                packageName:
                                                                    "com.delcab.user"),
                                                        iosParameters:
                                                            const IOSParameters(
                                                                bundleId:
                                                                    "com.delcab.user"),
                                                      );
                                                      FirebaseDynamicLinks
                                                          .instance
                                                          .buildShortLink(
                                                              dynamicLinkParams)
                                                          .then(
                                                              (ShortDynamicLink
                                                                  value) {
                                                        print(value.shortUrl);
                                                        capturePng(index,
                                                            value.shortUrl);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 30.w,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 16),
                                                      height: 5.h,
                                                      decoration: boxDecoration(
                                                          radius: 5,
                                                          bgColor: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                      child: Center(
                                                          child: loading1
                                                              ? text(
                                                                  getTranslated(
                                                                      context,
                                                                      "SHARE")!,
                                                                  fontFamily:
                                                                      fontMedium,
                                                                  fontSize:
                                                                      10.sp,
                                                                  isCentered:
                                                                      true,
                                                                  textColor:
                                                                      Colors
                                                                          .white)
                                                              : CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                    ),
                                                  )
                                                : selected
                                                    ? InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  PaymentDialog(
                                                                      rideList[
                                                                          index]));
                                                        },
                                                        child: Container(
                                                          width: 30.w,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      16),
                                                          height: 5.h,
                                                          decoration: boxDecoration(
                                                              radius: 5,
                                                              bgColor: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          child: Center(
                                                              child: loading1
                                                                  ? text("Pay",
                                                                      fontFamily:
                                                                          fontMedium,
                                                                      fontSize:
                                                                          10.sp,
                                                                      isCentered:
                                                                          true,
                                                                      textColor:
                                                                          Colors
                                                                              .white)
                                                                  : CircularProgressIndicator(
                                                                      color: Colors
                                                                          .white,
                                                                    )),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                          ],
                                        ),

                                        Padding(padding: EdgeInsets.all(8.0),child: Text("Tap For More Info"),),
                                        SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        )
                      : Center(
                          child: text(getTranslated(context, "NO_RIDES")!,
                              fontFamily: fontMedium,
                              fontSize: 12.sp,
                              textColor: Colors.black),
                        )
                  : Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  final colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  final colorizeTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w900,
    fontFamily: 'Inter',
  );
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  PersistentBottomSheetController? controller;
  double rating = 4.0;
  TextEditingController desCon = new TextEditingController();
  showBottom(driverId, bookingId) async {
    controller = await scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rate Driver",
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            RatingBar(
              initialRating: rating,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 36,
              ratingWidget: RatingWidget(
                full: Icon(
                  Icons.star,
                  color: AppTheme.primaryColor,
                ),
                half: Icon(
                  Icons.star_half_rounded,
                  color: AppTheme.primaryColor,
                ),
                empty: Icon(
                  Icons.star_border_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              itemPadding: EdgeInsets.zero,
              onRatingUpdate: (rating1) {
                print(rating1);
                controller!.setState!(() {
                  rating = rating1;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            EntryField(
              controller: desCon,
              keyboardType: TextInputType.name,
              label: "Write Comment",
            ),
            SizedBox(
              height: 10,
            ),
            !status
                ? InkWell(
                    onTap: () {
                      controller!.setState!(() {
                        status = true;
                      });
                      rateOrder(driverId, bookingId);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: MyColorName.primaryDark.withOpacity(0.5),
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Rate Booking",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )
          ],
        ),
      );
    });
  }

  bool status = false;
  rateOrder(driverId, bookingId) async {
    await App.init();
    Map param = {
      "driver_id": driverId,
      "comments": desCon.text,
      "booking_id": bookingId,
      "rating": rating.toString(),
      "user_id": curUserId,
    };
    Map response = await apiBase.postAPICall(
        Uri.parse(baseUrl1 + "payment/AddReviews"), param);
    controller!.setState!(() {
      status = false;
    });
    UI.setSnackBar(response['message'], context);
    if (response['status']) {
      Navigator.pop(context, "yes");
      Navigator.pop(context, "yes");
    }
  }

  List<GlobalKey> _globalKey = [];

  Future<String> capturePng(i, url) async {
    try {
      print('inside');
      RenderRepaintBoundary? boundary = _globalKey[i]
          .currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      print(pngBytes);
      String dir = (await getApplicationSupportDirectory()).path;
      File? file = File(
          "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".png");
      await file.writeAsBytes(pngBytes);
      setState(() {
        loading1 = true;
      });
      SocialShare.shareOptions("${url}", imagePath: file.path);
      return file.path;
    } catch (e) {
      print(e);
    }
    return "";
  }

  bool acceptStatus = false;
  List<ReasonModel> reasonList = [];
  getReason() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "type": "User",
        };
        Map response = await apiBase.postAPICall(
            Uri.parse(baseUrl1 + "payment/cancel_ride_reason"), data);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          for (var v in response['data']) {
            setState(() {
              reasonList.add(new ReasonModel.fromJson(v));
            });
          }
          //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> OfflinePage("")), (route) => false);
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  cancelStatus(String bookingId, status1) async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "type": "schedule_booking",
          "booking_time": status1,
          "accept_reject": "4",
          "booking_id": bookingId,
          "reason": reasonList[indexReason].reason,
        };
        Map response = await apiBase.postAPICall(
            Uri.parse(baseUrl1 + "Payment/cancel_ride_user_driver"), data);
        print(response);
        print(response);
        setState(() {
          acceptStatus = false;
        });
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          Navigator.pop(context, true);
          /*Navigator.popUntil(
            context,
            ModalRoute.withName('/'),
          );*/
          /*Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SearchLocationPage()),
              (route) => false);*/
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  int indexReason = 0;
  PersistentBottomSheetController? persistentBottomSheetController1;
  getDifference(index) {
    String date = rideList[index].pickupDate.toString();
    DateTime temp = DateTime.parse(date.replaceAll(" ", ""));
    if (temp.day == DateTime.now().day) {
      String time = rideList[index].pickupTime.toString().split(" ")[0];
      DateTime temp = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          int.parse(time.split(":")[0]),
          int.parse(time.split(":")[1]));
      print(int.parse(cancelTime) < temp.difference(DateTime.now()).inHours);
      return int.parse(cancelTime) > temp.difference(DateTime.now()).inHours;
    } else {
      print(false);
      return false;
    }
  }

  showBottom1(id, date, index) async {
    persistentBottomSheetController1 =
        await scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        decoration:
            boxDecoration(radius: 0, showShadow: true, color: Colors.white),
        padding: EdgeInsets.all(getWidth(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(getWidth(10)),
              color: Colors.white,
              child: Column(
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        "Cancellation Charge ₹${rideList[index].cancel_charge} will be deducted from the wallet.",
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                    ],
                    pause: Duration(milliseconds: 100),
                    isRepeatingAnimation: true,
                    totalRepeatCount: 100,
                    onTap: () {
                      print("Tap Event");
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "This charge is deducted from your wallet",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            //  Text("OTP : ${rideList[index].bookingOtp}"),
            boxHeight(20),
            text("${getTranslated(context, "SELECT_REASON")}",
                textColor: MyColorName.colorTextPrimary,
                fontSize: 12.sp,
                fontFamily: fontBold),
            boxHeight(20),
            reasonList.length > 0
                ? Container(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: reasonList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              persistentBottomSheetController1!.setState!(() {
                                indexReason = index;
                              });
                              // Navigator.pop(context);
                            },
                            child: Container(
                              color: indexReason == index
                                  ? MyColorName.primaryLite.withOpacity(0.2)
                                  : Colors.white,
                              padding: EdgeInsets.all(getWidth(10)),
                              child: text(reasonList[index].reason.toString(),
                                  textColor: MyColorName.colorTextPrimary,
                                  fontSize: 10.sp,
                                  fontFamily: fontMedium,
                                  isLongText: true),
                            ),
                          );
                        }),
                  )
                : SizedBox(),
            boxHeight(20),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 35.w,
                    height: 5.h,
                    margin: EdgeInsets.all(getWidth(14)),
                    decoration: boxDecoration(
                        radius: 5, bgColor: Theme.of(context).primaryColor),
                    child: Center(
                        child: text(getTranslated(context, "BACK")!,
                            fontFamily: fontMedium,
                            fontSize: 10.sp,
                            isCentered: true,
                            textColor: Colors.white)),
                  ),
                ),
                boxWidth(10),
                InkWell(
                  onTap: () {
                    persistentBottomSheetController1!.setState!(() {
                      acceptStatus = true;
                    });
                    cancelStatus(id, date);
                  },
                  child: !acceptStatus
                      ? Container(
                          width: 35.w,
                          height: 5.h,
                          margin: EdgeInsets.all(getWidth(14)),
                          decoration: boxDecoration(
                              radius: 5,
                              bgColor: Theme.of(context).primaryColor),
                          child: Center(
                              child: text(getTranslated(context, "CONTINUE")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        )
                      : CircularProgressIndicator(),
                ),
              ],
            ),
            boxHeight(40),
          ],
        ),
      );
    });
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:why_taxi_user/Auth/Login/UI/login_page.dart';
import 'package:why_taxi_user/BookRide/search_location_page.dart';
import 'package:why_taxi_user/DrawerPages/ChangePassword/change_password.dart';
import 'package:why_taxi_user/DrawerPages/ContactUs/contact_us_page.dart';
import 'package:why_taxi_user/DrawerPages/Profile/profile_page.dart';
import 'package:why_taxi_user/DrawerPages/Profile/reviews.dart';
import 'package:why_taxi_user/DrawerPages/PromoCode/promo_code_page.dart';
import 'package:why_taxi_user/DrawerPages/ReferEarn/refer_earn.dart';

import 'package:why_taxi_user/DrawerPages/Rides/intercity_rides.dart';
import 'package:why_taxi_user/DrawerPages/Rides/my_rides_page.dart';
import 'package:why_taxi_user/DrawerPages/Rides/rental_rides.dart';
import 'package:why_taxi_user/DrawerPages/Settings/settings_page.dart';
import 'package:why_taxi_user/DrawerPages/Wallet/wallet_page.dart';
import 'package:why_taxi_user/DrawerPages/faq_page.dart';
import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/colors.dart';
import 'package:why_taxi_user/utils/common.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:why_taxi_user/Assets/assets.dart';
import 'package:why_taxi_user/Locale/strings_enum.dart';
import 'package:why_taxi_user/Routes/page_routes.dart';
import 'package:why_taxi_user/Theme/style.dart';
import 'package:why_taxi_user/Locale/locale.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AppDrawer extends StatefulWidget {
  final bool fromHome;
  ValueChanged onResult;
  AppDrawer({this.fromHome = true, required this.onResult});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //addArray([1000, 100, 1000, 10, 100, 1, 5]);
    //getNumber();
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;

  void addArray(List<int> arr) {
    int index = 0;
    int total = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i + 1 < arr.length && arr[i] < arr[i + 1] && index != i) {
        arr[i + 1] = arr[i + 1] - arr[i];
        index = i + 1;
        continue;
      } else {
        total += arr[i];
      }
    }
    print("Total = ${total}");
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    print("image url user ${image}");
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                            icon: Icon(Icons.close),
                            color: theme.primaryColor,
                            iconSize: 28,
                            onPressed: () => Navigator.pop(context)),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                          child: Row(
                            children: [
                              Container(
                                height: 72,
                                width: 72,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    image.toString(),
                                    height: 72,
                                    width: 72,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 150,
                                    child: Text(name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.headline5!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                  ),
                                  SizedBox(height: 6),
                                  Text(mobile != "" ? mobile.toString() : "",
                                      style: theme.textTheme.caption!
                                          .copyWith(fontSize: 12)),
                                  SizedBox(height: 4),
                                  /*   Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: AppTheme.ratingsColor,
                                    ),
                                    child: Row(
                                      children: [
                                        Text('4.2',
                                            style: TextStyle(fontSize: 12)),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.star,
                                          color: AppTheme.starColor,
                                          size: 10,
                                        )
                                      ],
                                    ),
                                  ),*/
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                buildListTile(context, Icons.home, "HOME", () {
                  if (widget.fromHome)
                    Navigator.pop(context);
                  else
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/'),
                    );
                  /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchLocationPage()));*/
                }),
                buildListTile(context, Icons.person, "MY_PROFILE", () async {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                  if (result != null) {
                    widget.onResult(result);
                    Navigator.pop(context);
                  }
                }),
                buildListTile(context, Icons.drive_eta, "MY_RIDES", () async {
                  // Navigator.pop(context);
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyRidesPage("3")));
                  if (result != null) {
                    widget.onResult(result);
                    Navigator.pop(context);
                  }
                }),
                /*buildListTile(context, Icons.history, "INTERCITY", () async {

                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InterCityRidePage("3")));
                  if (result != null) {
                    widget.onResult(result);
                    Navigator.pop(context);
                  }
                }),*/
                buildListTile(context, Icons.account_balance_wallet, "WALLET",
                    () async {
                  // Navigator.pop(context);
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => WalletPage()));
                  if (result != null) {
                    widget.onResult(result);
                    Navigator.pop(context);
                  }
                }),
                buildListTile(context, Icons.star, 'RATING', () async {
                  // Navigator.pop(context);
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewsPage()),
                  );
                  if (result != null) {
                    widget.onResult(result);
                    Navigator.pop(context);
                  }
                  /*Navigator.popAndPushNamed(context, PageRoutes.reviewsPage);*/
                }),
                /* buildListTile(context, Icons.local_offer, Strings.PROMO_CODE,
                        () {
                      Navigator.pop(context);
                      Navigator.push(context,MaterialPageRoute(builder: (context)=> PromoCodePage()));
                    }),*/
                /*ListTile(
                  title: Text(
                    getTranslated(context, "RENTAL_RIDES")!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading:
                      Icon(Icons.location_on_outlined, color: Color(0xffF36B21)),
                  onTap: () async {
                    Navigator.pop(context);
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RentalRides(
                                selected: true,
                              )),
                    );

                  },
                ),*/
                buildListTile(context, Icons.call, "EMERGENCY_CALL", () {
                  launch("tel://${userNumber}");
                }),
                // buildListTile(context, Icons.airline_seat_recline_normal_rounded,
                //     "REFER_EARN", () {
                //   if (widget.fromHome)
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => ReferEarn()));
                //   else
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => ReferEarn()));
                // }),
                buildListTile(context, Icons.lock, "CHANGE_PASSWORD", () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChangePassword()));
                }),
               /* buildListTile(context, Icons.settings, "SETTINGS", () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                }),*/
                buildListTile(context, Icons.help, "FAQS", () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FaqPage()));
                }),
                buildListTile(context, Icons.mail, "CONTACT_US", () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ContactUsPage()));
                }),
                buildListTile(context, Icons.logout, "LOGOUT", () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(getTranslated(context, "LOGOUT")!),
                          content: Text(getTranslated(context, "DO_LOGOUT")!),
                          actions: <Widget>[
                            ElevatedButton(
                              child: Text('No'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    MyColorName.colorMainButton),
                              ),
                              /*   textColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.transparent)),*/
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            ElevatedButton(
                                child: Text('Yes'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      MyColorName.primaryLite),
                                ),
                                /* shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.transparent)),
                                  textColor: Theme.of(context).colorScheme.primary,*/
                                onPressed: () async {
                                  await App.init();
                                  App.localStorage.clear();
                                  Common.logoutApi();
                                  //Common().toast("Logout");
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                      (route) => false);
                                }),
                          ],
                        );
                      });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListTile buildListTile(BuildContext context, IconData icon, String title,
      [Function? onTap]) {
    var theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor, size: 24),
      title: Text(
        getTranslated(context, title)??'',
        maxLines: 1,
        style: theme.textTheme.headline5!
            .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      onTap: onTap as void Function()?,
    );
  }
}

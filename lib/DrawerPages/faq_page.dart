import 'dart:async';
import 'dart:convert';

import 'package:why_taxi_user/DrawerPages/Settings/rules.dart';
import 'package:why_taxi_user/Theme/style.dart';
import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/common.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:why_taxi_user/utils/widget.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:why_taxi_user/DrawerPages/app_drawer.dart';
import 'package:why_taxi_user/Locale/locale.dart';
import 'package:why_taxi_user/Locale/strings_enum.dart';
import 'package:http/http.dart' as http;

class FAQs {
  final Strings title;
  final Strings subtitle;

  FAQs(this.title, this.subtitle);
}

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  void initState() {
    super.initState();
    getFaq();
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  List<RuleModel> ruleList = [];
  getFaq() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_id": curUserId,
        };
        var res =
            await http.get(Uri.parse(baseUrl + "needhelp"));
        Map response = jsonDecode(res.body);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          for (var v in response['need_help']) {
            setState(() {
              ruleList
                  .add(new RuleModel(v['id'], v['title'], v['description']));
            });
          }
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getTranslated(context, "FAQS")??"FAQs",
        ),
      ),

      //drawer: AppDrawer(false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                getTranslated(context, 'READ_FAQS')!,
                style:
                    theme.textTheme.bodyText2!.copyWith(color: theme.hintColor),
              ),
            ),
            SizedBox(height: 20),
      ruleList.length > 0
          ? Container(
        color: theme.backgroundColor,
        padding: EdgeInsets.only(top: 16),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: ruleList.length,
          itemBuilder: (context, index) => Container(
            decoration: boxDecoration(radius: 10, showShadow: true),
            margin: EdgeInsets.all(getWidth(10)),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // Remove the top and bottom lines
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: Text(
                  getString1(ruleList[index].title),
                  style: theme.textTheme.headline6,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      getString1(ruleList[index].description),
                    ),
                  ),
                ],
                expandedAlignment: Alignment.centerLeft,
                trailing: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),

      // ruleList.length > 0
            //     ? Container(
            //         color: theme.backgroundColor,
            //         padding: EdgeInsets.only(top: 16),
            //         child: ListView.builder(
            //           shrinkWrap: true,
            //           physics: NeverScrollableScrollPhysics(),
            //           itemCount: ruleList.length,
            //           itemBuilder: (context, index) => Container(
            //             decoration: boxDecoration(radius: 10, showShadow: true),
            //             margin: EdgeInsets.all(getWidth(10)),
            //             child: ExpansionTile(
            //               tilePadding:
            //                   EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            //               title: Text(
            //                 getString1(ruleList[index].title),
            //                 style: theme.textTheme.headline6,
            //               ),
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.symmetric(
            //                       horizontal: 20, vertical: 10),
            //                   child: Text(
            //                     getString1(ruleList[index].description),
            //                   ),
            //                 )
            //               ],
            //               expandedAlignment: Alignment.centerLeft,
            //               trailing: Icon(
            //                 Icons.keyboard_arrow_down,
            //                 color: theme.primaryColor,
            //                 size: 20,
            //               ),
            //             ),
            //           ),
            //         ),
            //       )
            //     : Center(
            //         child: CircularProgressIndicator(),
            //       )
          ],
        ),
      ),
    );
  }
}

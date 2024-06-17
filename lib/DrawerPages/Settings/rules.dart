import 'dart:async';
import 'dart:convert';

import 'package:why_taxi_user/DrawerPages/Settings/theme_cubit.dart';
import 'package:why_taxi_user/Theme/style.dart';
import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/colors.dart';
import 'package:why_taxi_user/utils/common.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:why_taxi_user/utils/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sizer/sizer.dart';
import 'language_cubit.dart';
import 'package:http/http.dart' as http;

class RuleModel {
  String id, title, description;

  RuleModel(this.id, this.title, this.description);
}

class RulesRegulation extends StatefulWidget {
  @override
  _RulesRegulationState createState() => _RulesRegulationState();
}

class _RulesRegulationState extends State<RulesRegulation> {
  late LanguageCubit _languageCubit;
  late ThemeCubit _themeCubit;
  int? _themeValue;
  int? _languageValue;
  bool screenStatus = false;
  @override
  void initState() {
    super.initState();
    getRules();
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  List<RuleModel> ruleList = [];
  getRules() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_id": curUserId,
        };
        var res = await http.get(
            Uri.parse(baseUrl1 + "page/get_user_pages/rules-and-regulations"));
        Map response = jsonDecode(res.body);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          for (var v in response['data']) {
            setState(() {
              ruleList
                  .add(new RuleModel(v['id'], v['title'], v['page_content']));
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
        title: Text(
          getTranslated(context, "RULES")??"Rules",
        ),
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: getWidth(25)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            boxHeight(20),
            ruleList.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: ruleList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            boxHeight(10),
                            text(getString1(ruleList[index].title),
                                fontSize: 14.sp,
                                fontFamily: fontBold,
                                textColor: MyColorName.colorTextPrimary),
                            boxHeight(10),
                            text(getString1(ruleList[index].description),
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                isLongText: true,
                                textColor: MyColorName.colorTextPrimary),
                          ],
                        ),
                      );
                    })
                : CircularProgressIndicator(),
            SizedBox(
              height: 80,
            )
          ],
        ),
      ),
    );
  }
}

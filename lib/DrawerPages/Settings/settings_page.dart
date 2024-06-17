import 'dart:async';

import 'package:why_taxi_user/DrawerPages/Settings/rules.dart';
import 'package:why_taxi_user/DrawerPages/Settings/theme_cubit.dart';
import 'package:why_taxi_user/Locale/locale.dart';
import 'package:why_taxi_user/Locale/strings_enum.dart';
import 'package:why_taxi_user/Theme/style.dart';
import 'package:why_taxi_user/main.dart';
import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/common.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


import 'language_cubit.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late LanguageCubit _languageCubit;
  late ThemeCubit _themeCubit;
  int? _themeValue;
  int? _languageValue;
  bool screenStatus = false;
  @override
  void initState() {
    super.initState();
    getSaved();
    _themeValue = 0;
    _languageValue = 0;
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
    _themeCubit = BlocProvider.of<ThemeCubit>(context);
  }

  List<String> langCode = [
    "en",
    "ne",
  ];
  List<String?> languageList = [];
  int? selectLan;
  getSaved() async {
    //String get = await settingsProvider.getPrefrence(APP_THEME) ?? '';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String getlng = await prefs.getString(languageCode) ?? '';
    setState(() {
      selectLan = langCode.indexOf(getlng == '' ? "en" : getlng);
    });
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  updateStatus(String status1) async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_id": curUserId,
          "status": status1.toString(),
        };
        Map response = await apiBase.postAPICall(
            Uri.parse(baseUrl + "update_notification"), data);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          App.localStorage.setBool("notification", notification);
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
    final List<Strings> themes = [Strings.LIGHT_MODE, Strings.DARK_MODE];
    languageList = [
      "English",
      "Nepali",
      /* Strings.FRENCH,
      Strings.PORTUGUESE,
      Strings.INDONESIAN,
      Strings.SPANISH,*/
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          getTranslated(context, "SETTINGS")??"Settings",
        ),
      ),

      body: Stack(
        children: [
          ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              boxHeight(20),
              Card(
                margin: EdgeInsets.all(getWidth(10)),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Text(
                      getTranslated(context, "LOCK_SCREEN")!,
                      style: theme.textTheme.bodyText2!
                          .copyWith(color: theme.hintColor),
                    ),
                  ),
                  trailing: Switch.adaptive(
                      value: doLock,
                      onChanged: (value) async {
                        await App.init();
                        App.localStorage.setBool("lock", value);
                        WakelockPlus.toggle(enable: value);
                        setState(() {
                          doLock = value;
                        });
                      }),
                ),
              ),
              Card(
                margin: EdgeInsets.all(getWidth(10)),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Text(
                      getTranslated(context, "RULES")!,
                      style: theme.textTheme.bodyText2!
                          .copyWith(color: theme.hintColor),
                    ),
                  ),
                  onTap: () {
                    navigateScreen(context, RulesRegulation());
                  },
                ),
              ),
              /* Card(
                  margin: EdgeInsets.all(getWidth(10)),
                  child: ListTile(
                    title:Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: Text(
                        "Push Notification",
                        style: theme.textTheme.bodyText2!
                            .copyWith(color: theme.hintColor),
                      ),
                    ),
                    trailing: Switch.adaptive(value: notification, onChanged: (value){
                      setState(() {
                        notification = value;
                        if(value){
                          updateStatus("1");
                        }else{
                          updateStatus("0");
                        }
                      });
                    }),
                  ),
                ),*/
              /* ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: themes.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => RadioListTile(
                    activeColor: theme.primaryColor,
                    value: index,
                    groupValue: _themeValue,
                    onChanged: (dynamic value) {
                      setState(() {
                        _themeValue = value;
                      });
                    },
                    title: Text(getString(themes[index])!),
                  ),
                ),*/
              Card(
                margin: EdgeInsets.all(getWidth(10)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    getTranslated(context, 'CHOOSE_LANG')!,
                    style: theme.textTheme.bodyText2!
                        .copyWith(color: theme.hintColor),
                  ),
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: languageList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => RadioListTile(
                  activeColor: theme.primaryColor,
                  value: index,
                  groupValue: selectLan,
                  onChanged: (dynamic value) {
                    setState(() {
                      selectLan = index;
                      _changeLan(langCode[index], context);
                    });
                  },
                  title: Text(languageList[index]!),
                ),
              ),
              SizedBox(
                height: 80,
              )
            ],
          ),
          /*PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: CustomButton(
                text: getString(Strings.SUBMIT),
                onTap: () async {
                  var prefs = await SharedPreferences.getInstance();

                  if (themes[_themeValue!] == Strings.LIGHT_MODE) {
                    prefs.setBool('theme', true);
                    _themeCubit.selectLightTheme();
                  } else if (themes[_themeValue!] == Strings.DARK_MODE) {
                    prefs.setBool('theme', false);
                    _themeCubit.selectDarkTheme();
                  }
                  if (languages[_languageValue!] == Strings.ENGLISH) {
                    prefs.setString('locale', 'en');
                    _languageCubit.selectEngLanguage();
                  } else if (languages[_languageValue!] == Strings.ARABIC) {
                    prefs.setString('locale', 'ar');
                    _languageCubit.selectArabicLanguage();
                  } else if (languages[_languageValue!] == Strings.PORTUGUESE) {
                    prefs.setString('locale', 'pt');
                    _languageCubit.selectPortugueseLanguage();
                  } else if (languages[_languageValue!] == Strings.FRENCH) {
                    prefs.setString('locale', 'fr');
                    _languageCubit.selectFrenchLanguage();
                  } else if (languages[_languageValue!] == Strings.SPANISH) {
                    prefs.setString('locale', 'es');
                    _languageCubit.selectSpanishLanguage();
                  } else if (languages[_languageValue!] == Strings.INDONESIAN) {
                    prefs.setString('locale', 'in');
                    _languageCubit.selectIndonesianLanguage();
                  }
                  Navigator.pop(context);
                },
              ),
            ),*/
        ],
      ),
    );
  }

  void _changeLan(String language, BuildContext ctx) async {
    Locale _locale = await setLocale(language);

    WhyTaxiUser.setLocale(ctx, _locale);
  }
}

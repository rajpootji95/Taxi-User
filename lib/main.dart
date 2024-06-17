import 'dart:io';

import 'package:why_taxi_user/Auth/Login/UI/login_page.dart';
import 'package:why_taxi_user/BookRide/search_location_page.dart';
import 'package:why_taxi_user/Theme/style.dart';
import 'package:why_taxi_user/utils/Demo_Localization.dart';
import 'package:why_taxi_user/utils/PushNotificationService.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/common.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:why_taxi_user/Auth/login_navigator.dart';
import 'package:why_taxi_user/DrawerPages/Settings/language_cubit.dart';
import 'package:why_taxi_user/DrawerPages/Settings/theme_cubit.dart';
import 'package:why_taxi_user/Routes/page_routes.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'Locale/locale.dart';
import 'map_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  MapUtils.getMarkerPic();
  MobileAds.instance.initialize();

  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: AppTheme.primaryColor, // status bar color
  ));
  String? locale = prefs.getString('locale');
  bool? isDark = prefs.getBool('theme');
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (context) => LanguageCubit(locale)),
    BlocProvider(create: (context) => ThemeCubit(isDark ?? false)),
  ], child: WhyTaxiUser()));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class WhyTaxiUser extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _WhyTaxiUserState state = context.findAncestorStateOfType<_WhyTaxiUserState>()!;
    state.setLocale(newLocale);
  }

  @override
  State<WhyTaxiUser> createState() => _WhyTaxiUserState();
}

class _WhyTaxiUserState extends State<WhyTaxiUser> {
  bool _isKeptOn = true;
  double _brightness = 1.0;
  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  Locale? _locale;

  setLocale(Locale locale) {
    if (mounted)
      setState(() {
        _locale = locale;
      });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      if (mounted)
        setState(() {
          this._locale = locale;
        });
    });
    super.didChangeDependencies();
  }

  initPlatformState() async {
    await App.init();
    bool keptOn = await WakelockPlus.enabled;
    if (App.localStorage.getBool("lock") != null) {
      doLock = App.localStorage.getBool("lock")!;
      WakelockPlus.toggle(enable: App.localStorage.getBool("lock")!);
    }
    if (App.localStorage.getBool("notification") != null) {
      notification = App.localStorage.getBool("notification")!;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return KhaltiScope(
        publicKey: "test_public_key_147c9018314d4c1e9d97f4701a8afb0e",
        enabledDebugging: true,
        builder: (context, navKey) {
          return Sizer(builder: (context, orientation, deviceType) {
            return BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return BlocBuilder<ThemeCubit, ThemeData>(
                  builder: (context, theme) {
                    return MaterialApp(
                      locale: _locale,
                      supportedLocales: [
                        Locale("en", "US"),
                        Locale("ne", "NPL"),
                      ],
                      navigatorKey: navKey,
                      localizationsDelegates: [
                        KhaltiLocalizations.delegate,
                        DemoLocalization.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      routes: {
                        '/': (BuildContext context) => SearchLocationPage(),
                        'Login': (BuildContext context) => LoginPage(),
                      },
                      localeResolutionCallback: (locale, supportedLocales) {
                        for (var supportedLocale in supportedLocales) {
                          if (supportedLocale.languageCode ==
                                  locale!.languageCode &&
                              supportedLocale.countryCode ==
                                  locale.countryCode) {
                            return supportedLocale;
                          }
                        }
                        return supportedLocales.first;
                      },
                      theme: theme,
                      initialRoute: "Login",
                      // home: LoginPage(),
                      // routes: PageRoutes().routes(),
                      debugShowCheckedModeBanner: false,
                    );
                  },
                );
              },
            );
          });
        });
  }
}

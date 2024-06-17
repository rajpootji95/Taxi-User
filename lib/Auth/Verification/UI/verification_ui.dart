import 'dart:async';

import 'package:why_taxi_user/Auth/AddMoney/UI/add_money_page.dart';
import 'package:why_taxi_user/Auth/login_navigator.dart';
import 'package:why_taxi_user/BookRide/search_location_page.dart';
import 'package:why_taxi_user/Theme/style.dart';
import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/colors.dart';
import 'package:why_taxi_user/utils/common.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:why_taxi_user/Components/custom_button.dart';
import 'package:why_taxi_user/Components/entry_field.dart';
import 'package:why_taxi_user/Locale/strings_enum.dart';
import 'verification_interactor.dart';
import 'package:why_taxi_user/Locale/locale.dart';

class VerificationUI extends StatefulWidget {
  final VerificationInteractor verificationInteractor;
  String mobile, otp;

  VerificationUI(this.verificationInteractor, this.mobile, this.otp);

  @override
  _VerificationUIState createState() => _VerificationUIState();
}

class _VerificationUIState extends State<VerificationUI> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Container(
              // color: Color(0xffF36B21)  AppTheme,
              //color: AppTheme.primaryColor,
              height: MediaQuery.of(context).size.height + 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Image.asset("assets/logo.png",height: 150,width: 150),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      getTranslated(context, 'ENTER')! +
                          '\n' +
                          getTranslated(context, 'VER_CODE')!,
                      style: theme.textTheme.headline4!.copyWith(color: MyColorName.colorTextSecondary),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                    child: Text(
                      getTranslated(context, 'ENTER_CODE_WE')!,
                      style: theme.textTheme.bodyText2!
                          .copyWith(color: MyColorName.colorTextSecondary, fontSize: 12,fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Container(
                      height: 500,
                      color: theme.backgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Spacer(),
                          EntryField(
                            keyboardType: TextInputType.phone,
                            maxLength: 4,
                            controller: _otpController,
                            label: getTranslated(context, 'ENTER_6_DIGIT')
                                    .toString() +
                                " ${widget.otp}",style: TextStyle(
                            color: MyColorName.primaryDark,fontWeight: FontWeight.bold
                          ),
                          ),
                          Spacer(flex: 7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          !loading
              ? Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: getTranslated(context, 'NOT_RECEIVED'),
                        onTap: () =>
                            widget.verificationInteractor.notReceived(),
                        color: theme.scaffoldBackgroundColor,
                        textColor: theme.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        textColor: Colors.white,
                        onTap: () {
                          if (_otpController.text == "" ||
                              _otpController.text.length != 4) {
                            UI.setSnackBar("Please Enter Valid Otp", context);
                            return;
                          }
                          if (_otpController.text != widget.otp) {
                            UI.setSnackBar("Wrong Otp", context);
                            return;
                          }
                          setState(() {
                            loading = true;
                          });
                          loginUser();
                        },
                      ),
                    ),
                  ],
                )
              : Container(
                  width: 50, child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;
  loginUser() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_phone": widget.mobile.trim().toString(),
          "otp": widget.otp.toString(),
        };
        Map response =
            await apiBase.postAPICall(Uri.parse(baseUrl + "login"), data);
        print(response);
        bool status = true;
        String msg = response['message'];
        setState(() {
          loading = false;
        });
        UI.setSnackBar(msg, context);
        if (response['status']) {
          App.localStorage
              .setString("userId", response['data']['id'].toString());
          curUserId = response['data']['id'].toString();
          Navigator.popAndPushNamed(context, "/");
          //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
        setState(() {
          loading = false;
        });
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
      setState(() {
        loading = false;
      });
    }
  }
}

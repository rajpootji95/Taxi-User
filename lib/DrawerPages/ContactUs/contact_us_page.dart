import 'dart:async';

import 'package:why_taxi_user/Components/custom_button.dart';
import 'package:why_taxi_user/Components/entry_field.dart';
import 'package:why_taxi_user/Locale/locale.dart';
import 'package:why_taxi_user/Locale/strings_enum.dart';
import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../app_drawer.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController _controller = TextEditingController();
  ApiBaseHelper apiBase = new ApiBaseHelper();
  double totalBal = 0;
  double minimumBal = 0;
  bool isNetwork = false;
  bool saveStatus = false;
  addContact() async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "driver_id": curUserId.toString(),
        "email": email.toString(),
        "name": name.toString(),
        "description": _controller.text.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Contact/contact_email"), params);
      setState(() {
        saveStatus = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context);
        back(context);
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getTranslated(context, "CONTACT_US")??'Contact Us',
        ),
      ),
      // drawer: AppDrawer(false),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height + 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [


                  SizedBox(height: 32),
                  /* Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            icon: Icons.call,
                            text: context.getString(Strings.CALL_US),
                            color: theme.cardColor,
                            textColor: theme.primaryColor,
                          ),
                        ),
                        Expanded(
                          child: CustomButton(
                            icon: Icons.email,
                            text: context.getString(Strings.EMAIL_US),
                          ),
                        ),
                      ],
                    ),*/
                  Expanded(
                    child: Container(
                      color: theme.backgroundColor,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            EntryField(
                              label:"Email ID",
                              initialValue: contactEmail,
                              readOnly: true,
                            ),
                            SizedBox(height: 20),
                            EntryField(
                              label:"Contact No.",
                              initialValue: contactNo,
                              readOnly: true,
                            ),
                          /*  Padding(
                              padding: EdgeInsets.fromLTRB(24, 48, 24, 0),
                              child: Text(
                                getTranslated(context, 'WRITE_US')!,
                                style: theme.textTheme.headline4,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: Text(
                                getTranslated(context, 'DESC_YOUR_ISSUE')!,
                                style: theme.textTheme.bodyText2!
                                    .copyWith(color: theme.hintColor),
                              ),
                            ),
                            SizedBox(height: 20),
                            EntryField(
                              label: getTranslated(context, 'YOUR_EMAIL'),
                              initialValue: email,
                              readOnly: true,
                            ),
                            SizedBox(height: 20),
                            EntryField(
                              controller: _controller,
                              label: getTranslated(context, 'DESC_YOUR_ISSUE')!,
                            ),*/
                            // Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
  /*    bottomNavigationBar: !saveStatus
          ? CustomButton(
              text: getTranslated(context, 'SUBMIT'),
              onTap: () {
                if (_controller.text == "") {
                  UI.setSnackBar(getTranslated(context, "FILL_DESC")!, context);
                  return;
                }
                addContact();
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),*/
    );
  }
}

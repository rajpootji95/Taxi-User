import 'dart:convert';

import 'package:why_taxi_user/Components/custom_button.dart';
import 'package:why_taxi_user/Locale/locale.dart';
import 'package:why_taxi_user/Model/Change_Password_Model.dart';
import 'package:why_taxi_user/utils/colors.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../BookRide/search_location_page.dart';
import '../../Components/entry_field.dart';
import '../../Locale/strings_enum.dart';
import '../../Theme/style.dart';
import '../../utils/Session.dart';
import '../../utils/common.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final oldPassC = TextEditingController();
  final newPassC = TextEditingController();
  final confirmPassC = TextEditingController();
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        title: Text(getTranslated(context, "CHANG_PASSWORD")!),
      ),
      body: Container(
        color: theme.backgroundColor,
        child: Column(
          children: [
            SizedBox(height: 10),
            EntryField(
              label: getTranslated(context,'OLD_PASS')!,
              controller: oldPassC,
              obscureText: obscure,
              suffixIcon: IconButton(
                icon: Icon(obscure?Icons.visibility:Icons.visibility_off,color: MyColorName.primaryLite,),
                onPressed: (){
                  setState(() {
                    obscure=!obscure;
                  });
                },
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            EntryField(
              label: getTranslated(context,'NEW_PASS')!,
              controller: newPassC,
              obscureText: obscure,
              suffixIcon: IconButton(
                icon: Icon(obscure?Icons.visibility:Icons.visibility_off,color: MyColorName.primaryLite,),
                onPressed: (){
                  setState(() {
                    obscure=!obscure;
                  });
                },
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            EntryField(
              label: getTranslated(context,'CONFIRM_PASS')!,
              controller: confirmPassC,
              obscureText: obscure,
              suffixIcon: IconButton(
                icon: Icon(obscure?Icons.visibility:Icons.visibility_off,color: MyColorName.primaryLite,),
                onPressed: (){
                  setState(() {
                    obscure=!obscure;
                  });
                },
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: 20,),
            CustomButton(
              borderRadius: BorderRadius.circular(10),
              textColor: Colors.white,
              text: getTranslated(context,'CHANGE_PASSWORD')!,
              onTap: (){
                if(oldPassC.text==""||oldPassC.text.length<8){
                  UI.setSnackBar("Enter Old Password", context);
                  return ;
                }
                if(newPassC.text==""||newPassC.text.length<8){
                  UI.setSnackBar(getTranslated(context, "ENTER_PASSWORD")!, context);
                  return ;
                }
                if(confirmPassC.text != newPassC.text){
                  UI.setSnackBar("Confirm Password Doesn't match", context);
                  return ;
                }
                changePassword();
              },
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomButton(
      //   textColor: Colors.white,
      //   text: getTranslated(context,'CHANGE_PASSWORD')!,
      //   onTap: (){
      //     if(oldPassC.text==""||oldPassC.text.length<8){
      //       UI.setSnackBar("Enter Old Password", context);
      //       return ;
      //     }
      //     if(newPassC.text==""||newPassC.text.length<8){
      //       UI.setSnackBar(getTranslated(context, "ENTER_PASSWORD")!, context);
      //       return ;
      //     }
      //     if(confirmPassC.text != newPassC.text){
      //       UI.setSnackBar("Confirm Password Doesn't match", context);
      //       return ;
      //     }
      //     changePassword();
      //   },
      // ),
    );
  }

  Future changePassword() async {
    Map<String, String> headers = {
      "token": App.localStorage.getString("token").toString(),
      "Content-type": "multipart/form-data"
    };
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl1 + 'Authentication/changePassword'));
    request.fields.addAll({
      'user_id': curUserId.toString(),
      'old_password': '${oldPassC.text}',
      'new_password': '${newPassC.text}'
    });
    print(request);
    print(request.fields);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      print(str);
      var data = ChangePasswordModel.fromJson(json.decode(str));
      if(data.status == true){
        UI.setSnackBar(data.message.toString(), context,);
        Navigator.pop(context);
      } else {
        UI.setSnackBar(data.message.toString(), context);
      }
    }
    else {
      return null;
    }
  }
}

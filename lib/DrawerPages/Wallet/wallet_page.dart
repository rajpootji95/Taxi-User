import 'dart:async';


import 'package:intl/intl.dart';
import 'package:why_taxi_user/Components/entry_field.dart';
import 'package:why_taxi_user/DrawerPages/Wallet/wallet_policy.dart';

import 'package:why_taxi_user/Model/wallet_model.dart';

import 'package:why_taxi_user/utils/ApiBaseHelper.dart';
import 'package:why_taxi_user/utils/Razorpay.dart';
import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/colors.dart';
import 'package:why_taxi_user/utils/constant.dart';
import 'package:why_taxi_user/utils/khalti_pay.dart';
import 'package:why_taxi_user/utils/widget.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sizer/sizer.dart';
import '../app_drawer.dart';

class WalletPage extends StatefulWidget {
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  ApiBaseHelper apiBase = new ApiBaseHelper();
  double totalRequest = 0,totalPay = 0,totalAvailable = 0;
  double minimumBal = 0;
  bool isNetwork = false;
  bool saveStatus = true;
  bool showText = false;
  TextEditingController amount = new TextEditingController();
  TextEditingController remark = new TextEditingController();
  getSetting() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/minimum_balance"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var data = response["data"][0];
        print(data);
        minimumBal = double.parse(data['wallet_amount'].toString());
        amount.text = minimumBal.toString().split(".")[0];

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

  List<RequestMoneyModel> walletList = [];

  getWallet() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
        Uri.parse(baseUrl1 + "Authentication/get_wallet_request"),params
      );
      setState(() {
        saveStatus = true;
        walletList.clear();
        paymentList.clear();
      });
      if (response['status']) {
        var data = response["data"];
        for (var v in data['wallet_request_list']) {
          print(v['Note']);
          setState(() {
            walletList.add(new RequestMoneyModel.fromJson(v));
          });
        }
        for (var v in data['payble_list']) {
          setState(() {
            paymentList.add(new RequestMoneyModel.fromJson(v));
          });
        }
        print(data);
        totalRequest = double.parse(data['payble_amount']??"0");
        totalAvailable = double.parse(data['wallet']??"0");
        totalPay = double.parse(data['total_payble_amount']??"0");
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

  List<RequestMoneyModel> paymentList = [];


  bool loading = false;
  bool showWithdraw = false;
  addWallet(orderId) async {
    try {


      Map params = {
        "user_id": curUserId.toString(),
        "amount": amount.text.contains(".")
            ? amount.text.toString().split(".")[0]
            : amount.text.toString(),
        "remark": remark.text.toString(),
        "order_id": DateTime.now().toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/wallet_request"), params);
      setState(() {
        requestMoneyLoading = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context);
        getWallet();
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
  addPayment(String orderId,RequestMoneyModel request) async {
    try {
      Map params = {
        "user_id": curUserId.toString(),
        "amount": request.paybleAmount,
        "transaction_id": orderId.toString(),
        "request_id": request.id,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/pay_request_amount"), params);
      setState(() {
        requestMoneyLoading = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context);
        getWallet();
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getWallet();
  //  getWithdraw();
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

    return Future.value(true);
  }
  bool requestMoneyLoading = false;
  String requestId = "";
  Future<bool> showRequestDialog() async{
    var theme = Theme.of(context);
    amount.text = "";
    remark.text = "";
    var result = await showDialog(context: context, builder: (ctx){
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  "Request Amount",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight:FontWeight.w700
                  ),
                ),
              ),

              UI.commonIconButton(
                message: "Close",
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  iconData: Icons.close,
                  iconColor: MyColorName.primaryDark),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EntryField(
                maxLength: 10,
                keyboardType: TextInputType.phone,
                controller: amount,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                label: "Amount",
              ),
              SizedBox(
                height: 10,
              ),
              EntryField(

                keyboardType: TextInputType.text,
                controller: remark,

                label: "Remark",
              ),
            ],
          ),
          actions: [
            UI.commonButton(
                title: "Submit",
                loading: false,
                onPressed: () async {
                  if (amount.text == "") {
                    UI.setSnackBar(
                        "Please Enter Amount", context);
                    return;
                  }
                  Navigator.pop(context,true);

                }),
          ],
        );
    });
    if(result==null){
      return false;
    }
    return result;
  }
  Future<bool> showPayDialog()async{
    var theme = Theme.of(context);
    amount.text = totalRequest.toString();
    remark.text = "";
    var result = await showDialog(context: context, builder: (ctx){
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                "Pay Amount",
                style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight:FontWeight.w700
                ),
              ),
            ),
            UI.commonIconButton(
                message: "Close",
                onPressed: (){
                  Navigator.pop(context);
                },
                iconData: Icons.close,
                iconColor: MyColorName.primaryDark),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EntryField(
              maxLength: 10,
              keyboardType: TextInputType.phone,
              controller: amount,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              label: "Amount",
            ),
            SizedBox(
              height: 10,
            ),
            EntryField(
              keyboardType: TextInputType.text,
              controller: remark,

              label: "Remark",
            ),
          ],
        ),
        actions: [
          UI.commonButton(
              title: "Submit",
              loading: false,
              onPressed: () async {
                if (amount.text == "") {
                  UI.setSnackBar(
                      "Please Enter Amount", context);
                  return;
                }
                Navigator.pop(context,true);

              }),
        ],
      );
    });
    if(result==null){
      return false;
    }
    return result;
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: onWill,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            getTranslated(context, "WALLET")??"Wallet",
          ),
        ),
        // drawer: AppDrawer(false),
        body: RefreshIndicator(
          onRefresh: ()async{
            await getWallet();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: saveStatus
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Available Amount",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 8,),
                                  Text(
                                    //\u{20B9}
                                    '\u{20B9}$totalAvailable',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: showWithdraw?Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Paid Amount",
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 8,),
                                  Text(
                                    //\u{20B9}
                                    '\u{20B9}$totalPay',
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ):Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Requested Amount",
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 8,),
                                  Text(
                                    //\u{20B9}
                                    '\u{20B9}$totalRequest',
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletPolicy()));
                      }, child: Text(
                        "Wallet Request Policy",
                        style: TextStyle(
                          decoration: TextDecoration.underline
                        ),
                      )),
                      SizedBox(height: 8),
                      Container(
                        width: getWidth(330),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: UI.commonButton(
                                  title: "Request Money",
                                  bgColor: Colors.transparent,
                                  borderColor: MyColorName.primaryLite,
                                  fontColor: Colors.black,
                                  loading: requestMoneyLoading,
                                  onPressed: () async {
                                    var result = await showRequestDialog();
                                    if(result){
                                      setState(() {
                                        requestMoneyLoading = true;
                                      });
                                      addWallet("");
                                    }
                                  }),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: UI.commonButton(
                                  title: showWithdraw?"Request History":"Due History",
                                  loading: false,
                                  onPressed: () async {
                                    setState(() {
                                      showWithdraw = !showWithdraw;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
                      boxHeight(10),

                      /*  Container(
                    width: getWidth(330),
                    child: text(totalRequest<500?"Note-You need to add minimum \u{20B9}${minimumBal} to get booking request.":"Note-Please maintain \u{20B9}${minimumBal} minimum balance to take rides.",
                    fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: Colors.red
                    ),
                  ),*/
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                getTranslated(context, 'RECENT_TRANS')!,
                                style: theme.textTheme.titleLarge!
                                    .copyWith(color: theme.hintColor),
                              ),
                            ),

                          ],
                        ),
                      ),
                      !showWithdraw
                          ? saveStatus
                              ? walletList.length > 0
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: walletList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) => Container(
                                        margin: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: Colors.grey.withOpacity(0.2))
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            UI.rowItem(
                                              title: "Status",
                                              fontWeight: FontWeight.w600,
                                              color: walletList[index].status=="0"?Colors.orange:walletList[index].status=="1"?Colors.green:Colors.red,
                                              content: walletList[index].status=="0"?"Pending":walletList[index].status=="1"?"Approved":"Rejected",
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            UI.rowItem(
                                              title: "Due Amount",
                                              fontWeight: FontWeight.w600,
                                               content: "\u20B9${walletList[index].amount??'0'}",
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            UI.rowItem(
                                              title: "Convenience Fee",
                                              fontWeight: FontWeight.w600,
                                              content: "\u20B9${walletList[index].convenienceCharge??'0'}",),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Divider(),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Remark"),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(walletList[index].remark??"",style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.w400),),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:10,
                                                ),
                                                if(walletList[index].status=="1")
                                                  UI.commonButton(
                                                    title: "Pay \u20B9${walletList[index].paybleAmount??'0'}",
                                                    loading: requestId == walletList[index].id,
                                                    // bgColor: Colors.white,
                                                    //  fontColor: MyColorName.mainColor,
                                                    onPressed: () async {
                                                      RazorPayHelper razorPay =
                                                      new RazorPayHelper(
                                                          walletList[index].paybleAmount??'0', context,
                                                              (result) {
                                                            if (result != "error") {
                                                              addPayment(result, walletList[index]);
                                                            } else {
                                                              setState(() {
                                                                requestId = "";
                                                              });
                                                            }
                                                          });
                                                      setState(() {
                                                        requestId = walletList[index].id??'';
                                                      });
                                                      razorPay.init();
                                                      /*var result = await showPayDialog();
                                                      if(result){

                                                      }*/
                                                    }),
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: text(
                                          getTranslated(
                                              context, "NO_TRANSACTION")??"",
                                          fontFamily: fontMedium,
                                          fontSize: 12.sp,
                                          textColor: Colors.black),
                                    )
                              : Center(child: CircularProgressIndicator())
                          : saveStatus
                              ? paymentList.length > 0
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: paymentList.length,
                                      shrinkWrap: true,
                                    itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey.withOpacity(0.2))
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              UI.rowItem(
                                title: "Paid Status",
                                fontWeight: FontWeight.w600,
                                color: paymentList[index].paybleStatus=="0"?Colors.orange:paymentList[index].paybleStatus=="1"?Colors.green:Colors.red,
                                content: paymentList[index].paybleStatus=="0"?"Pending":paymentList[index].paybleStatus=="1"?"Approved":"Rejected",
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              UI.rowItem(
                                title: "Last Due Date",
                                fontWeight: FontWeight.w600,
                                content: "${DateFormat("dd MMM yy").format(DateTime.parse(paymentList[index].validDate ?? '0000-00-00'))}",
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              UI.rowItem(
                                title: "Approved Date",
                                fontWeight: FontWeight.w600,
                                content: "${DateFormat("dd MMM yy").format(DateTime.parse(paymentList[index].approvalDate ?? '0000-00-00'))}",
                              ),
                              SizedBox(
                                height: 8,
                              ),

                              UI.rowItem(
                                title: "Due Amount",
                                fontWeight: FontWeight.w600,
                                content: "\u20B9${paymentList[index].amount??'0'}",
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              UI.rowItem(
                                title: "Convenience Fee",
                                fontWeight: FontWeight.w600,
                                content: "\u20B9${paymentList[index].convenienceCharge??'0'}",),
                              SizedBox(
                                height: 5,
                              ),
                              Divider(),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Remark"),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(paymentList[index].remark??"",style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.w400),),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width:10,
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),
                                    )
                                  : Center(
                                      child: text(
                                          getTranslated(
                                              context, "NO_TRANSACTION")??"",
                                          fontFamily: fontMedium,
                                          fontSize: 12.sp,
                                          textColor: Colors.black),
                                    )
                              : Center(child: CircularProgressIndicator())
                    ],
                  )
                : Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

class WithdrawModel {
  String id, amount, status, added_date;
  WithdrawModel(this.id, this.amount, this.status, this.added_date);
}

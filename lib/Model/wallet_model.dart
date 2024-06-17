class WalletModel {
  String? id;
  String? userId;
  String? transactionId;
  String? amount;
  String? sign;
  String? createdAt;
  String? modifiedAt;

  WalletModel(
      {this.id,
      this.userId,
      this.sign,
      this.transactionId,
      this.amount,
      this.createdAt,
      this.modifiedAt});

  WalletModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    sign = json['sign'] ?? "";
    transactionId = json['transaction_id'];
    amount = json['amount'];
    createdAt = json['created_at'];
    modifiedAt = json['modified_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['transaction_id'] = this.transactionId;
    data['amount'] = this.amount;
    data['created_at'] = this.createdAt;
    data['modified_at'] = this.modifiedAt;
    return data;
  }
}
class RequestMoneyModel {
  String? id;
  String? userId;
  String? amount;
  String? remark;
  String? status;
  String? approvalDate;
  String? validDate;
  String? paybleAmount;
  String? paybleStatus;
  String? convenienceCharge;
  String? createdAt;
  String? updatedAt;

  RequestMoneyModel(
      {this.id,
        this.userId,
        this.amount,
        this.remark,
        this.status,
        this.approvalDate,
        this.validDate,
        this.paybleAmount,
        this.paybleStatus,
        this.convenienceCharge,
        this.createdAt,
        this.updatedAt});

  RequestMoneyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    amount = json['amount'];
    remark = json['remark'];
    status = json['status'];
    approvalDate = json['approval_date'];
    validDate = json['valid_date'];
    paybleAmount = json['payble_amount'];
    paybleStatus = json['payble_status'];
    convenienceCharge = json['convenience_charge'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['amount'] = this.amount;
    data['remark'] = this.remark;
    data['status'] = this.status;
    data['approval_date'] = this.approvalDate;
    data['valid_date'] = this.validDate;
    data['payble_amount'] = this.paybleAmount;
    data['payble_status'] = this.paybleStatus;
    data['convenience_charge'] = this.convenienceCharge;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}


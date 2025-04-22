
class BillingData {
  final List<Due> dues;
  final List<Payment> payments;

  BillingData({
    required this.dues,
    required this.payments,
  });

  double get totalPayable => dues.fold(0, (sum, due) => sum + due.payable);
  double get totalPaid => payments.fold(0, (sum, payment) => sum + payment.amount);
  double get balance => totalPayable - totalPaid;

  factory BillingData.fromJson(Map<String, dynamic> json) {
    return BillingData(
      dues: (json['dues'] as List).map((e) => Due.fromJson(e)).toList(),
      payments: (json['payments'] as List).map((e) => Payment.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dues': dues.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}

class Due {
  final String date;
  final String head;
  final num amount;
  final num discount;
  final num dueVat;
  final num vatAdjusted;
  final num payable;

  Due({
    required this.date,
    required this.head,
    required this.amount,
    required this.discount,
    required this.dueVat,
    required this.vatAdjusted,
    required this.payable,
  });

  factory Due.fromJson(Map<String, dynamic> json) {
    return Due(
      date: json['date'],
      head: json['head'],
      amount: (json['amount'] as num),
      discount: (json['discount'] as num),
      dueVat: (json['due_vat'] as num),
      vatAdjusted: (json['vat_adjusted'] as num),
      payable: (json['payable'] as num),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'head': head,
      'amount': amount,
      'discount': discount,
      'due_vat': dueVat,
      'vat_adjusted': vatAdjusted,
      'payable': payable,
    };
  }
}

// models/payment.dart
class Payment {
  final String date;
  final String mrNo;
  final num amount;
  final String chequeNo;
  final String comments;

  Payment({
    required this.date,
    required this.mrNo,
    required this.amount,
    required this.chequeNo,
    required this.comments,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      date: json['date'],
      mrNo: json['mr_no'].toString(),
      amount: (json['amount'] as num),
      chequeNo: json['cheque_no'].toString(),
      comments: json['comments'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mr_no': mrNo,
      'amount': amount,
      'cheque_no': chequeNo,
      'comments': comments,
    };
  }
}
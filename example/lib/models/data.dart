class Data {
  int id;
  String plan;
  String customer;
  int remainingDays;

  Data({this.id, this.plan, this.customer, this.remainingDays});

  Data.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    plan = json['plan'];
    customer = json['customer'];
    remainingDays = int.parse(json['remaining_days'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['plan'] = this.plan;
    data['customer'] = this.customer;
    data['remaining_days'] = this.remainingDays;
    return data;
  }
}

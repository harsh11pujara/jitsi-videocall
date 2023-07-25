class UserModel {
  String? uid;
  String? name;
  bool? online;
  String? email;
  String? fmcToken;

  UserModel({this.uid, this.name, this.online, this.email, this.fmcToken});

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    online = json['online'];
    email = json['email'];
    fmcToken = json['fmcToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['online'] = this.online;
    data['email'] = this.email;
    data['fmcToken'] = this.fmcToken;
    return data;
  }
}
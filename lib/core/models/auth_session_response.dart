class AuthSessionResponse {
  String? token;
  User? user;
  String? type;
  List<String>? permissions;

  AuthSessionResponse({this.token, this.user, this.type, this.permissions});

  AuthSessionResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    type = json['type'];
    permissions = (json['permissions'] as List<dynamic>?)
        ?.map((item) => item as String)
        .toList();
  }
}

class User {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  Organization? organization;
  String? fcmTopic;

  User(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phoneNumber,
      this.organization,
      this.fcmTopic});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    fcmTopic = json['fcmTopic'];
    phoneNumber = json['phoneNumber'];
    organization = json['organization'] != null
        ? Organization.fromJson(json['organization'])
        : null;
  }
}

class Organization {
  String? id;
  String? name;
  bool? isActive;
  bool? isMaster;

  Organization({this.id, this.name, this.isActive, this.isMaster});

  Organization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isActive = json['isActive'];
    isMaster = json['isMaster'];
  }
}

class Role {
  String? id;
  String? name;
  int? position;
  List<String>? granted;
  List<String>? revoked;

  Role({
    this.id,
    this.name,
    this.position,
    this.granted,
    this.revoked,
  });

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    position = json['position'];
    granted = (json['granted'] as List<dynamic>?)
        ?.map((item) => item as String)
        .toList();
    revoked = (json['revoked'] as List<dynamic>?)
        ?.map((item) => item as String)
        .toList();
  }
}

class AuthResponse {
  String? token;
  User? user;

  AuthResponse({this.token, this.user});

  AuthResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? avatarUrl;
  String? device_id;
  bool? isActive;

  User(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.firstName,
      this.lastName,
      this.email,
      this.phoneNumber,
      this.avatarUrl,
      this.isActive,
      this.device_id});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    avatarUrl = (json['avatar_url'] ??
            json['photo_url'] ??
            json['picture'] ??
            json['avatar'])
        ?.toString();
    isActive = json['is_active'];
    device_id = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['avatar_url'] = avatarUrl;
    data['is_active'] = isActive;
    data['device_id'] = device_id;
    return data;
  }
}

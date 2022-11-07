class User {
  String login;
  String password;

  User({required this.login, required this.password});

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        login: parsedJson['login'] ?? "",
        password: parsedJson['password'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "login": login,
      "password": password
    };
  }
}

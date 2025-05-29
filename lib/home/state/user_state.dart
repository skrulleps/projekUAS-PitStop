class UserState {
  static final UserState _instance = UserState._internal();

  factory UserState() {
    return _instance;
  }

  UserState._internal();

  String? _userId;

  String? get userId => _userId;

  void setUserId(String? id) {
    _userId = id;
  }
}

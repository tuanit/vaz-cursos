import 'dart:convert';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vaz_cursos/constants.dart';
import 'package:vaz_cursos/models/auth_user.dart';
import 'package:vaz_cursos/models/teacher.dart';
import 'package:vaz_cursos/models/user.dart';

part 'user.g.dart';

class UserStore = UserStoreBase with _$UserStore;

abstract class UserStoreBase with Store {
  UserStoreBase(this._preferences) {
    this.initUserStore();
  }

  SharedPreferences _preferences;

  @observable
  AuthUser user;

  @action
  Future<void> initUserStore() async {
    this.user = await this.getUser();
  }

  @action
  void setAuthUser(AuthUser authUser) {
    this.user = authUser;
    this._persistUser();
  }

  @action
  void setUser(User user) {
    if (this.user != null) {
      this.user = AuthUser(token: this.user.token, user: user);
      this._persistUser();
    }
  }

  @action
  void setTeacher(Teacher teacher) {
    if (this.user != null) {
      final user = this.user.user;
      user.teacher = teacher;
      this.user = AuthUser(token: this.user.token, user: user);
      this._persistUser();
    }
  }

  @action
  void logout() {
    this.user = null;
    this._persistUser();
  }

  Future<AuthUser> getUser() async {
    final String token = this._preferences.getString(USER_TOKEN_STORAGE) ?? '';
    final String userLogged =
        this._preferences.getString(USER_LOGGED_STORAGE) ?? '';

    if (token.isNotEmpty && userLogged.isNotEmpty) {
      return AuthUser(
        token: token,
        user: User.fromJson(jsonDecode(userLogged)),
      );
    }

    return null;
  }

  void _persistUser() async {
    if (this.user == null) {
      await this._preferences.remove(USER_TOKEN_STORAGE);
      await this._preferences.remove(USER_LOGGED_STORAGE);
      return;
    }

    await this._preferences.setString(USER_TOKEN_STORAGE, this.user.token);
    await this._preferences.setString(
          USER_LOGGED_STORAGE,
          jsonEncode(this.user.user.toJson()),
        );
  }
}

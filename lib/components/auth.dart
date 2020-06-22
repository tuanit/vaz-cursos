import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:vaz_cursos/api.dart';
import 'package:vaz_cursos/models/auth_user.dart';
import 'package:vaz_cursos/models/user.dart';
import 'package:vaz_cursos/store/user.dart';
import 'package:vaz_cursos/utils/validations.dart';

class AuthComponent extends StatefulWidget {
  AuthComponent({Key key, this.instructions, this.dialogCtx}) : super(key: key);

  final String instructions;
  final BuildContext dialogCtx;

  @override
  _AuthComponentState createState() => _AuthComponentState();
}

class _AuthComponentState extends State<AuthComponent> {
  final _formKey = GlobalKey<FormState>();

  var _name = '';
  var _email = '';
  var _password = '';
  var _isLogin = true;

  void _showMessage(String message) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _onPressed(UserStore userStore) async {
    if (_formKey.currentState.validate()) {
      final _url = "/auth/" + (_isLogin ? "login" : "register");

      try {
        final _data =
            FormData.fromMap({'email': _email, 'password': _password});

        if (!_isLogin) {
          _data.fields.add(MapEntry('name', _name));
        }

        var response = await api.post(_url, data: _data);
        final String token = response.data['token'];
        final User user = User.fromJson(response.data['user']);

        userStore.setUser(AuthUser(token: token, user: user));
        _formKey.currentState.reset();

        if (widget.dialogCtx != null) {
          Navigator.of(widget.dialogCtx).pop();
        } else {
          _showMessage('Bem vindo ${user.name}');
        }
      } on DioError catch (e) {
        if (e.response != null) {
          String errorMessage = e.response.data['errors'][0]['message'];
          _showMessage(errorMessage);
        } else {
          _showMessage(
              'Ocorreu um erro inesperado, verifique sua conexão com a internet');
        }
      } catch (e) {
        _showMessage(
            'Ocorreu um erro inesperado, verifique sua conexão com a internet');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);

    final welcomeText = Text(
      widget.instructions != null
          ? widget.instructions
          : 'Bem vindo ao Vaz Cursos',
      style: TextStyle(
        fontSize: 18.0,
      ),
    );

    final formItems = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: welcomeText,
      ),
      if (!_isLogin)
        TextFormField(
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => setState(() {
            _name = value;
          }),
          decoration: const InputDecoration(
            hintText: 'Nome',
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Por favor use um nome válido';
            }
            return null;
          },
        ),
      TextFormField(
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) => setState(() {
          _email = value;
        }),
        decoration: const InputDecoration(
          hintText: 'Email',
        ),
        validator: (value) {
          if (!validateEmail(value)) {
            return 'Por favor use um email válido';
          }
          return null;
        },
      ),
      TextFormField(
        autocorrect: false,
        obscureText: true,
        onChanged: (value) => setState(() {
          _password = value;
        }),
        decoration: const InputDecoration(
          hintText: 'Senha',
        ),
        validator: (value) {
          if (value.isEmpty || value.length < 6) {
            return 'A senha deve ter ao menos 6 caracteres';
          }
          return null;
        },
      ),
      SizedBox(
        width: double.maxFinite,
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () => _onPressed(userStore),
          child: Text(_isLogin ? 'ENTRAR' : 'REGISTRAR'),
        ),
      ),
      FlatButton(
        textColor: Theme.of(context).primaryColor,
        onPressed: () => setState(
          () {
            _formKey.currentState.reset();
            _isLogin = !_isLogin;
          },
        ),
        child: Text(_isLogin ? 'Criar conta' : 'Já tenho uma conta'),
      )
    ];

    if (widget.dialogCtx != null) {
      formItems[0] = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: welcomeText),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(widget.dialogCtx).pop();
            },
          )
        ],
      );
    }

    final form = widget.dialogCtx != null
        ? Wrap(
            alignment: WrapAlignment.center,
            children: formItems,
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: formItems,
          );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: form,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:vaz_cursos/pages/courses.dart';
import 'package:vaz_cursos/pages/home.dart';
import 'package:vaz_cursos/pages/profile.dart';

class TabPage extends StatefulWidget {
  TabPage({Key key}) : super(key: key);

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  var _currentIndex = 0;
  final _children = [
    HomePage(),
    CoursesPage(),
    ProfilePage(),
  ];

  _onTap(int tab) {
    if (_currentIndex != tab) {
      setState(() {
        _currentIndex = tab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaz Cursos'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTap,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Início'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            title: Text('Cursos'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Perfil'),
          ),
        ],
      ),
    );
  }
}

import 'package:chatapp/screens/chats.dart';
import 'package:chatapp/screens/friends.dart';
import 'package:chatapp/screens/search.dart';
import 'package:chatapp/screens/settings.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final String uid;

  const MainPage({Key key, this.uid}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  initPages() {
    String uid = widget.uid;
    screenList = [
      Chats(),
      Search(),
      Friends(),
      Settings(
        uid: uid,
      )
    ];
  }

  @override
  void initState() {
    print(widget.uid);
    initPages();
    super.initState();
  }

  List<Widget> screenList = [];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          currentIndex: _currentIndex,
          selectedFontSize: 16,
          selectedItemColor: Colors.deepOrangeAccent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white.withOpacity(0.5),
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.chat), title: Text('Chats')),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                title: Text(
                  'Search',
                )),
            BottomNavigationBarItem(
                icon: Icon(Icons.contacts), title: Text('Friends')),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text('Settings')),
          ]),
      body: screenList[_currentIndex],
    );
  }
}

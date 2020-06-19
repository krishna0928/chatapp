import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Services/Authentication.dart';
import 'package:chatapp/screens/chats.dart';
import 'package:chatapp/screens/friend_requests.dart';
import 'package:chatapp/screens/friends.dart';
import 'package:chatapp/screens/search.dart';
import 'package:chatapp/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class MainPage extends StatefulWidget {
  final String uid, imageUrl, name;

  const MainPage({Key key, this.uid, this.imageUrl, this.name})
      : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  initPages() {
    String uid = widget.uid;
    screenList = [
      Chats(uid: uid),
      Search(uid: uid),
      Friends(uid: uid),
      FriendRequest(uid: uid),
      Settings(uid: uid)
    ];
  }

  @override
  void initState() {
    initPages();
    super.initState();
  }

  List<Widget> screenList = [];

  int _currentIndex = 0;
  String title = 'Chats';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              ClipOval(
                child: widget.imageUrl != 'null'
                    ? CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        height: 117,
                        width: 117,
                      )
                    : Image.asset('assets/circular_avatar.png',
                        height: 117, width: 117),
              )
            ],
          ),
          GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                  title = 'Chats';
                });
                Navigator.of(context).pop();
              },
              child: getSideTile('Chats', Icons.chat)),
          GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                  title = 'Search';
                });
                Navigator.of(context).pop();
              },
              child: getSideTile('Search', Icons.search)),
          GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                  title = 'Friends';
                });
                Navigator.of(context).pop();
              },
              child: getSideTile('Friends', Icons.contacts)),
          GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                  title = 'Requests';
                });
                Navigator.of(context).pop();
              },
              child: getSideTile('Requests', Icons.format_line_spacing)),
          GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 4;
                  title = 'Settings';
                });
                Navigator.of(context).pop();
              },
              child: getSideTile('Settings', Icons.settings)),
          GestureDetector(
              onTap: () async {
                await AuthServices().logout();
                Phoenix.rebirth(context);
                Navigator.of(context).pop();
              },
              child: getSideTile('Logout', Icons.all_out)),
        ],
      )),
      body: screenList[_currentIndex],
    );
  }

  Widget getSideTile(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.deepOrangeAccent,
          ),
          SizedBox(
            width: 18,
          ),
          Text(title),
        ],
      ),
    );
  }
}

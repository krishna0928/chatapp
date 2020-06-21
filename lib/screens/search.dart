import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/users.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final String uid;

  const Search({Key key, this.uid}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Query _query = Firestore.instance.collection('Users');
  List<Users> _users = [];

  initQuery() {
    _users = [];
    _query
        .where('name', isEqualTo: _searchQuery)
        .snapshots()
        .forEach((element) {
      element.documents.forEach((element) {
        if (element.documentID != widget.uid) {
          setState(() {
            _users.add(Users(
              name: element.data['name'],
              imageUrl: element.data['imageUrl'],
              status: element.data['status'],
              uid: element.documentID,
            ));
          });
        }
      });
    });
  }

  String _searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            )),
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(9),
                child: TextField(
                  onChanged: (value) {
                    if (value.length > 0) {
                      _searchQuery = value;

                      initQuery();
                    }
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade100)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade100)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    contentPadding: EdgeInsets.all(9),
                    border: InputBorder.none,
                    hintText: 'Search your friends',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                )),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _users.length,
                itemBuilder: (_, index) {
                  return Container(
                      margin: EdgeInsets.all(9),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30)),
                      child: ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return ProfileScreen(
                                name: _users[index].name,
                                status: _users[index].status,
                                thumbUrl: _users[index].imageUrl,
                                uid: _users[index].uid,
                                myUid: widget.uid,
                              );
                            }));
                          },
                          title: Text(
                            _users[index].name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(_users[index].status),
                          leading: CircleAvatar(
                              maxRadius: 27,
                              minRadius: 27,
                              backgroundColor: Colors.white,
                              backgroundImage: _users[index].imageUrl == 'null'
                                  ? AssetImage('assets/circular_avatar.png')
                                  : CachedNetworkImageProvider(
                                      _users[index].imageUrl,
                                    ))));
                })
          ],
        ),
      ),
    );
  }
}

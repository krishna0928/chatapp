import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final String uid;

  const Search({Key key, this.uid}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  CustomWidgets _customWidgets = CustomWidgets();
  CollectionReference _usersRef = Firestore.instance.collection('Users');
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
                    setState(() {
                      _searchQuery = value;
                    });
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
            StreamBuilder<QuerySnapshot>(
                stream: _usersRef
                    .where('name', isEqualTo: _searchQuery)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: (_searchQuery != null)
                          ? snapshot.data.documents.length
                          : 0,
                      itemBuilder: (_, index) {
                        if (snapshot.data.documents[index].documentID ==
                            widget.uid) {
                          return Container();
                        } else {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return ProfileScreen(
                                    uid: snapshot
                                        .data.documents[index].documentID,
                                    name: snapshot.data.documents[index]
                                        ['name'],
                                    status: snapshot.data.documents[index]
                                        ['status'],
                                    thumbUrl: snapshot.data.documents[index]
                                        ['imageUrl'],
                                    myUid: widget.uid,
                                  );
                                }));
                              },
                              child: _customWidgets.getDetailedCard(
                                snapshot.data.documents[index]['name'],
                                snapshot.data.documents[index]['status'],
                                snapshot.data.documents[index]['imageUrl'],
                              ));
                        }
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                })
          ],
        ),
      ),
    );
  }
}

import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final String uid;

  const Search({Key key, this.uid}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  CollectionReference _searchRef = Firestore.instance.collection('Users');
  List<DocumentSnapshot> _docs;
  String _searchQuery;
  bool loading = false;

  searchForUser() async {
    setState(() {
      loading = true;
    });
    _docs =
        (await _searchRef.where("name", isEqualTo: _searchQuery).getDocuments())
            .documents;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomAppBar(
          title: 'Search',
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  border: Border.all(width: 0.5, color: Colors.blueGrey)),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          if (_docs != null) {
                            _docs.clear();
                          }
                        });
                        searchForUser();
                      },
                    ),
                    contentPadding: EdgeInsets.all(15),
                    border: InputBorder.none,
                    hintText: 'Search your friends',
                    fillColor: Colors.blueGrey),
              ),
            )),
        if (_docs != null && !loading)
          ListView.builder(
            shrinkWrap: true,
            itemCount: _docs.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ProfileScreen(
                        userMap: _docs[index].data,
                        userID: _docs[index].documentID,
                        myUid: widget.uid,
                      );
                    }));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          maxRadius: 25,
                          minRadius: 25,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _docs[index]['name'],
                              style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              _docs[index]['status'],
                              style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )
      ],
    );
  }
}

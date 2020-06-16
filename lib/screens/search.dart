import 'package:chatapp/models/users.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final String uid;

  const Search({Key key, this.uid}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  CustomWidgets _customWidgets = CustomWidgets();
  DatabaseReference _usersData =
      FirebaseDatabase.instance.reference().child('Users');
  String _searchQuery;
  bool loading = false;
  List<Users> _resultUsers = [];

  searchForUser() async {
    setState(() {
      loading = true;
    });
    _resultUsers.clear();
    if (_searchQuery.length > 0) {
      Query _query = _usersData
          .orderByChild("name")
          .startAt(_searchQuery)
          .endAt(_searchQuery + "\uf8ff");

      await _query.once().then((value) {
        if (value.value != null) {
          value.value.forEach((key, value) {
            if (key != widget.uid) {
              _resultUsers.add(Users(
                  name: value['name'],
                  imageUrl: value['imageUrl'],
                  thumbUrl: value['thumbUrl'],
                  status: value['status'],
                  uid: key));
            }
          });
        }
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: _customWidgets.getCustomAppBar('Search'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(9),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      searchForUser();
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
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
                      onPressed: () {
                        searchForUser();
                      },
                    ),
                    contentPadding: EdgeInsets.all(9),
                    border: InputBorder.none,
                    hintText: 'Search your friends',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                )),
            loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _resultUsers.length,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return ProfileScreen(
                                userData: _resultUsers[index],
                                myUid: widget.uid,
                              );
                            }));
                          },
                          child: _customWidgets.getDetailedCard(
                              _resultUsers[index].name,
                              _resultUsers[index].status,
                              _resultUsers[index].thumbUrl));
                    },
                  )
          ],
        ),
      ),
    );
  }
}

import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final String uid;

  const Search({Key key, this.uid}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomAppBar(
          title: 'Search',
        ),
      ],
    );
  }
}

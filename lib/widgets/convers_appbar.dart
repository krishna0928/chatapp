import 'package:flutter/material.dart';

class ConversAppBar extends StatelessWidget implements PreferredSizeWidget {
  final name;
  final thumbUrl;
  final onlineStatus;

  const ConversAppBar({Key key, this.name, this.thumbUrl, this.onlineStatus})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(
                width: 2,
              ),
              CircleAvatar(
                maxRadius: 20,
                minRadius: 20,
                backgroundColor: Colors.white,
                backgroundImage: thumbUrl == 'null'
                    ? AssetImage('assets/circular_avatar.png')
                    : NetworkImage(thumbUrl),
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 25),
                    ),
                    Text(
                      (onlineStatus == null) ? '' : onlineStatus,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    )
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

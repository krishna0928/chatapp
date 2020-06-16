class ChatsModel {
  String uid;
  String thumbUrl;
  String name;
  String lastMessage;
  String time;
  bool seen;

  ChatsModel(
      {this.uid,
      this.seen,
      this.time,
      this.lastMessage,
      this.name,
      this.thumbUrl});
}

import 'package:flutter/material.dart';
import 'package:no_chat/home/chat.dart';
import 'package:no_chat/home/home_page_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';


/// view of home page
class HomePageView extends HomePageViewModel {
  static const Color _themeColor = Color(0xfff5a623);
  static const Color _primaryColor = Color(0xff203152);
  static const Color _greyColor2 = Color(0xffE8E8E8);

  Widget _buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: CachedNetworkImage(
                  placeholder: (BuildContext context, String url) => Container(
                        child: const CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _themeColor
                          ),
                        ),
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(15),
                      ),
                  imageUrl: document['photoUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${document['nickname']}',
                          style: TextStyle(color: _primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                      ),
                      Container(
                        child: Text(
                          'About me: ${document['aboutMe'] ?? 'Not available'}',
                          style: TextStyle(color: _primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      )
                    ],
                  ),
                  margin: const EdgeInsets.only(left: 20),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => Chat(
                          peerId: document.documentID,
                          peerAvatar: document['photoUrl'],
                        )));
          },
          color: _greyColor2,
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.eject),
            onPressed: logout,
          )
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder<dynamic>(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<dynamic> snapshot
                ) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_themeColor),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (BuildContext context, int index) =>
                        _buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: false==true
                  ? Container(
                      child: Center(
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor)
                        ),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ),
        onWillPop: () async => false
      ),
    );

}
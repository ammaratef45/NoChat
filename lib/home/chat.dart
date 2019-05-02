import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// theme color
const Color themeColor = Color(0xfff5a623);
/// primary color
const Color primaryColor = Color(0xff203152);
/// grey color
const Color greyColor = Color(0xffaeaeae);
/// another grey color
const Color greyColor2 = Color(0xffE8E8E8);
/// caht view
class Chat extends StatelessWidget {
  /// constructor
  const Chat(
    {Key key, this.peerId, this.peerAvatar}
  ) : super(key: key);
  /// peer id
  final String peerId;
  /// peer avatar
  final String peerAvatar;

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
      ),
    );
}

/// chat screen
class ChatScreen extends StatefulWidget {
  ///constructor
  const ChatScreen({Key key, this.peerId, this.peerAvatar}) : super(key: key);
  /// id of peer
  final String peerId;
  /// avatar of peer
  final String peerAvatar;

  @override
  State createState() =>
    ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

/// state of chat screen
class ChatScreenState extends State<ChatScreen> {
  /// constructor
  ChatScreenState({this.peerId, this.peerAvatar});
  /// id of peer
  String peerId;
  /// avatar of peer
  String peerAvatar;
  /// the id
  String id;
  /// list of messages
  List<dynamic> listMessage;
  /// id of group chat
  String groupChatId;
  /// shared prefs
  SharedPreferences prefs;
  /// the image file
  File imageFile;
  /// is loading flag
  bool isLoading;
  /// is show sticker
  bool isShowSticker;
  /// url of image
  String imageUrl;

  ///
  final TextEditingController textEditingController = TextEditingController();
  ///
  final ScrollController listScrollController = ScrollController();
  ///
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  ///
  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  ///
  Future<void> readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    setState(() {});
  }

  ///
  Future<void> getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      await uploadFile();
    }
  }

  ///
  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  ///
  Future<void> uploadFile() async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final StorageReference reference =
      FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask uploadTask = reference.putFile(imageFile);
    final StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    // ignore: avoid_annotating_with_dynamic
    await storageTaskSnapshot.ref.getDownloadURL().then((dynamic downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
      // ignore: avoid_annotating_with_dynamic
    }, onError: (dynamic err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }
  ///
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      final DocumentReference documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.set(
          documentReference,
          <String, dynamic>{
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController
      .animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut
      );
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  ///
  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  width: 200,
                  decoration: BoxDecoration(
                    color: greyColor2, borderRadius: BorderRadius.circular(8)
                  ),
                  margin: EdgeInsets.only(
                    bottom: isLastMessageRight(index) ? 20 : 10, right: 10
                  ),
                )
              : document['type'] == 1
                  // Image
                  ? Container(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (BuildContext context, String url) =>
                              Container(
                                child: const CircularProgressIndicator(
                                  valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                                ),
                                width: 200,
                                height: 200,
                                padding: const EdgeInsets.all(70),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                          errorWidget: (
                            BuildContext context,
                            String url,
                            Object error
                          ) => Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                          imageUrl: document['content'],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                          const BorderRadius.all(Radius.circular(8)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 10, right: 10
                      ),
                    )
                  // Sticker
                  : Container(
                      child: Image.asset(
                        'images/${document['content']}.gif',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      margin:
                        EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20 : 10, right: 10
                        ),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (
                            BuildContext context,
                            String url
                          ) => Container(
                                child: const CircularProgressIndicator(
                                  strokeWidth: 1,
                                  valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                                ),
                                width: 35,
                                height: 35,
                                padding: const EdgeInsets.all(10),
                              ),
                          imageUrl: peerAvatar,
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35),
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        width: 200,
                        decoration:
                          BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8)
                          ),
                        margin: const EdgeInsets.only(left: 10),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (
                                  BuildContext context,
                                  String url
                                ) => Container(
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                            themeColor
                                          ),
                                      ),
                                      width: 200,
                                      height: 200,
                                      padding: const EdgeInsets.all(70),
                                      decoration: BoxDecoration(
                                        color: greyColor2,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                errorWidget: (
                                  BuildContext context,
                                  String url,
                                  Object error
                                ) => Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                imageUrl: document['content'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: 
                                const BorderRadius.all(Radius.circular(8)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            margin: const EdgeInsets.only(left: 10),
                          )
                        : Container(
                            child: Image.asset(
                              'images/${document['content']}.gif',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            margin:
                              EdgeInsets.only(
                                bottom:
                                  isLastMessageRight(index) ? 20 : 10, right: 10
                              ),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm')
                          .format(
                            DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp'])
                            )
                          ),
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                    margin: const EdgeInsets.only(
                      left: 50,
                      top: 5,
                      bottom: 5
                    ),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: const EdgeInsets.only(bottom: 10),
      );
    }
  }

  ///
  bool isLastMessageLeft(int index) {
    if (
      (
        index > 0 && listMessage != null &&
        listMessage[index - 1]['idFrom'] == id
      ) ||
      index == 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  ///
  bool isLastMessageRight(int index) {
    if (
      (
        index > 0 && listMessage != null &&
        listMessage[index - 1]['idFrom'] != id
      ) ||
        index == 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  ///
  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future<bool>.value(false);
  }

  @override
  Widget build(BuildContext context) =>
    WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );

  ///
  Widget buildSticker() =>
    Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'images/mimi2.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'images/mimi3.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'images/mimi4.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'images/mimi5.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: Image.asset(
                  'images/mimi6.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'images/mimi7.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'images/mimi8.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: Image.asset(
                  'images/mimi9.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: greyColor2, width: 0.5)),
            color: Colors.white
          ),
      padding: const EdgeInsets.all(5),
      height: 180,
    );

  ///
  Widget buildLoading() =>
    Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeColor
                  )
                ),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );

  ///
  Widget buildInput() =>
    Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: greyColor2, width: 0.5)),
            color: Colors.white
          ),
    );

  ///
  Widget buildListMessage() =>
    Flexible(
      child: groupChatId == ''
          ? Center(
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)
              )
            )
          : StreamBuilder<dynamic>(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child:
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor))
                        );
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (BuildContext context, int index) =>
                      buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );

}
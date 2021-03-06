import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

DocumentSnapshot snapshot;
final userRef = _firestore.collection('Reviews');
final _firestore = FirebaseFirestore.instance;
User loggedInUser ;

class Reviews extends StatefulWidget {
  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {

  final _auth = FirebaseAuth.instance;
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  Future getUsers() async {
    var data = (await userRef.doc(loggedInUser.email)
        .get())
        .data();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Reviews'),
    ),
      body: FutureBuilder(future: getUsers(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            return GestureDetector(
              onTap: (){
              },
              child: ListView.builder(
                  itemCount: snapshot.data['Reviews'].length,
                  itemBuilder: (context,index){
                    return Card(
                      elevation: 10,
                      child: ListTile(
                        title: Text(snapshot.data['Reviews'][index]),
                        subtitle: Text(snapshot.data['movie-name'][index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: (){
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          title: Text('Write Your Review'),
                                          content: TextFormField(
                                            controller: myController,
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('CANCEL'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Edit'),
                                              onPressed: () {
                                                  Navigator.pop(context);
                                              },
                                            ),
                                          ]
                                      );
                                    }
                                );
                              },
                                child: Icon(Icons.edit,color: Colors.pink)),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _firestore.collection('Reviews').doc(loggedInUser.email).update({
                                    'movie-name':FieldValue.arrayRemove([snapshot.data['movie-name'][index]]),
                                    'Reviews':FieldValue.arrayRemove([snapshot.data['Reviews'][index]]),
                                  });
                                });
                              },
                                child: Icon(Icons.delete,color: Colors.pink)),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            );
          }
        },
      ),
    );
  }
}

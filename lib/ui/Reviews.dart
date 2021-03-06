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

  Future editMovie()async{

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
                    final myController = TextEditingController()..text=snapshot.data['Reviews'][index];
                    return Card(
                      elevation: 10,
                      child: Dismissible(
                        direction: DismissDirection.endToStart,

                        key: UniqueKey(),
                        onDismissed: (direction){
                            _firestore.collection('Reviews').doc(loggedInUser.email).update({
                              'movie-name':FieldValue.arrayRemove([snapshot.data['movie-name'][index]]),
                              'Reviews':FieldValue.arrayRemove([snapshot.data['Reviews'][index]]),
                          });
                            },
                        background: Container(
                          color: Colors.pink,
                        ),
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
                                              autofocus: true,
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
                                                  setState(() {
                                                    _firestore.collection('Reviews').doc(loggedInUser.email).update({
                                                      'Reviews':FieldValue.arrayRemove([snapshot.data['Reviews'][index]]),
                                                      'movie-name':FieldValue.arrayRemove([snapshot.data['movie-name'][index]]),
                                                    }).whenComplete((){
                                                      _firestore.collection('Reviews').doc(loggedInUser.email).update({
                                                        'Reviews':FieldValue.arrayUnion([myController.text]),
                                                        'movie-name':FieldValue.arrayUnion([snapshot.data['movie-name'][index]])
                                                      }).whenComplete((){
                                                        Navigator.pop(context);
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => Reviews()),
                                                        );
                                                      });
                                                    });
                                                  });
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

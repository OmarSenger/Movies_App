import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser ;

class Details extends StatefulWidget {

  final MovieData args;
  Details({Key key, this.args}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

  }

  void getCurrentUser() async {
    try{
      final user = _auth.currentUser;
      if (user!=null){
        loggedInUser = user ;
      }
    }  catch (e){
      print(e);
    }
  }

  var fav = [];
int index ;

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    final myController = TextEditingController();
    Future<void> _displayTextInputDialog(BuildContext context) async {

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Write Your Review'),
            content: TextField(
              controller: myController,
              decoration: InputDecoration(hintText: "Write Your Review Here"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  if (myController.text.isEmpty){
                    Navigator.pop(context);
                  }else {
                    Navigator.pop(context);
                    Flushbar(
                      title: '${widget.args.title} Review :',
                      message: '${myController.text}',
                      duration: Duration(seconds: 4),
                    ).show(context);
                  }
                },
              ),
            ],
          );
        },
      );
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
          child : Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top:MediaQuery.of
                      (context).size.height*0.38),
                    child: Container(
                      width: width,
                      height: height/3,
                      color: Colors.grey.shade200,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.network(widget.args.image),
                          ),
                          Container(
                            width: width/2,
                            height: height*0.5,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top:MediaQuery.of(context).size.height/30),
                                    child: Text(widget.args.title),
                                  ),
                                  SizedBox(height: height*0.05),
                                  Text(widget.args.releaseDate),
                                  SizedBox(height:height*0.1),
                                  RaisedButton(
                                      color: Colors.teal.shade400,
                                      child: Text('Reviews',
                                        style: TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        _displayTextInputDialog(context);
                                      },
                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: height*0.38,
                    width: width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(widget.args.image),
                      ),
                    ),
                  ),
                  Padding(
                    padding:EdgeInsets.only(left: MediaQuery.of(context).size.width*0.92, top: MediaQuery.of(context).size.height*0.01),
                    child: Icon(Icons.share,color: Colors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.31, left: 10),
                    child: Text(widget.args.title, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white)),
                  ),
                  Padding(
                    padding:EdgeInsets.only(top:MediaQuery.of(context).size.height*0.35,left:MediaQuery.of(context).size.width*0.87),
                    child: StatefulBuilder(
                    builder: (context,setState) {
                      return CircleAvatar(
                        radius: 22.0,
                        backgroundColor: Colors.teal.shade400,
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (widget.args.fav==false) {
                                  setState((){
                                    widget.args.fav = !widget.args.fav;
                                  });

                                  _firestore.collection('Favourite').doc(
                                      loggedInUser.uid).set(
                                      {
                                        'movie-name':FieldValue.arrayUnion([widget.args.title]),
                                        'user': loggedInUser.email,
                                      },SetOptions(merge: true));

                                  Flushbar(
                                    title: widget.args.title,
                                    message: 'Added to favourite',
                                    duration: Duration(seconds: 2),
                                  ).show(context);
                                } else if (widget.args.fav==true){
                                  setState((){
                                    widget.args.fav = !widget.args.fav;
                                    fav.add(widget.args.title);
                                    _firestore.collection('Favourite').doc(loggedInUser.uid).update({
                                      'movie-name':FieldValue.arrayRemove(fav)
                                    });
                                  });
                                  Flushbar(
                                    title: widget.args.title,
                                    message: 'Removed from favourite',
                                    duration: Duration(seconds: 2),
                                  ).show(context);
                                }
                              });
                            },
                          child:   IconTheme(
                              data: IconThemeData(color: Colors.white),
                              child: Icon(widget.args.fav?Icons.favorite : Icons
                                  .favorite_border),
                              ),
                        ),
                      );
                    }
                    ),
                  ),
                ],
              ),
              Divider(
                  color: Colors.grey,
                  height: height*0.05,
                  endIndent: width/20,
                  indent: width/20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade400,
                        child: Text('${widget.args.voteAverage}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:5.0),
                        child: Text('Vote Average',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade400,
                        child: Text('${widget.args.popularity}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 9),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:5.0),
                        child: Text('Popularity',style:TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade400,
                        child:Text('${widget.args.language}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:5),
                        child: Text('Main Language',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(
                  color: Colors.grey,
                  height: height*0.02,
                  endIndent: width/20,
                  indent: width/20),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.only(top:10),
                  width: width*0.9,
                  child: Text(
                      widget.args.overview,
                      textAlign: TextAlign.justify),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieData {
  final String image ;
  final String title;
  final String overview;
  final String releaseDate;
  final double voteAverage ;
  final double popularity;
  final String language;
  bool fav;
  MovieData({this.image,this.title,this.overview,this.releaseDate,this.voteAverage,this.popularity,this.language,this.fav});

}

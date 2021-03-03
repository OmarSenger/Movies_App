
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;
List<String> list = [];
bool isFavourited = false ;
User loggedInUser ;
final _auth = FirebaseAuth.instance;
// PopData popData = PopData();

// Future checkMovieFav()async{
//   await _firestore.collection("Favourite").doc(loggedInUser.uid).get().then((value){
//       List.from(value.data()['movie-name']).forEach((element) {
//         list.add(element);
//         if(list.contains(popData.title)){
//           print('x:$element');
//           isFavourited = true;
//         }else {
//           print('y:$element');
//           isFavourited = false ;
//         }
//       });
//   });
// }

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


// class PopData {
//   final String image ;
//   final String title;
//   final String overview;
//   final String releaseDate;
//   final double voteAverage ;
//   final double popularity;
//   final String language;
//   final bool video ;
//   PopData({this.image,this.title,this.overview,this.releaseDate,this.voteAverage,this.popularity,this.language,this.video});
//
// }
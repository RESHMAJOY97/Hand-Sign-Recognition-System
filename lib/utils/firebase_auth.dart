import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  DatabaseReference dbRef;

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      if (user != null)
        return true;
      else
        return false;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      print("Error logging out!");
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      //GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) return false;
      AuthResult res =
          await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));
      if (res.user == null) {
        return false;
      }
      // add in database
      dbRef = FirebaseDatabase.instance
          .reference()
          .child("users")
          .child(res.user.uid);
      if (res.additionalUserInfo.isNewUser) {
        //print("inside new user");
        dbRef.set({
          'userid': res.user.uid,
          'name': res.user.displayName,
          'phone': res.user.phoneNumber,
          'email': res.user.email,
          'profile_pic': res.user.photoUrl,
        }).catchError((err) {
          print(err.toString());
        });
      } else {}
      return true;
    } catch (e) {
      print(e.message);
      print("Error logging with google");
      return false;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Creating an account using email and password
  Future<String> createAccountWithEmail(String name, String email, String password) async {
    try {
      // Create the user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      //update user display name in firebase auth
      await userCredential.user?.updateDisplayName(name);
      //save the details to firebase for proper display and updation of user
      await DbService().saveUserData(name: name, email: email);
      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return "Account created. Please verify your email.";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  // Login using email and password
  Future<String> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Check if the user's email is verified
      if (userCredential.user?.emailVerified ?? false) {
        return "Login Successful";
      } else {
        return "Please verify your email before logging in.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  // Logout
  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Reset password
  Future resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "Mail Sent";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  // Check whether the user is signed in or not
  Future isLoggedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // Resend verification email if the email is not verified
  Future<void> resendVerificationEmail() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("Verification mail has been resent");
    }
  }

  //google sign in
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //user cancels sign in
    if (gUser == null) return;

    //obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    //create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    //sign in
    return await _firebaseAuth.signInWithCredential(credential);
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } on FirebaseException {
      return 'Não foi possível realizar o login. Verifique sua conexão e tente novamente.';
    } catch (_) {
      return 'Não foi possível realizar o login. Tente novamente.';
    }
  }

  Future<String?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } on FirebaseException {
      return 'Não foi possível criar a conta. Verifique sua conexão e tente novamente.';
    } catch (_) {
      return 'Não foi possível criar a conta. Tente novamente.';
    }
  }

  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } on FirebaseException {
      return 'Não foi possível enviar as instruções. Verifique sua conexão e tente novamente.';
    } catch (_) {
      return 'Não foi possível enviar as instruções. Tente novamente.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'ERROR_INVALID_LOGIN_CREDENTIALS':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha informada é muito fraca.';
      case 'network-request-failed':
        return 'Não foi possível conectar ao servidor. Verifique sua conexão.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'requires-recent-login':
        return 'Sua sessão expirou. Faça login novamente.';
      default:
        return 'Não foi possível completar a operação. Tente novamente.';
    }
  }
}

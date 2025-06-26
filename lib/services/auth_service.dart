import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

/// Estado de autenticação do usuário
enum AuthStatus {
  /// Usuário não iniciou autenticação
  initial,
  
  /// Autenticação em andamento
  authenticating,
  
  /// Usuário autenticado
  authenticated,
  
  /// Erro de autenticação
  error
}

/// Serviço de autenticação de usuários
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  
  /// Construtor que configura os listeners de autenticação
  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        _status = AuthStatus.authenticated;
        // Verificar se o Firebase está inicializado antes de configurar o ID do usuário
        if (_firebaseService.isInitialized) {
          await _firebaseService.setUserId(user.uid);
        }
      } else if (_status == AuthStatus.authenticated) {
        _status = AuthStatus.initial;
        // Verificar se o Firebase está inicializado antes de configurar o ID do usuário
        if (_firebaseService.isInitialized) {
          await _firebaseService.setUserId(null);
        }
      }
      notifyListeners();
    });
  }
  
  /// Usuário atual
  User? get currentUser => _auth.currentUser;
  
  /// Estado de autenticação
  AuthStatus get status => _status;
  
  /// Mensagem de erro
  String? get errorMessage => _errorMessage;
  
  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => _auth.currentUser != null;
  
  /// Registra um novo usuário com email e senha
  Future<User?> registrar(String email, String senha) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      // Registrar evento de registro bem-sucedido
      if (_firebaseService.isInitialized) {
        await _firebaseService.logEvent(name: 'sign_up', parameters: {'method': 'email'});
      }
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'A senha é muito fraca.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Este email já está sendo usado por outra conta.';
          break;
        case 'invalid-email':
          _errorMessage = 'O email fornecido é inválido.';
          break;
        default:
          _errorMessage = 'Erro ao registrar: ${e.message}';
      }
      notifyListeners();
      return null;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Erro desconhecido: $e';
      notifyListeners();
      return null;
    }
  }
  
  /// Faz login com email e senha
  Future<User?> login(String email, String senha) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      // Registrar evento de login bem-sucedido
      if (_firebaseService.isInitialized) {
        await _firebaseService.logEvent(name: 'login', parameters: {'method': 'email'});
      }
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          _errorMessage = 'Senha incorreta.';
          break;
        case 'invalid-email':
          _errorMessage = 'O email fornecido é inválido.';
          break;
        case 'user-disabled':
          _errorMessage = 'Esta conta foi desativada.';
          break;
        default:
          _errorMessage = 'Erro ao fazer login: ${e.message}';
      }
      notifyListeners();
      return null;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Erro desconhecido: $e';
      notifyListeners();
      return null;
    }
  }
  
  /// Envia email de redefinição de senha
  Future<bool> resetarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      // Registrar evento de solicitação de redefinição de senha
      if (_firebaseService.isInitialized) {
        await _firebaseService.logEvent(
          name: 'password_reset', 
          parameters: {'method': 'email'}
        );
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Não há usuário registrado com este email.';
          break;
        case 'invalid-email':
          _errorMessage = 'O email fornecido é inválido.';
          break;
        default:
          _errorMessage = 'Erro ao enviar email de redefinição: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Erro desconhecido: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Faz logout do usuário
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _status = AuthStatus.initial;
      notifyListeners();
      
      // Registrar evento de logout
      if (_firebaseService.isInitialized) {
        await _firebaseService.logEvent(name: 'logout');
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Erro ao fazer logout: $e';
      notifyListeners();
    }
  }
}

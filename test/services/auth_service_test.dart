import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:projeto_flutter/services/auth_service.dart';
import 'package:projeto_flutter/services/firebase_service.dart';

import 'auth_service_test.mocks.dart';

// Gere mocks para as classes necessárias
@GenerateMocks([FirebaseAuth, UserCredential, User, FirebaseService])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseService mockFirebaseService;
  late AuthService authService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseService = MockFirebaseService();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    // Configurar o mock para FirebaseAuth.instance
    when(mockUserCredential.user).thenReturn(mockUser);
    
    authService = AuthService();
    // Injetar o mock do FirebaseAuth
    authService.auth = mockFirebaseAuth;
    // Injetar o mock do FirebaseService
    authService.firebaseService = mockFirebaseService;
  });

  group('AuthService', () {
    test('isAuthenticated should return true when user is logged in', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      
      // Act & Assert
      expect(authService.isAuthenticated, true);
    });

    test('isAuthenticated should return false when user is not logged in', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      
      // Act & Assert
      expect(authService.isAuthenticated, false);
    });

    test('registrar should create a new user and return user credentials', () async {
      // Arrange
      final email = 'test@example.com';
      final senha = 'password123';
      
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      )).thenAnswer((_) async => mockUserCredential);
      
      // Act
      final result = await authService.registrar(email, senha);
      
      // Assert
      expect(result, mockUser);
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      )).called(1);
      verify(mockFirebaseService.logEvent(
        name: 'sign_up',
        parameters: {'method': 'email'},
      )).called(1);
      expect(authService.status, AuthStatus.authenticated);
    });

    test('login should authenticate user and return user credentials', () async {
      // Arrange
      final email = 'test@example.com';
      final senha = 'password123';
      
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      )).thenAnswer((_) async => mockUserCredential);
      
      // Act
      final result = await authService.login(email, senha);
      
      // Assert
      expect(result, mockUser);
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      )).called(1);
      verify(mockFirebaseService.logEvent(
        name: 'login',
        parameters: {'method': 'email'},
      )).called(1);
      expect(authService.status, AuthStatus.authenticated);
    });

    test('login should set error status when authentication fails', () async {
      // Arrange
      final email = 'test@example.com';
      final senha = 'wrong_password';
      final errorMessage = 'The password is invalid or the user does not have a password.';
      
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      )).thenThrow(
        FirebaseAuthException(
          code: 'wrong-password',
          message: errorMessage,
        ),
      );
      
      // Act
      final result = await authService.login(email, senha);
      
      // Assert
      expect(result, isNull);
      expect(authService.status, AuthStatus.error);
      expect(authService.errorMessage, 'Senha incorreta.');
    });

    test('logout should sign out user', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      
      // Act
      await authService.logout();
      
      // Assert
      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockFirebaseService.logEvent(name: 'logout')).called(1);
      expect(authService.status, AuthStatus.initial);
      expect(authService.errorMessage, isNull);
    });

    test('resetarSenha should send password reset email', () async {
      // Arrange
      final email = 'test@example.com';
      
      when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .thenAnswer((_) async {});
      
      // Act
      final result = await authService.resetarSenha(email);
      
      // Assert
      expect(result, true);
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
      verify(mockFirebaseService.logEvent(
        name: 'password_reset',
        parameters: {'email': email},
      )).called(1);
      expect(authService.status, AuthStatus.initial);
    });

    test('resetarSenha should handle errors', () async {
      // Arrange
      final email = 'invalid_email';
      
      when(mockFirebaseAuth.sendPasswordResetEmail(email: email)).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
          message: 'There is no user record corresponding to this identifier.',
        ),
      );
      
      // Act
      final result = await authService.resetarSenha(email);
      
      // Assert
      expect(result, false);
      expect(authService.status, AuthStatus.error);
      expect(authService.errorMessage, 'Usuário não encontrado para este email.');
    });

    test('authStateChanges should listen to FirebaseAuth state changes', () async {
      // Arrange
      final controller = StreamController<User?>();
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => controller.stream);
      
      // Act & Assert - Initial state
      expect(authService.status, AuthStatus.initial);
      
      // Act - User logs in
      controller.add(mockUser);
      await Future.delayed(Duration.zero); // Allow stream to process
      
      // Assert - After login
      expect(authService.status, AuthStatus.authenticated);
      verify(mockFirebaseService.setUserId(any)).called(1);
      
      // Act - User logs out
      controller.add(null);
      await Future.delayed(Duration.zero); // Allow stream to process
      
      // Assert - After logout
      expect(authService.status, AuthStatus.initial);
      verify(mockFirebaseService.setUserId(null)).called(1);
      
      // Clean up
      await controller.close();
    });
  });
}

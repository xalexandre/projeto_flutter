import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/services/firestore_service.dart';

import 'firestore_service_test.mocks.dart';

// Gere mocks para as classes necessárias
@GenerateMocks([
  FirebaseFirestore, 
  FirebaseAuth, 
  User,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late FirestoreService firestoreService;
  late MockCollectionReference<Map<String, dynamic>> mockTarefasRef;
  late MockDocumentReference<Map<String, dynamic>> mockUserDocRef;
  late MockDocumentReference<Map<String, dynamic>> mockTarefaDocRef;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockTarefasRef = MockCollectionReference<Map<String, dynamic>>();
    mockUserDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockTarefaDocRef = MockDocumentReference<Map<String, dynamic>>();
    
    firestoreService = FirestoreService();
    // Injetar mocks
    firestoreService.firestore = mockFirestore;
    firestoreService.auth = mockAuth;
    
    // Configurar mocks
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');
    
    // Configurar a cadeia de referências do Firestore
    when(mockFirestore.collection('usuarios'))
        .thenReturn(MockCollectionReference<Map<String, dynamic>>());
    when(mockFirestore.collection('usuarios').doc('test_user_id'))
        .thenReturn(mockUserDocRef);
    when(mockFirestore.collection('usuarios').doc('test_user_id').collection('tarefas'))
        .thenReturn(mockTarefasRef);
  });

  group('FirestoreService', () {
    test('carregarTarefas should return empty list when user is not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      
      // Act
      final result = await firestoreService.carregarTarefas();
      
      // Assert
      expect(result, isEmpty);
    });

    test('carregarTarefas should return list of tasks from Firestore', () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockTarefasRef.get()).thenAnswer((_) async => mockQuerySnapshot);
      
      when(mockQuerySnapshot.docs).thenReturn([
        mockQueryDocSnapshot1,
        mockQueryDocSnapshot2,
      ]);
      
      when(mockQueryDocSnapshot1.id).thenReturn('task1');
      when(mockQueryDocSnapshot1.data()).thenReturn({
        'nome': 'Tarefa 1',
        'descricao': 'Descrição da tarefa 1',
        'concluida': false,
        'dataHora': Timestamp.fromDate(DateTime(2025, 6, 25)),
      });
      
      when(mockQueryDocSnapshot2.id).thenReturn('task2');
      when(mockQueryDocSnapshot2.data()).thenReturn({
        'nome': 'Tarefa 2',
        'descricao': 'Descrição da tarefa 2',
        'concluida': true,
        'dataHora': Timestamp.fromDate(DateTime(2025, 6, 26)),
      });
      
      // Act
      final result = await firestoreService.carregarTarefas();
      
      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, 'task1');
      expect(result[0].nome, 'Tarefa 1');
      expect(result[0].concluida, false);
      expect(result[1].id, 'task2');
      expect(result[1].nome, 'Tarefa 2');
      expect(result[1].concluida, true);
    });

    test('adicionarTarefa should add task to Firestore with new ID', () async {
      // Arrange
      final tarefa = Tarefa(
        id: '',
        nome: 'Nova Tarefa',
        descricao: 'Descrição da nova tarefa',
        concluida: false,
        dataHora: DateTime(2025, 6, 25),
      );
      
      when(mockTarefasRef.add(any)).thenAnswer((_) async => mockTarefaDocRef);
      when(mockTarefaDocRef.id).thenReturn('new_task_id');
      
      // Act
      final result = await firestoreService.adicionarTarefa(tarefa);
      
      // Assert
      expect(result, 'new_task_id');
      verify(mockTarefasRef.add(any)).called(1);
    });

    test('adicionarTarefa should add task to Firestore with existing ID', () async {
      // Arrange
      final tarefa = Tarefa(
        id: 'existing_id',
        nome: 'Tarefa Existente',
        descricao: 'Descrição da tarefa existente',
        concluida: false,
        dataHora: DateTime(2025, 6, 25),
      );
      
      when(mockTarefasRef.doc('existing_id')).thenReturn(mockTarefaDocRef);
      when(mockTarefaDocRef.set(any)).thenAnswer((_) async => {});
      
      // Act
      final result = await firestoreService.adicionarTarefa(tarefa);
      
      // Assert
      expect(result, 'existing_id');
      verify(mockTarefaDocRef.set(any)).called(1);
    });

    test('adicionarTarefa should throw exception when user is not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      
      final tarefa = Tarefa(
        id: '',
        nome: 'Nova Tarefa',
        descricao: 'Descrição da nova tarefa',
        concluida: false,
        dataHora: DateTime(2025, 6, 25),
      );
      
      // Act & Assert
      expect(() => firestoreService.adicionarTarefa(tarefa), throwsException);
    });
    
    test('atualizarTarefa should update task in Firestore', () async {
      // Arrange
      final tarefa = Tarefa(
        id: 'task_id',
        nome: 'Tarefa Atualizada',
        descricao: 'Descrição atualizada',
        concluida: true,
        dataHora: DateTime(2025, 6, 30),
      );
      
      when(mockTarefasRef.doc('task_id')).thenReturn(mockTarefaDocRef);
      when(mockTarefaDocRef.update(any)).thenAnswer((_) async => {});
      
      // Act
      await firestoreService.atualizarTarefa(tarefa);
      
      // Assert
      verify(mockTarefaDocRef.update(any)).called(1);
    });
    
    test('atualizarTarefa should throw exception when user is not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      
      final tarefa = Tarefa(
        id: 'task_id',
        nome: 'Tarefa Atualizada',
        descricao: 'Descrição atualizada',
        concluida: true,
        dataHora: DateTime(2025, 6, 30),
      );
      
      // Act & Assert
      expect(() => firestoreService.atualizarTarefa(tarefa), throwsException);
    });
    
    test('removerTarefa should delete task from Firestore', () async {
      // Arrange
      const tarefaId = 'task_to_delete';
      
      when(mockTarefasRef.doc(tarefaId)).thenReturn(mockTarefaDocRef);
      when(mockTarefaDocRef.delete()).thenAnswer((_) async => {});
      
      // Act
      await firestoreService.removerTarefa(tarefaId);
      
      // Assert
      verify(mockTarefaDocRef.delete()).called(1);
    });
    
    test('marcarComoConcluida should update task completion status', () async {
      // Arrange
      const tarefaId = 'task_id';
      const concluida = true;
      
      when(mockTarefasRef.doc(tarefaId)).thenReturn(mockTarefaDocRef);
      when(mockTarefaDocRef.update({'concluida': concluida})).thenAnswer((_) async => {});
      
      // Act
      await firestoreService.marcarComoConcluida(tarefaId, concluida);
      
      // Assert
      verify(mockTarefaDocRef.update({'concluida': concluida})).called(1);
    });
    
    test('observarTarefas should return stream of tasks', () async {
      // Arrange
      final mockQuerySnapshot1 = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockTarefasRef.snapshots()).thenAnswer((_) => 
        Stream.fromIterable([mockQuerySnapshot1]));
      
      when(mockQuerySnapshot1.docs).thenReturn([mockQueryDocSnapshot1]);
      
      when(mockQueryDocSnapshot1.id).thenReturn('stream_task');
      when(mockQueryDocSnapshot1.data()).thenReturn({
        'nome': 'Tarefa do Stream',
        'descricao': 'Descrição da tarefa do stream',
        'concluida': false,
        'dataHora': Timestamp.fromDate(DateTime(2025, 6, 25)),
      });
      
      // Act
      final stream = firestoreService.observarTarefas();
      
      // Assert
      await expectLater(
        stream,
        emits(predicate<List<Tarefa>>((tarefas) => 
          tarefas.length == 1 && 
          tarefas[0].id == 'stream_task' && 
          tarefas[0].nome == 'Tarefa do Stream'
        )),
      );
    });
    
    test('observarTarefas should return empty stream when user is not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      
      // Act
      final stream = firestoreService.observarTarefas();
      
      // Assert
      await expectLater(stream, emits(isEmpty));
    });
    
    test('salvarPerfilUsuario should save user profile to Firestore', () async {
      // Arrange
      const nome = 'Test User';
      const fotoUrl = 'https://example.com/photo.jpg';
      
      when(mockUser.email).thenReturn('test@example.com');
      when(mockFirestore.collection('usuarios').doc('test_user_id'))
          .thenReturn(mockUserDocRef);
      when(mockUserDocRef.set(any, any)).thenAnswer((_) async => {});
      
      // Act
      await firestoreService.salvarPerfilUsuario(nome, fotoUrl);
      
      // Assert
      verify(mockUserDocRef.set(
        {
          'nome': nome,
          'email': 'test@example.com',
          'fotoUrl': fotoUrl,
          'ultimoAcesso': any,
        },
        any,
      )).called(1);
    });
    
    test('salvarPerfilUsuario should throw exception when user is not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      
      // Act & Assert
      expect(() => firestoreService.salvarPerfilUsuario('Nome', 'url'), throwsException);
    });
  });
}

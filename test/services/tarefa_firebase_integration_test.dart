import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/repositories/adaptive_repository.dart';
import 'package:projeto_flutter/services/auth_service.dart';
import 'package:projeto_flutter/services/firestore_service.dart';
import 'package:projeto_flutter/services/notification_service.dart';
import 'package:projeto_flutter/services/tarefa_service.dart';

import 'tarefa_firebase_integration_test.mocks.dart';

@GenerateMocks([
  AdaptiveRepository, 
  FirestoreService, 
  NotificationService,
  AuthService,
])
void main() {
  late MockAdaptiveRepository mockRepository;
  late MockFirestoreService mockFirestoreService;
  late MockNotificationService mockNotificationService;
  late MockAuthService mockAuthService;
  late TarefaService tarefaService;

  setUp(() {
    mockRepository = MockAdaptiveRepository();
    mockFirestoreService = MockFirestoreService();
    mockNotificationService = MockNotificationService();
    mockAuthService = MockAuthService();
    
    tarefaService = TarefaService(mockRepository);
    // Injetar os mocks
    tarefaService.firestoreService = mockFirestoreService;
    tarefaService.notificationService = mockNotificationService;
    tarefaService.auth = mockAuthService;
  });

  group('TarefaService Firebase Integration', () {
    test('deve carregar tarefas do repositório local quando não autenticado', () async {
      // Arrange
      final tarefasLocais = [
        Tarefa(id: 'local1', nome: 'Tarefa Local 1', descricao: 'Descrição 1', concluida: false, dataHora: DateTime(2025, 6, 25)),
        Tarefa(id: 'local2', nome: 'Tarefa Local 2', descricao: 'Descrição 2', concluida: true, dataHora: DateTime(2025, 6, 26)),
      ];
      
      when(mockAuthService.isAuthenticated).thenReturn(false);
      when(mockRepository.carregarTarefas()).thenAnswer((_) async => tarefasLocais);
      
      // Act
      await tarefaService.carregarTarefas();
      
      // Assert
      expect(tarefaService.tarefas, equals(tarefasLocais));
      verify(mockRepository.carregarTarefas()).called(1);
      verifyNever(mockFirestoreService.carregarTarefas());
    });

    test('deve carregar tarefas do Firestore quando autenticado', () async {
      // Arrange
      final tarefasFirestore = [
        Tarefa(id: 'cloud1', nome: 'Tarefa Nuvem 1', descricao: 'Descrição 1', concluida: false, dataHora: DateTime(2025, 6, 25)),
        Tarefa(id: 'cloud2', nome: 'Tarefa Nuvem 2', descricao: 'Descrição 2', concluida: true, dataHora: DateTime(2025, 6, 26)),
      ];
      
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockFirestoreService.carregarTarefas()).thenAnswer((_) async => tarefasFirestore);
      
      // Act
      await tarefaService.carregarTarefas();
      
      // Assert
      expect(tarefaService.tarefas, equals(tarefasFirestore));
      verifyNever(mockRepository.carregarTarefas());
      verify(mockFirestoreService.carregarTarefas()).called(1);
    });

    test('deve sincronizar tarefas com Firestore quando o usuário se autentica', () async {
      // Arrange
      final tarefasLocais = [
        Tarefa(id: 'local1', nome: 'Tarefa Local 1', descricao: 'Descrição 1', concluida: false, dataHora: DateTime(2025, 6, 25)),
        Tarefa(id: 'local2', nome: 'Tarefa Local 2', descricao: 'Descrição 2', concluida: true, dataHora: DateTime(2025, 6, 26)),
      ];
      
      // Inicialmente não autenticado
      when(mockAuthService.isAuthenticated).thenReturn(false);
      when(mockRepository.carregarTarefas()).thenAnswer((_) async => tarefasLocais);
      
      // Carrega tarefas locais
      await tarefaService.carregarTarefas();
      expect(tarefaService.tarefas, equals(tarefasLocais));
      
      // Simula autenticação
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockFirestoreService.carregarTarefas()).thenAnswer((_) async => []);
      
      // Act - Sincroniza com o Firestore
      await tarefaService.sincronizarComFirestore();
      
      // Assert - Deve enviar tarefas locais para o Firestore
      for (var tarefa in tarefasLocais) {
        verify(mockFirestoreService.adicionarTarefa(tarefa)).called(1);
      }
    });
    
    test('deve adicionar tarefa ao Firestore quando autenticado', () async {
      // Arrange
      final novaTarefa = Tarefa(
        id: '',
        nome: 'Nova Tarefa',
        descricao: 'Descrição da tarefa',
        concluida: false,
        dataHora: DateTime(2025, 6, 25),
      );
      
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockFirestoreService.adicionarTarefa(any)).thenAnswer((_) async => 'firestore_id');
      
      // Act
      await tarefaService.adicionarTarefa(novaTarefa);
      
      // Assert
      verify(mockFirestoreService.adicionarTarefa(any)).called(1);
      verify(mockRepository.adicionarTarefa(any)).called(1);
      expect(tarefaService.tarefas.length, 1);
      expect(tarefaService.tarefas[0].id, 'firestore_id');
    });
    
    test('deve adicionar tarefa apenas ao repositório local quando não autenticado', () async {
      // Arrange
      final novaTarefa = Tarefa(
        id: '',
        nome: 'Nova Tarefa',
        descricao: 'Descrição da tarefa',
        concluida: false,
        dataHora: DateTime(2025, 6, 25),
      );
      
      when(mockAuthService.isAuthenticated).thenReturn(false);
      when(mockRepository.adicionarTarefa(any)).thenAnswer((_) async => 'local_id');
      
      // Act
      await tarefaService.adicionarTarefa(novaTarefa);
      
      // Assert
      verify(mockRepository.adicionarTarefa(any)).called(1);
      verifyNever(mockFirestoreService.adicionarTarefa(any));
      expect(tarefaService.tarefas.length, 1);
      expect(tarefaService.tarefas[0].id, 'local_id');
    });
    
    test('deve atualizar tarefa no Firestore quando autenticado', () async {
      // Arrange
      final tarefa = Tarefa(
        id: 'tarefa_id',
        nome: 'Tarefa Atualizada',
        descricao: 'Descrição atualizada',
        concluida: true,
        dataHora: DateTime(2025, 6, 25),
      );
      
      when(mockAuthService.isAuthenticated).thenReturn(true);
      
      // Act
      await tarefaService.atualizarTarefa(tarefa);
      
      // Assert
      verify(mockFirestoreService.atualizarTarefa(tarefa)).called(1);
      verify(mockRepository.atualizarTarefa(tarefa)).called(1);
    });
    
    test('deve remover tarefa do Firestore quando autenticado', () async {
      // Arrange
      const tarefaId = 'tarefa_id';
      when(mockAuthService.isAuthenticated).thenReturn(true);
      
      // Act
      await tarefaService.removerTarefa(tarefaId);
      
      // Assert
      verify(mockFirestoreService.removerTarefa(tarefaId)).called(1);
      verify(mockRepository.removerTarefa(tarefaId)).called(1);
    });
    
    test('deve observar tarefas do Firestore quando autenticado', () async {
      // Arrange
      final tarefas = [
        Tarefa(id: 'stream1', nome: 'Tarefa Stream 1', descricao: 'Descrição 1', concluida: false, dataHora: DateTime(2025, 6, 25)),
      ];
      
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockFirestoreService.observarTarefas()).thenAnswer((_) => Stream.value(tarefas));
      
      // Act & Assert
      expect(tarefaService.observarTarefas(), emits(tarefas));
    });
    
    test('deve lidar com erro ao carregar tarefas do Firestore', () async {
      // Arrange
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockFirestoreService.carregarTarefas()).thenThrow(Exception('Erro no Firestore'));
      
      // Act
      await tarefaService.carregarTarefas();
      
      // Assert
      expect(tarefaService.erro, isNotNull);
      expect(tarefaService.isLoading, isFalse);
    });
  });
}

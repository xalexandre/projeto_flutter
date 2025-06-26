import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tarefa.dart';

/// Serviço para manipulação de dados no Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Retorna a referência para a coleção de tarefas do usuário atual
  CollectionReference<Map<String, dynamic>> get _tarefasRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }
    return _firestore.collection('usuarios').doc(userId).collection('tarefas');
  }
  
  /// Carrega tarefas do Firestore
  Future<List<Tarefa>> carregarTarefas() async {
    try {
      if (_auth.currentUser == null) {
        return [];
      }
      
      final snapshot = await _tarefasRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Garantir que o ID está no objeto
        return Tarefa.fromMap(data);
      }).toList();
    } catch (e) {
      print('FirestoreService: Erro ao carregar tarefas: $e');
      rethrow;
    }
  }
  
  /// Adiciona uma tarefa ao Firestore
  Future<String> adicionarTarefa(Tarefa tarefa) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Remover o ID para que o Firestore gere um novo
      final tarefaMap = tarefa.toMap();
      final id = tarefa.id;
      tarefaMap.remove('id');
      
      // Se o ID já existe, usar como documento ID
      if (id.isNotEmpty) {
        await _tarefasRef.doc(id).set(tarefaMap);
        return id;
      } else {
        // Caso contrário, deixar o Firestore gerar um novo ID
        final docRef = await _tarefasRef.add(tarefaMap);
        return docRef.id;
      }
    } catch (e) {
      print('FirestoreService: Erro ao adicionar tarefa: $e');
      rethrow;
    }
  }
  
  /// Atualiza uma tarefa no Firestore
  Future<void> atualizarTarefa(Tarefa tarefa) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Usuário não autenticado');
      }
      
      final tarefaMap = tarefa.toMap();
      tarefaMap.remove('id'); // Remover o ID do mapa
      
      await _tarefasRef.doc(tarefa.id).update(tarefaMap);
    } catch (e) {
      print('FirestoreService: Erro ao atualizar tarefa: $e');
      rethrow;
    }
  }
  
  /// Remove uma tarefa do Firestore
  Future<void> removerTarefa(String id) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Usuário não autenticado');
      }
      
      await _tarefasRef.doc(id).delete();
    } catch (e) {
      print('FirestoreService: Erro ao remover tarefa: $e');
      rethrow;
    }
  }
  
  /// Marca uma tarefa como concluída ou não concluída
  Future<void> marcarComoConcluida(String id, bool concluida) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Usuário não autenticado');
      }
      
      await _tarefasRef.doc(id).update({'concluida': concluida});
    } catch (e) {
      print('FirestoreService: Erro ao marcar tarefa como concluída: $e');
      rethrow;
    }
  }
  
  /// Configura um listener para mudanças nas tarefas
  Stream<List<Tarefa>> observarTarefas() {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }
    
    return _tarefasRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Tarefa.fromMap(data);
      }).toList();
    });
  }
  
  /// Salva informações do perfil do usuário
  Future<void> salvarPerfilUsuario(String nome, String? fotoUrl) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Usuário não autenticado');
      }
      
      await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).set({
        'nome': nome,
        'email': _auth.currentUser!.email,
        'fotoUrl': fotoUrl,
        'ultimoAcesso': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('FirestoreService: Erro ao salvar perfil do usuário: $e');
      rethrow;
    }
  }
}

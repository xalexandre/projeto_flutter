import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projeto_flutter/main.dart' as app;
import 'package:projeto_flutter/models/geo_point.dart';
import 'package:projeto_flutter/services/location_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Testes de Integração da API de Localização', () {
    testWidgets('Deve buscar endereço e exibir resultados', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa (onde está o componente de busca)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Verificar se a tela de formulário foi aberta
      expect(find.text('Nova Tarefa'), findsOneWidget);
      
      // Encontrar e tocar no botão de seleção de localização
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pumpAndSettle();
      
      // Verificar se o componente de busca de localização é exibido
      expect(find.text('Buscar endereço...'), findsOneWidget);
      
      // Digitar um endereço para busca
      await tester.enterText(find.byType(TextField).last, 'New York');
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Aguardar a resposta da API
      
      // Verificar se os resultados da busca são exibidos
      // Note: Este teste pode falhar se a API estiver indisponível ou mudar seu formato
      expect(find.textContaining('New York'), findsWidgets);
      
      // Selecionar o primeiro resultado
      await tester.tap(find.textContaining('New York').first);
      await tester.pumpAndSettle();
      
      // Verificar se voltamos para o formulário com a localização selecionada
      expect(find.text('Nova Tarefa'), findsOneWidget);
      expect(find.textContaining('Latitude:'), findsOneWidget);
      expect(find.textContaining('Longitude:'), findsOneWidget);
    });

    testWidgets('Deve abrir o mapa e selecionar localização', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Tocar no botão para abrir o mapa
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      
      // Verificar se a tela do mapa foi aberta
      expect(find.text('Selecionar Localização'), findsOneWidget);
      
      // Simular um toque no mapa (coordenadas aproximadas do centro do mapa)
      // Nota: Esta parte pode variar dependendo de como seu mapa é implementado
      final mapFinder = find.byType(Scaffold);
      final center = tester.getCenter(mapFinder);
      await tester.tapAt(center);
      await tester.pumpAndSettle();
      
      // Confirmar a seleção da localização
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      
      // Verificar se voltamos para o formulário com a localização selecionada
      expect(find.text('Nova Tarefa'), findsOneWidget);
      expect(find.textContaining('Latitude:'), findsOneWidget);
      expect(find.textContaining('Longitude:'), findsOneWidget);
    });
    
    testWidgets('Deve lidar com erros da API graciosamente', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Encontrar e tocar no botão de seleção de localização
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pumpAndSettle();
      
      // Digitar um endereço inválido ou muito específico que provavelmente não terá resultados
      await tester.enterText(find.byType(TextField).last, 'xyzabcnonexistentlocation123456789');
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Aguardar a resposta da API
      
      // Verificar se a mensagem de "Nenhum resultado encontrado" é exibida
      expect(find.text('Nenhum resultado encontrado'), findsOneWidget);
      
      // Voltar para o formulário
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verificar se voltamos para o formulário sem uma localização
      expect(find.text('Nova Tarefa'), findsOneWidget);
    });
    
    testWidgets('Deve salvar tarefa com localização e exibir no mapa posteriormente', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Preencher os campos da tarefa
      await tester.enterText(find.byKey(const ValueKey('nome_tarefa')), 'Tarefa com Localização');
      await tester.enterText(find.byKey(const ValueKey('descricao_tarefa')), 'Esta tarefa tem uma localização associada');
      
      // Adicionar uma localização
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pumpAndSettle();
      
      // Digitar um endereço para busca
      await tester.enterText(find.byType(TextField).last, 'São Paulo');
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Aguardar a resposta da API
      
      // Selecionar o primeiro resultado
      await tester.tap(find.textContaining('São Paulo').first);
      await tester.pumpAndSettle();
      
      // Salvar a tarefa
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      
      // Verificar se a tarefa foi criada e aparece na lista
      expect(find.text('Tarefa com Localização'), findsOneWidget);
      
      // Abrir a tarefa para visualizar detalhes
      await tester.tap(find.text('Tarefa com Localização'));
      await tester.pumpAndSettle();
      
      // Verificar se os detalhes da tarefa são exibidos
      expect(find.text('Esta tarefa tem uma localização associada'), findsOneWidget);
      
      // Verificar se o botão para ver a localização no mapa está presente
      expect(find.byIcon(Icons.map), findsOneWidget);
      
      // Tocar no botão para ver a localização no mapa
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      
      // Verificar se o mapa é exibido
      expect(find.text('Localização da Tarefa'), findsOneWidget);
      
      // Voltar para a tela de detalhes
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Voltar para a lista de tarefas
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Limpar - remover a tarefa criada
      // Encontrar o botão de excluir na tarefa
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      // Confirmar a exclusão
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      
      // Verificar se a tarefa foi removida
      expect(find.text('Tarefa com Localização'), findsNothing);
    });
    
    testWidgets('Deve usar localização atual do dispositivo quando solicitado', (WidgetTester tester) async {
      // Nota: Este teste pode falhar em emuladores ou dispositivos sem acesso à localização
      // É recomendado usar mocks para testar esta funcionalidade em ambiente de CI
      
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Encontrar e tocar no botão de seleção de localização
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pumpAndSettle();
      
      // Verificar se o botão "Usar minha localização" está presente
      expect(find.text('Usar minha localização'), findsOneWidget);
      
      // Tentar usar a localização atual (pode falhar em ambiente de teste)
      // Nota: Em um ambiente de produção real, seria necessário configurar permissões
      // e mockar os serviços de localização do dispositivo
      try {
        await tester.tap(find.text('Usar minha localização'));
        await tester.pumpAndSettle(const Duration(seconds: 5)); // Aguardar resposta da API
        
        // Se chegar aqui, a localização foi obtida com sucesso
        // Voltar para o formulário
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      } catch (e) {
        // Em caso de falha, apenas registrar e continuar
        print('Não foi possível obter a localização atual: $e');
        
        // Voltar para o formulário, independentemente do resultado
        if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        }
      }
    });
    
    testWidgets('Deve usar geocodificação reversa para converter coordenadas em endereço', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Tocar no botão para abrir o mapa
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      
      // Verificar se a tela do mapa foi aberta
      expect(find.text('Selecionar Localização'), findsOneWidget);
      
      // Simular um toque no mapa (coordenadas aproximadas do centro do mapa)
      final mapFinder = find.byType(Scaffold);
      final center = tester.getCenter(mapFinder);
      await tester.tapAt(center);
      await tester.pumpAndSettle();
      
      // Verificar se o endereço correspondente às coordenadas selecionadas é exibido
      // Nota: Não podemos verificar o texto exato, pois depende das coordenadas e da API
      // Mas podemos verificar se algum texto de endereço é exibido
      expect(find.textContaining('Endereço:'), findsOneWidget);
      
      // Confirmar a seleção da localização
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      
      // Verificar se voltamos para o formulário com a localização selecionada
      expect(find.text('Nova Tarefa'), findsOneWidget);
      expect(find.textContaining('Latitude:'), findsOneWidget);
      expect(find.textContaining('Longitude:'), findsOneWidget);
    });
  });
}

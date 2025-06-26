// Arquivo para gerar mocks usando o comando:
// dart generate_mocks.dart

import 'dart:io';

void main() async {
  print('Gerando arquivos de mock para testes...');
  
  // Executar o comando para gerar os mocks
  final result = await Process.run('flutter', ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs']);
  
  if (result.exitCode == 0) {
    print('✅ Mocks gerados com sucesso!');
    print(result.stdout);
  } else {
    print('❌ Erro ao gerar mocks:');
    print(result.stderr);
  }
}

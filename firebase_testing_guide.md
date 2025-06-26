# Guia de Teste da Integração com Firebase

Este documento fornece instruções detalhadas sobre como configurar, executar e testar a integração do Firebase no projeto de gerenciamento de tarefas.

## 1. Configuração do Projeto Firebase

### 1.1. Criar um Projeto no Firebase Console

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Dê um nome ao seu projeto, por exemplo, "Gerenciador de Tarefas"
4. Opcionalmente, ative o Google Analytics
5. Clique em "Criar projeto"

### 1.2. Adicionar Aplicativos ao Projeto Firebase

#### Para Web:

1. Na página inicial do projeto, clique no ícone da Web (</>) para adicionar um app da Web
2. Registre o app com o nome "Gerenciador de Tarefas Web"
3. Copie o objeto `firebaseConfig` gerado. Você precisará dele mais tarde

#### Para Android:

1. Na página inicial do projeto, clique no ícone do Android para adicionar um app Android
2. Use o pacote `br.com.brodt.projeto_flutter` como ID do pacote Android
3. Registre o app e faça o download do arquivo `google-services.json`
4. Coloque o arquivo na pasta `android/app/` do seu projeto Flutter

#### Para iOS (se aplicável):

1. Na página inicial do projeto, clique no ícone do iOS para adicionar um app iOS
2. Registre o app com seu Bundle ID
3. Faça o download do arquivo `GoogleService-Info.plist`
4. Adicione o arquivo ao projeto iOS usando o Xcode

### 1.3. Ativar Serviços Necessários

#### Authentication:

1. No menu lateral, clique em "Authentication"
2. Vá para a aba "Sign-in method"
3. Habilite o método "E-mail/senha"

#### Firestore Database:

1. No menu lateral, clique em "Firestore Database"
2. Clique em "Criar banco de dados"
3. Comece no modo de teste (permitir leitura/escrita para todos inicialmente)
4. Escolha uma localização para o banco de dados (preferencialmente próxima aos seus usuários)

#### Cloud Messaging (opcional para notificações push):

1. No menu lateral, clique em "Cloud Messaging"
2. Configure as notificações conforme necessário

## 2. Configuração do Projeto Flutter

### 2.1. Configurar o Web

1. Abra o arquivo `web/index.html`
2. Substitua o objeto de configuração no bloco de script do Firebase pelo seu objeto `firebaseConfig`:

```javascript
const firebaseConfig = {
  apiKey: "SEU_API_KEY",
  authDomain: "seu-projeto.firebaseapp.com",
  projectId: "seu-projeto",
  storageBucket: "seu-projeto.appspot.com",
  messagingSenderId: "SEU_MESSAGING_SENDER_ID",
  appId: "SEU_APP_ID",
  measurementId: "SEU_MEASUREMENT_ID"
};
```

### 2.2. Configurar o Android

Certifique-se de que o arquivo `google-services.json` está na pasta `android/app/`.

### 2.3. Configurar o iOS (se aplicável)

Certifique-se de que o arquivo `GoogleService-Info.plist` foi adicionado ao seu projeto iOS.

## 3. Testando a Integração com Firebase

### 3.1. Executar o Aplicativo

1. Execute o aplicativo com o comando:
   ```
   flutter run
   ```

2. Se estiver testando no navegador, use:
   ```
   flutter run -d chrome
   ```

### 3.2. Testar o Registro de Usuário

1. Ao iniciar o aplicativo, você será redirecionado para a tela de login
2. Clique em "Não tem uma conta? Registre-se"
3. Preencha os campos de email e senha
4. Clique em "Registrar"
5. Você deve ser redirecionado para a tela principal se o registro for bem-sucedido
6. Verifique no Firebase Console > Authentication se o usuário foi criado

### 3.3. Testar o Login

1. Se já estiver logado, faça logout clicando no ícone de logout na barra superior
2. Na tela de login, preencha o email e senha cadastrados
3. Clique em "Entrar"
4. Você deve ser redirecionado para a tela principal

### 3.4. Testar a Recuperação de Senha

1. Na tela de login, clique em "Esqueci minha senha"
2. Digite o email cadastrado
3. Você receberá um email com instruções para redefinir sua senha
4. Verifique sua caixa de entrada e siga as instruções

### 3.5. Testar a Sincronização de Tarefas

1. Após fazer login, adicione algumas tarefas
2. Verifique no Firebase Console > Firestore Database se as tarefas foram salvas
3. A estrutura de dados deve ser:
   ```
   usuarios/{user_id}/tarefas/{task_id}
   ```

4. Faça logout e login novamente para verificar se as tarefas são carregadas do Firestore
5. Adicione, edite e exclua tarefas para testar a sincronização em tempo real

### 3.6. Testar em Múltiplos Dispositivos

1. Execute o aplicativo em dois dispositivos diferentes (ou navegadores) simultaneamente
2. Faça login com o mesmo usuário em ambos
3. Adicione ou modifique tarefas em um dispositivo
4. Verifique se as alterações são refletidas no outro dispositivo

## 4. Solução de Problemas Comuns

### 4.1. Problemas de Inicialização do Firebase

**Sintoma:** Erro "Firebase App named '[DEFAULT]' already exists"

**Solução:** Certifique-se de que `Firebase.initializeApp()` é chamado apenas uma vez. Isso está configurado no `main.dart`.

### 4.2. Problemas de Autenticação

**Sintoma:** Erro ao tentar registrar ou fazer login

**Solução:**
- Verifique se o método de autenticação por email/senha está habilitado no Firebase Console
- Verifique se o email é válido e a senha tem pelo menos 6 caracteres
- Verifique os logs para mensagens de erro específicas

### 4.3. Problemas com o Firestore

**Sintoma:** Erro ao salvar ou carregar tarefas

**Solução:**
- Verifique as regras de segurança do Firestore
- Durante o desenvolvimento, você pode usar regras permissivas:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if true;
      }
    }
  }
  ```

- Para produção, use regras mais restritivas:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /usuarios/{userId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        match /tarefas/{tarefaId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
  }
  ```

### 4.4. Problemas com Notificações

**Sintoma:** Notificações push não são recebidas

**Solução:**
- Verifique se as permissões de notificação foram concedidas no dispositivo
- Para web, verifique se o navegador suporta notificações push
- Verifique a configuração do Firebase Cloud Messaging no console

### 4.5. Problemas de Conexão

**Sintoma:** O aplicativo não consegue se conectar ao Firebase

**Solução:**
- Verifique sua conexão com a internet
- Verifique se os arquivos de configuração estão corretos
- Certifique-se de que as dependências do Firebase estão atualizadas no `pubspec.yaml`

## 5. Testando o Pacote Interno `core_components`

### 5.1. Verificar Componentes Visuais

1. Observe a tela de login que utiliza `CustomTextField` e `CustomButton`
2. Verifique se os componentes são renderizados corretamente
3. Verifique o comportamento dos componentes (validação, estados de carregamento, etc.)

### 5.2. Testar Utilitários

1. Os utilitários `InputValidators` são usados na validação dos formulários
2. O `ResponsiveHelper` adapta a interface para diferentes tamanhos de tela
3. Para testar o `DateFormatter`, observe a formatação de datas nas tarefas

## 6. Monitoramento e Análise

### 6.1. Analytics

1. No Firebase Console, acesse "Analytics"
2. Verifique os eventos registrados (login, registro, criação de tarefas, etc.)
3. Observe métricas como usuários ativos, retenção, etc.

### 6.2. Crashlytics (opcional)

Se você configurou o Firebase Crashlytics, poderá:

1. Acessar "Crashlytics" no Firebase Console
2. Monitorar crashes e erros do aplicativo
3. Verificar relatórios detalhados para solucionar problemas

## 7. Próximos Passos

Após testar com sucesso a integração com Firebase, considere:

1. Implementar recursos adicionais, como compartilhamento de tarefas entre usuários
2. Melhorar a segurança com regras mais específicas no Firestore
3. Adicionar autenticação social (Google, Facebook, etc.)
4. Implementar recursos premium com Firebase In-App Purchases

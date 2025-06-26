import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../routes/app_routes.dart';
import 'package:core_components/core_components.dart';

/// Página de login do aplicativo
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLogin = true; // true para login, false para registro
  bool _isPasswordVisible = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
  
  /// Alterna entre os modos de login e registro
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }
  
  /// Mostra ou esconde a senha
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
  
  /// Submete o formulário
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final firebaseService = FirebaseService();
    
    try {
      if (_isLogin) {
        await authService.login(
          _emailController.text.trim(),
          _senhaController.text.trim(),
        );
        
        // Verificar se o Firebase está inicializado antes de registrar eventos
        if (firebaseService.isInitialized) {
          await firebaseService.logEvent(name: 'login_success');
        }
      } else {
        await authService.registrar(
          _emailController.text.trim(),
          _senhaController.text.trim(),
        );
        
        // Verificar se o Firebase está inicializado antes de registrar eventos
        if (firebaseService.isInitialized) {
          await firebaseService.logEvent(name: 'register_success');
        }
      }
      
      if (mounted && authService.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Ocorreu um erro. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Verificar se o Firebase está inicializado antes de registrar eventos
        if (firebaseService.isInitialized) {
          await firebaseService.logEvent(
            name: _isLogin ? 'login_error' : 'register_error',
            parameters: {'error': e.toString()},
          );
        }
      }
    }
  }
  
  /// Botão de esqueci minha senha
  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () async {
        if (_emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, insira seu email para redefinir a senha.'),
            ),
          );
          return;
        }
        
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.resetarSenha(_emailController.text.trim());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Email de redefinição de senha enviado. Verifique sua caixa de entrada.'
                    : authService.errorMessage ?? 'Erro ao enviar email de redefinição.',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      },
      child: const Text('Esqueci minha senha'),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoading = authService.status == AuthStatus.authenticating;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Registro'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.responsivePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou ícone
                Icon(
                  Icons.task_alt,
                  size: ResponsiveHelper.adaptiveFontSize(context, 64),
                  color: AppColors.primary,
                ),
                const SizedBox(height: 32),
                
                // Título
                Text(
                  _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Campo de email
                CustomTextField.email(
                  controller: _emailController,
                  validator: InputValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Campo de senha
                CustomTextField(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  controller: _senhaController,
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _isPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: _togglePasswordVisibility,
                  validator: InputValidators.validatePassword,
                  required: true,
                ),
                const SizedBox(height: 8),
                
                // Esqueci minha senha (apenas no modo de login)
                if (_isLogin) _buildForgotPasswordButton(),
                const SizedBox(height: 24),
                
                // Botão de submit
                CustomButton.primary(
                  text: _isLogin ? 'Entrar' : 'Registrar',
                  onPressed: isLoading ? null : _submitForm,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),
                
                // Alternar entre login e registro
                TextButton(
                  onPressed: isLoading ? null : _toggleAuthMode,
                  child: Text(
                    _isLogin
                        ? 'Não tem uma conta? Registre-se'
                        : 'Já tem uma conta? Faça login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

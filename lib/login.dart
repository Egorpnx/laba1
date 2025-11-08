import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://frvexfoezbscdbcvuxas.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZydmV4Zm9lemJzY2RiY3Z1eGFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NDY4ODgsImV4cCI6MjA3NTMyMjg4OH0.XDr9MFxBMX0P42a4MwjstxtZeh_Caqdyrfpfr7d9ec8',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Вход и Регистрация',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

// === Экран входа ===
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
        // 🔥 Сохраняем email пользователя в SharedPreferences (если нужно)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', emailController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Добро пожаловать!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      String message = 'Ошибка входа';
      if (e is AuthException) {
        message = e.message;
      } else if (e is Exception) {
        message = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Войти'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen1()),
                );
              },
              child: Text('Нет аккаунта? Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}

// === Экран регистрации - Шаг 1 ===
class RegistrationScreen1 extends StatefulWidget {
  @override
  _RegistrationScreen1State createState() => _RegistrationScreen1State();
}

class _RegistrationScreen1State extends State<RegistrationScreen1> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Заполните все поля')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationScreen2(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    ),
                  ),
                );
              },
              child: Text('Далее'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === Экран регистрации - Шаг 2 ===
class RegistrationScreen2 extends StatefulWidget {
  final String email;
  final String password;

  const RegistrationScreen2({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _RegistrationScreen2State createState() => _RegistrationScreen2State();
}

class _RegistrationScreen2State extends State<RegistrationScreen2> {
  final TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, введите имя')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signUp(
        email: widget.email,
        password: widget.password,
      );

      if (response.user != null) {
        // Обновляем профиль с именем через data (попадает в user_metadata)
        await supabase.auth.updateUser(
          UserAttributes(data: {'full_name': nameController.text.trim()}),
        );

        // 🔥 Сохраняем имя в SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('full_name', nameController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Регистрация завершена!')),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Проверьте email для подтверждения регистрации')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      String message = 'Ошибка регистрации';
      if (e is AuthException) {
        message = e.message;
      } else if (e is Exception) {
        message = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Ваше имя',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeRegistration,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Завершить регистрацию'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === Главный экран ===
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? fullName;

  @override
  void initState() {
    super.initState();
    _loadFullName();
  }

  Future<void> _loadFullName() async {
    final user = Supabase.instance.client.auth.currentUser;
    String? nameFromSupabase = user?.userMetadata?['full_name'];


    if (nameFromSupabase != null) {
      setState(() {
        fullName = nameFromSupabase;
      });
      return;
    }

    
    final prefs = await SharedPreferences.getInstance();
    String? nameFromPrefs = prefs.getString('full_name');

    setState(() {
      fullName = nameFromPrefs ?? 'Гость';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final supabase = Supabase.instance.client;
              await supabase.auth.signOut();

              // 🔥 Очищаем сохранённое имя при выходе
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('full_name');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Добро пожаловать, ${fullName ?? 'Гость'}!', style: TextStyle(fontSize: 20)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final supabase = Supabase.instance.client;
                await supabase.auth.signOut();

                
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('full_name');

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// === Ваши данные Supabase (убедитесь, что нет пробелов!) ===
const String supabaseUrl ='https://frvexfoezbscdbcvuxas.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZydmV4Zm9lemJzY2RiY3Z1eHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NDY4ODgsImV4cCI6MjA3NTMyMjg4OH0.XDr9MFxBMX0P42a4MwjstxtZeh_Caqdyrfpfr7d9ec8';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Messages',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MessagesPage(),
    );
  }
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late Future<List<Map<String, dynamic>>> _futureMessages;

  @override
  void initState() {
    super.initState();
    _futureMessages = _fetchMessages();
  }

  Future<List<Map<String, dynamic>>> _fetchMessages() async {
    try {
      // В новых версиях supabase_flutter:
      // - .select() возвращает List<dynamic> напрямую
      // - При ошибке — выбрасывается исключение
      final data = await Supabase.instance.client
          .from('messages')
          .select();

      // Преобразуем в List<Map<String, dynamic>>
      return (data as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } on PostgrestException catch (error) {
      // Обработка ошибок Supabase
      throw Exception('Supabase error: ${error.message}');
    } catch (e) {
      // Обработка других ошибок (сети и т.д.)
      throw Exception('Network or unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureMessages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка: ${snapshot.error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureMessages = _fetchMessages();
                      });
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return const Center(
              child: Text('Нет сообщений', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final id = msg['id']?.toString() ?? '—';
              final content = msg['content']?.toString() ?? 'Без текста';
              final createdAt = msg['created_at']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(content, style: const TextStyle(fontSize: 16)),
                  subtitle: Text('ID: $id | $createdAt', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
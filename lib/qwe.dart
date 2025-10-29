import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

const String supabaseUrl = 'https://frvexfoezbscdbcvuxas.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZydmV4Zm9lemJzY2RiY3Z1eGFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NDY4ODgsImV4cCI6MjA3NTMyMjg4OH0.XDr9MFxBMX0P42a4MwjstxtZeh_Caqdyrfpfr7d9ec8';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сообщения',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MessageScreen(),
    );
  }
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
  final messageCtrl = TextEditingController();

  // Функция для показа диалога подтверждения
  Future<void> _showConfirmationDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтвердите отправку'),
          content: Text('Вы уверены, что хотите отправить сообщение?\n\n"$message"'),
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
              },
            ),
            ElevatedButton(
              child: const Text('Да'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                _sendMessage(message);       // Отправляем сообщение
              },
            ),
          ],
        );
      },
    );
  }

  // Функция отправки сообщения в Supabase
  void _sendMessage(String message) {
    supabase
        .from('messages')
        .insert({'message': message})
        .then((_) {
          messageCtrl.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Сообщение добавлено')),
          );
          setState(() {}); // Обновляем список
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сообщения')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: messageCtrl,
                  decoration: const InputDecoration(labelText: 'Введите сообщение'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final message = messageCtrl.text.trim();
                    if (message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Введите сообщение')),
                      );
                      return;
                    }
                    _showConfirmationDialog(message);
                  },
                  child: const Text('Отправить'),
                ),
              ],
            ),
          ),
Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _loadMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final msg = snapshot.data![i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(msg['message']),
                          subtitle: Text('Отправлено: ${msg['created_at']}'),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Нет сообщений'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _loadMessages() async {
    final data = await supabase.from('messages').select().order('created_at', ascending: false);
    return data as List<dynamic>;
  }
}
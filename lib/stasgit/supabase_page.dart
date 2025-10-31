import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePage extends StatefulWidget {
  const SupabasePage({super.key});

  @override
  State<SupabasePage> createState() => _SupabasePageState();
}

class _SupabasePageState extends State<SupabasePage> {
  late SupabaseClient supabase;
  List<dynamic> messages = [];
  final TextEditingController messageController = TextEditingController();
  late Future<void> _initFuture;
  bool isConnected = false;
  String statusMessage = "Подключение...";

  // === Получаем ключи и инициализируем Supabase ===
  Future<void> getKeysAndInit() async {
    try {
      final uri = Uri.parse('https://college.panfilius.ru/keys.php');
      final response = await http.patch(uri);

      print('Ответ сервера: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        final supabaseUrl = (data['url'] ?? '').toString();
        final supabaseKey = (data['anonKey'] ?? '').toString();

        if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
          await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
          supabase = Supabase.instance.client;
          setState(() {
            isConnected = true;
            statusMessage = "Подключено через сервер";
          });
          return;
        }
      }

      // === Резервное подключение ===
      await Supabase.initialize(
        url: 'https://frvexfoezbscdbcvuxas.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZydmV4Zm9lemJzY2RiY3Z1eGFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NDY4ODgsImV4cCI6MjA3NTMyMjg4OH0.XDr9MFxBMX0P42a4MwjstxtZeh_Caqdyrfpfr7d9ec8',
      );
      supabase = Supabase.instance.client;
      setState(() {
        isConnected = true;
        statusMessage = "Подключено (резерв)";
      });
    } catch (e) {
      print("Ошибка подключения: $e");
      await Supabase.initialize(
        url: 'https://frvexfoezbscdbcvuxas.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZydmV4Zm9lemJzY2RiY3Z1eGFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NDY4ODgsImV4cCI6MjA3NTMyMjg4OH0.XDr9MFxBMX0P42a4MwjstxtZeh_Caqdyrfpfr7d9ec8',
      );
      supabase = Supabase.instance.client;
      setState(() {
        isConnected = false;
        statusMessage = "Ошибка подключения";
      });
    }
  }

  // === Получаем данные из базы ===
  Future<void> fetchData() async {
    try {
      final response = await supabase.from('messages').select();
      setState(() {
        messages = response;
      });
    } catch (e) {
      print("Ошибка получения данных: $e");
      setState(() {
        statusMessage = "Ошибка загрузки данных";
      });
    }
  }

  // === Отправляем новое сообщение ===
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    try {
      await supabase.from('messages').insert({'message': messageController.text});
      messageController.clear();
      await fetchData();
    } catch (e) {
      print("Ошибка отправки сообщения: $e");
      setState(() {
        statusMessage = "Ошибка при отправке";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initFuture = initializeAll();
  }

  Future<void> initializeAll() async {
    await getKeysAndInit();
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3F5),
      appBar: AppBar(
        title: const Text('Supabase Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: [
              // === Статус подключения ===
              Container(
                color: isConnected ? Colors.green[100] : Colors.red[100],
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Text(
                  statusMessage,
                  style: TextStyle(
                    color: isConnected ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // === Список сообщений ===
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text('Нет сообщений'))
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final row = messages[index];
                          final msg = row['message'] ?? row['text'] ?? row['content'] ?? row.toString();

                          return ListTile(
                            leading: const Icon(Icons.message_outlined),
                            title: Text(msg),
                          );
                        },
                      ),
              ),

              // === Поле ввода и кнопка отправки ===
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'Введите сообщение...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
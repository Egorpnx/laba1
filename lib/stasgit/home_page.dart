import 'package:flutter/material.dart';
import 'supabase_page.dart';
import 'prefs_page.dart';
import 'registration_page.dart'; 

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная страница'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Первый блок ===
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: const Center(
                            child: Text('PHOTO', style: TextStyle(fontSize: 10))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SupabasePage()),
                          );
                        },
                        child: const Text('Перейти к Supabase'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.green[200],
                    margin: const EdgeInsets.only(bottom: 8),
                    child: const Center(child: Text('ТЕКСТ')),
                  ),
                  Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.green[200],
                    child: const Center(child: Text('ТЕКСТ')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // === Второй блок ===
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 80,
                          color: Colors.green[200],
                          margin: const EdgeInsets.only(right: 8),
                          child: const Center(child: Text('ТЕКСТ')),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 80,
                          color: Colors.green[200],
                          child: const Center(child: Text('ТЕКСТ')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    color: Colors.pink[100],
                    child: const Center(child: Text('SCROL')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // === Третий блок ===
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          color: Colors.green[200],
                          margin: const EdgeInsets.only(right: 8),
                          child: const Center(child: Text('ТЕКСТ')),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          color: Colors.green[200],
                          child: const Center(child: Text('ТЕКСТ')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 130, // увеличил высоту, чтобы поместить две кнопки
                    color: Colors.pink[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Действия'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PrefsPage()),
                            );
                          },
                          child: const Text('SharedPreferences'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegistrationPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Форма регистрации'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
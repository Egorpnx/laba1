import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsPage extends StatefulWidget {
  const PrefsPage({super.key});

  @override
  State<PrefsPage> createState() => _PrefsPageState();
}

class _PrefsPageState extends State<PrefsPage> {
  final TextEditingController controller = TextEditingController();
  String savedValue = '';

  Future<void> saveData(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', value);
    debugPrint('Сохранено: $value');
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedValue = prefs.getString('username') ?? 'Нет данных';
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SharedPreferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Введите имя'),
              onChanged: (value) {
                debugPrint('Введено: $value');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await saveData(controller.text);
                await loadData();
              },
              child: const Text('Сохранить'),
            ),
            const SizedBox(height: 16),
            Text('Сохранено: $savedValue'),
          ],
        ),
      ),
    );
  }
}
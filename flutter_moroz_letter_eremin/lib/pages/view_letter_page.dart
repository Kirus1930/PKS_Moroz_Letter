import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_moroz_letter_eremin/models/letter.dart';
import 'package:flutter_moroz_letter_eremin/repositories/letter_repository.dart';
import 'package:flutter_moroz_letter_eremin/services/response_generator.dart';
import 'package:intl/intl.dart';

class ViewLetterPage extends StatefulWidget {
  final LetterRepository repository;

  const ViewLetterPage({super.key, required this.repository});

  @override
  State<ViewLetterPage> createState() => _ViewLetterPageState();
}

class _ViewLetterPageState extends State<ViewLetterPage> {
  late Future<List<Letter>> _futureLetters;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  void _loadLetters() {
    setState(() {
      _futureLetters = widget.repository.getAllLetters();
    });
  }

  Future<void> _generateResponse(Letter letter) async {
    if (!letter.hasResponse) {
      final responseText = ResponseGenerator.generateResponse(letter);
      final updatedLetter = letter.copyWith(
        hasResponse: true,
        responseText: responseText,
        responseDate: DateTime.now(),
      );
      await widget.repository.updateLetter(updatedLetter);
      _loadLetters();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ответ от Деда Мороза сгенерирован!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteLetter(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить письмо?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.repository.deleteLetter(id);
      _loadLetters();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Письмо удалено'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLetterDetails(Letter letter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Письмо от ${letter.childName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Возраст: ${letter.age}'),
              Text('Отправлено: ${_dateFormat.format(letter.createdAt)}'),
              const SizedBox(height: 20),
              const Text(
                'Рассказ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(letter.story),
              const SizedBox(height: 20),
              const Text(
                'Желания:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...letter.wishes.map((wish) => Text('• $wish')).toList(),
              if (letter.drawingPath != null &&
                  File(letter.drawingPath!).existsSync()) ...[
                const SizedBox(height: 20),
                const Text(
                  'Рисунок:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.file(
                  File(letter.drawingPath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 20),
              if (letter.hasResponse && letter.responseText != null) ...[
                const Text(
                  'Ответ Деда Мороза:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(letter.responseText!),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ответ отправлен: ${_dateFormat.format(letter.responseDate!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!letter.hasResponse)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.mail),
                      label: const Text('Получить ответ'),
                      onPressed: () => _generateResponse(letter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Удалить'),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteLetter(letter.id!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои письма'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Letter>>(
        future: _futureLetters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          }

          final letters = snapshot.data!;

          if (letters.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Вы еще не написали ни одного письма Деду Морозу.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Нажмите кнопку "+" на главной странице, чтобы создать письмо.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final letter = letters[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      letter.childName.isNotEmpty
                          ? letter.childName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  title: Text(
                    letter.childName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Возраст: ${letter.age}'),
                      const SizedBox(height: 2),
                      Text(
                        'Отправлено: ${_dateFormat.format(letter.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (letter.hasResponse)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 12, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Ответ получен',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteLetter(letter.id!),
                  ),
                  onTap: () => _showLetterDetails(letter),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

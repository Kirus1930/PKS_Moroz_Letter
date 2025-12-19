import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_moroz_letter_eremin/models/letter.dart';
import 'package:flutter_moroz_letter_eremin/repositories/letter_repository.dart';
import 'package:flutter_moroz_letter_eremin/services/response_generator.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

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
        SnackBar(
          content: Text(
            'Ответ от Деда Мороза сгенерирован!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  Future<void> _deleteLetter(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Удалить письмо?',
          style: TextStyle(color: AppTheme.blueText),
        ),
        content: Text(
          'Это действие нельзя отменить.',
          style: TextStyle(color: AppTheme.lightRedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppTheme.lightRedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Удалить',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.repository.deleteLetter(id);
      _loadLetters();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Письмо удалено',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLetterDetails(Letter letter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightBlueBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.blueText,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.lightRedText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Возраст: ${letter.age}',
                  style: TextStyle(fontSize: 16, color: AppTheme.lightRedText),
                ),
                Text(
                  'Отправлено: ${_dateFormat.format(letter.createdAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.lightRedText.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Рассказ:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.blueText,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightRedText.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    letter.story,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.lightRedText,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Желания:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.blueText,
                  ),
                ),
                const SizedBox(height: 8),
                ...letter.wishes
                    .map(
                      (wish) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightRedText.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '• $wish',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.lightRedText,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                if (letter.drawingPath != null &&
                    File(letter.drawingPath!).existsSync()) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Рисунок:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blueText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightRedText.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(letter.drawingPath!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (letter.hasResponse && letter.responseText != null) ...[
                  Text(
                    'Ответ Деда Мороза:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blueText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      letter.responseText!,
                      style: TextStyle(fontSize: 15, color: Colors.blue[900]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ответ отправлен: ${_dateFormat.format(letter.responseDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightRedText.withOpacity(0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!letter.hasResponse)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.mail, size: 20),
                        label: const Text('Получить ответ'),
                        onPressed: () => _generateResponse(letter),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          backgroundColor: AppTheme.accentColor,
                        ),
                      ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text('Удалить'),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteLetter(letter.id!);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightBlueBackground, Colors.lightBlue[100]!],
          ),
        ),
        child: FutureBuilder<List<Letter>>(
          future: _futureLetters,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Ошибка загрузки: ${snapshot.error}',
                  style: TextStyle(color: AppTheme.lightRedText),
                ),
              );
            }

            final letters = snapshot.data!;

            if (letters.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 100,
                        color: AppTheme.lightRedText.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Вы еще не написали ни одного письма Деду Морозу.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.lightRedText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Нажмите кнопку "+" на главной странице, чтобы создать письмо.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightRedText.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: letters.length,
              itemBuilder: (context, index) {
                final letter = letters[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        radius: 28,
                        child: Text(
                          letter.childName.isNotEmpty
                              ? letter.childName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppTheme.blueText,
                          ),
                        ),
                      ),
                      title: Text(
                        letter.childName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.lightRedText,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Возраст: ${letter.age}',
                            style: TextStyle(
                              color: AppTheme.lightRedText.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Отправлено: ${_dateFormat.format(letter.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.lightRedText.withOpacity(0.7),
                            ),
                          ),
                          if (letter.hasResponse)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ответ получен',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppTheme.lightRedText,
                        ),
                        onPressed: () => _deleteLetter(letter.id!),
                      ),
                      onTap: () => _showLetterDetails(letter),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/qa_model.dart';
import '../../services/database_service.dart';

class QAAdminScreen extends StatefulWidget {
  const QAAdminScreen({Key? key}) : super(key: key);

  @override
  _QAAdminScreenState createState() => _QAAdminScreenState();
}

class _QAAdminScreenState extends State<QAAdminScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _keywordsController = TextEditingController();
  List<QAModel> _qaList = [];

  @override
  void initState() {
    super.initState();
    _loadQA();
  }

  Future<void> _loadQA() async {
    final qaList = await _databaseService.getAllQA();
    setState(() {
      _qaList = qaList;
    });
  }

  Future<void> _addQA() async {
    if (_formKey.currentState!.validate()) {
      final keywords = _keywordsController.text.split(',').map((e) => e.trim()).toList();
      final qa = QAModel(
        question: _questionController.text,
        answer: _answerController.text,
        keywords: keywords,
      );

      await _databaseService.insertQA(qa);
      _clearForm();
      _loadQA();
    }
  }

  Future<void> _deleteQA(int id) async {
    await _databaseService.deleteQA(id);
    await _loadQA();
  }

  void _clearForm() {
    _questionController.clear();
    _answerController.clear();
    _keywordsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration Q/R'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une question';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      labelText: 'Réponse',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une réponse';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _keywordsController,
                    decoration: const InputDecoration(
                      labelText: 'Mots-clés (séparés par des virgules)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer au moins un mot-clé';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addQA,
                    child: const Text('Ajouter Q/R'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Questions/Réponses existantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _qaList.length,
                itemBuilder: (context, index) {
                  final qa = _qaList[index];
                  return Card(
                    child: ListTile(
                      title: Text(qa.question),
                      subtitle: Text(qa.answer),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteQA(qa.id!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }
} 
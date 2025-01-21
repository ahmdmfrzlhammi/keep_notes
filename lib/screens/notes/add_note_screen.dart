import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_notes/services/firestore_service.dart';
import 'package:keep_notes/widgets/text_editor.dart';

class CreateNoteScreen extends StatefulWidget {
  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> _selectedTags = [];
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  void _loadTags() {
    _firestoreService.getAllTags().listen((tags) {
      setState(() {
        _availableTags = tags;
      });
    });
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _selectedTags.add(_tagController.text);
        if (!_availableTags.contains(_tagController.text)) {
          _availableTags.add(_tagController.text);
        }
        _tagController.clear();
      });
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }
    await _firestoreService.createNote(
      title: _titleController.text,
      content: _contentController.text,
      imageUrl: '',
      tags: _selectedTags,
    );
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Note", style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                hintText: 'Select or create tag',
                                border: InputBorder.none,
                              ),
                              value: null,
                              items: _availableTags.map((tag) {
                                return DropdownMenuItem(
                                  value: tag,
                                  child: Text(tag),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null && !_selectedTags.contains(value)) {
                                  setState(() {
                                    _selectedTags.add(value);
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:   Text('Add New Tag'),
                                  content: TextField(
                                    controller: _tagController,
                                    decoration:  InputDecoration(hintText: 'Enter tag name'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _addTag();
                                        Navigator.pop(context);
                                      },
                                      child: Text('Add'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: _selectedTags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setState(() {
                                _selectedTags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomTextEditor(
                      controller: _contentController,
                      hintText: 'Start writing your note...',
                      expands: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveNote,
        label: Text("Save Note", style: TextStyle(fontWeight: FontWeight.w600)),
        icon: Icon(Icons.save),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
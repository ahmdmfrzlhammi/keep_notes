import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_notes/services/firestore_service.dart';
import 'package:keep_notes/widgets/text_editor.dart';

class EditNoteScreen extends StatefulWidget {
  final String noteId;

  EditNoteScreen({required this.noteId});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> _selectedTags = [];
  List<String> _availableTags = [];
  DateTime? createdAt;
  DateTime? updatedAt;

  @override
  void initState() {
    super.initState();
    _loadTags();
    _fetchNoteData();
  }

  void _loadTags() {
    _firestoreService.getAllTags().listen((tags) {
      setState(() {
        _availableTags = tags;
      });
    });
  }

  void _fetchNoteData() async {
    try {
      DocumentSnapshot note = await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.noteId)
          .get();

      if (note.exists) {
        final data = note.data() as Map<String, dynamic>;
        setState(() {
          _titleController.text = data['title'] ?? '';
          _contentController.text = data['content'] ?? '';
          _selectedTags = List<String>.from(data['tags'] ?? []);
          createdAt = (data['timestamp'] as Timestamp?)?.toDate();
          updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load note: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.noteId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note deleted successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete note: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      }
    }
  }

  Future<void> _archiveNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archive Note'),
        content: Text('This note will be moved to archive. Do you want to continue?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Archive', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.archiveNote(noteId: widget.noteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note archived successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          context.go('/archives');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to archive note: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      }
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

    try {
      await _firestoreService.updateNote(
        noteId: widget.noteId,
        title: _titleController.text,
        content: _contentController.text,
        tags: _selectedTags,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note saved successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text("Edit Note", style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.archive_outlined, color: Colors.grey[600]),
            onPressed: _archiveNote,
            tooltip: 'Archive Note',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteNote,
            tooltip: 'Delete Note',
          ),
        ],
        
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (createdAt != null || updatedAt != null)
                Card(
                  elevation: 1,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Created: ${_formatDate(createdAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.edit_calendar, size: 14, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Last modified: ${_formatDate(updatedAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
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
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
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
                              decoration: InputDecoration(
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
                                  title: Text('Add New Tag'),
                                  content: TextField(
                                    controller: _tagController,
                                    decoration: InputDecoration(hintText: 'Enter tag name'),
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
        label: Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
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
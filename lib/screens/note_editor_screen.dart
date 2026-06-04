import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final String _noteId;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Timer? _debounceTimer;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _noteId = widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _charCount = _contentController.text.length;

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveNoteLocally(); // Final save on dispose
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _charCount = _contentController.text.length;
    });

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveNoteLocally();
    });
  }

  Future<void> _saveNoteLocally() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // If both fields are empty, we remove the note from storage to prevent saving blank notes
    if (title.isEmpty && content.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final notesString = prefs.getString('saved_notes');
      if (notesString != null) {
        try {
          final List<dynamic> decoded = jsonDecode(notesString) as List<dynamic>;
          final list = decoded.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
          list.removeWhere((n) => n.id == _noteId);
          await prefs.setString('saved_notes', jsonEncode(list.map((n) => n.toJson()).toList()));
        } catch (e) {
          debugPrint('Error removing empty note: $e');
        }
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('saved_notes');
    List<Note> list = [];
    if (notesString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(notesString) as List<dynamic>;
        list = decoded.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error loading notes for auto-save: $e');
      }
    }

    final index = list.indexWhere((n) => n.id == _noteId);
    final noteTitle = title.isEmpty ? 'Untitled' : title;
    final updatedNote = Note(
      id: _noteId,
      title: noteTitle,
      content: content,
      timestamp: DateTime.now(),
    );

    if (index >= 0) {
      list[index] = updatedNote;
    } else {
      list.insert(0, updatedNote);
    }

    await prefs.setString('saved_notes', jsonEncode(list.map((n) => n.toJson()).toList()));
  }

  void _save() {
    _debounceTimer?.cancel();
    _saveNoteLocally().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$month $day, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Create Note' : 'Edit Note',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: _save,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(widget.note?.timestamp ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                Text(
                  '$_charCount characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

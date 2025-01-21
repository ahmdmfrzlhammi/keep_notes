// lib/widgets/custom_text_editor.dart
import 'package:flutter/material.dart';

class TextStyleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const TextStyleButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
      ),
      onPressed: onPressed,
    );
  }
}

class CustomTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int? minLines;
  final bool expands;
  final double fontSize;

  const CustomTextEditor({
    required this.controller,
    required this.hintText,
    this.minLines,
    this.expands = false,
    this.fontSize = 16,
  });

  @override
  _CustomTextEditorState createState() => _CustomTextEditorState();
}

class _CustomTextEditorState extends State<CustomTextEditor> {
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  TextAlign textAlignment = TextAlign.left;

  TextStyle get _textStyle => TextStyle(
        fontSize: widget.fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
        height: 1.5,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              TextStyleButton(
                icon: Icons.format_bold,
                isActive: isBold,
                onPressed: () => setState(() => isBold = !isBold),
              ),
              TextStyleButton(
                icon: Icons.format_italic,
                isActive: isItalic,
                onPressed: () => setState(() => isItalic = !isItalic),
              ),
              TextStyleButton(
                icon: Icons.format_underline,
                isActive: isUnderline,
                onPressed: () => setState(() => isUnderline = !isUnderline),
              ),
              VerticalDivider(width: 16),
              TextStyleButton(
                icon: Icons.format_align_left,
                isActive: textAlignment == TextAlign.left,
                onPressed: () => setState(() => textAlignment = TextAlign.left),
              ),
              TextStyleButton(
                icon: Icons.format_align_center,
                isActive: textAlignment == TextAlign.center,
                onPressed: () => setState(() => textAlignment = TextAlign.center),
              ),
              TextStyleButton(
                icon: Icons.format_align_right,
                isActive: textAlignment == TextAlign.right,
                onPressed: () => setState(() => textAlignment = TextAlign.right),
              ),
            ],
          ),
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            maxLines: null,
            minLines: widget.minLines,
            expands: widget.expands,
            textAlign: textAlignment,
            style: _textStyle,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
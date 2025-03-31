import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../service/pdf_service.dart';

class DownloadConfirmationDialog extends StatelessWidget {
  final String filePath;

  const DownloadConfirmationDialog({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download Complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('The invoice has been saved to:'),
          const SizedBox(height: 8),
          SelectableText(
            filePath,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
      actions: [
        _DialogActionButton(
          icon: Icons.open_in_new,
          label: 'Open',
          onPressed: () => OpenFile.open(filePath),
        ),
        _DialogActionButton(
          icon: Icons.folder_open,
          label: 'Show in Folder',
          onPressed: () => PdfService.openFileExplorer(filePath),
        ),
        // _DialogActionButton(
        //   icon: Icons.share,
        //   label: 'Share',
        //   onPressed: () => _shareFile(context, filePath),
        // ),
      ],
    );
  }

  Future<void> _shareFile(BuildContext context, String path) async {
    try {
      await Share.shareXFiles([XFile(path)]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sharing failed: ${e.toString()}')),
      );
    }
  }
}

class _DialogActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _DialogActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: () {
        Navigator.pop(context);
        onPressed();
      },
    );
  }
}
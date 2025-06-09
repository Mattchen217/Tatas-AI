```dart
import 'package:flutter/material.dart'; // For IconData

class ClientDataItem {
  final String id;
  final String name;
  final String type; // User-friendly type, e.g., "PDF Document", "JPEG Image"
  final DateTime uploadDate;
  final double? fileSizeMB;
  final IconData icon; // Derived client-side based on type or MIME type

  ClientDataItem({
    required this.id,
    required this.name,
    required this.type,
    required this.uploadDate,
    this.fileSizeMB,
    required this.icon,
  });

  // Example factory from a more complex PDS DataObject map (conceptual)
  factory ClientDataItem.fromPdsMap(Map<String, dynamic> pdsMap) {
    String rawFileType = pdsMap['fileType'] ?? pdsMap['mimeType'] ?? 'unknown';
    String displayType = 'File';
    IconData displayIcon = Icons.insert_drive_file_outlined;

    // Simple type to display name and icon mapping
    if (rawFileType.toLowerCase().contains('pdf')) {
      displayType = 'PDF Document';
      displayIcon = Icons.picture_as_pdf_outlined;
    } else if (rawFileType.toLowerCase().contains('doc') || rawFileType.toLowerCase().contains('word')) {
      displayType = 'Word Document';
      displayIcon = Icons.article_outlined;
    } else if (rawFileType.toLowerCase().startsWith('image/')) {
      displayType = 'Image';
      displayIcon = Icons.image_outlined;
    } else if (rawFileType.toLowerCase().startsWith('text/')) {
      displayType = 'Text Document';
      displayIcon = Icons.description_outlined;
    } else if (rawFileType.toLowerCase().contains('zip') || rawFileType.toLowerCase().contains('archive')) {
      displayType = 'Archive File';
      displayIcon = Icons.archive_outlined;
    }


    return ClientDataItem(
      id: pdsMap['dataId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: pdsMap['fileName'] ?? 'Unnamed File',
      type: displayType,
      // Assuming date is stored as ISO string or Firestore Timestamp
      uploadDate: pdsMap['createdAt'] != null ? (pmsMap['createdAt'] as dynamic)?.toDate() ?? DateTime.parse(pdsMap['createdAt']) : DateTime.now(),
      fileSizeMB: pdsMap['sizeInBytes'] != null ? (pdsMap['sizeInBytes'] / (1024 * 1024)) : null,
      icon: displayIcon,
    );
  }
}
```

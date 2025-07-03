// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/photocard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PhotocardAdapter());
  await Hive.openBox<Photocard>('photocards');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photocard App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PhotocardHomePage(),
    );
  }
}

Future<String> calculateImageHash(File file) async {
  final bytes = await file.readAsBytes();
  final digest = md5.convert(bytes);
  return digest.toString();
}

class PhotocardHomePage extends StatelessWidget {
  final Box<Photocard> cardBox = Hive.box<Photocard>('photocards');

  PhotocardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Photocard Library')),
      body: ValueListenableBuilder(
        valueListenable: cardBox.listenable(),
        builder: (context, Box<Photocard> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text('No cards yet.'));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final card = box.getAt(index);
              return Card(
                child: Column(
                  children: [
                    if (card?.imagePath != null && card!.imagePath.isNotEmpty)
                      Image.file(
                        File(card.imagePath),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    Text(
                      card?.title ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(card?.number ?? ''),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPhotocardPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddPhotocardPage extends StatefulWidget {
  const AddPhotocardPage({super.key});

  @override
  _AddPhotocardPageState createState() => _AddPhotocardPageState();
}

class _AddPhotocardPageState extends State<AddPhotocardPage> {
  File? _imageFile;
  final picker = ImagePicker();
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveCard() async {
    if (_imageFile == null ||
        _titleController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide all info and a photo.')),
      );
      return;
    }

    String newImageHash = await calculateImageHash(_imageFile!);

    if(!mounted) return;
    final cardBox = Hive.box<Photocard>('photocards');
    bool isDuplicate = false;

    for (var card in cardBox.values) {
      String existingHash = await calculateImageHash(File(card.imagePath));
      if (!mounted) return;
      if (existingHash == newImageHash) {
        isDuplicate = true;
        break;
      }
    }

    if (isDuplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('呢張相已經儲存咗喺你個library入面！')),
      );
      return;
    }

    final card = Photocard(
      imagePath: _imageFile!.path,
      title: _titleController.text.trim(),
      number: _numberController.text.trim(),
    );
    cardBox.add(card);
    if (!mounted) return;
    Navigator.pop(context); // go back to main page
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Photocard')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(Icons.photo, size: 100, color: Colors.grey),
                  ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Card Title / Member'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _numberController,
              decoration: InputDecoration(labelText: 'Card Number / Set'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveCard,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Save Card'),
            ),
          ],
        ),
      ),
    );
  }
}

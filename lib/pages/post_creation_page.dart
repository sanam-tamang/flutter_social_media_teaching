import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCreationPage extends StatefulWidget {
  const PostCreationPage({super.key});

  @override
  State<PostCreationPage> createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final TextEditingController _contentController = TextEditingController();
  // File? imageFile;
  Uint8List? _imageBytes;

  bool isLoading = false;
  @override
  void dispose() {
    super.dispose();

    _contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FilledButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              try {
                final client = Supabase.instance.client;
                String? imageUrl;
                if (_imageBytes != null) {
                  String fileName = DateTime.now().toString();
                  imageUrl = await client.storage
                      .from("images")
                      .uploadBinary(fileName, _imageBytes!);
                }

                await client.from('posts').insert({
                  "content": _contentController.text,
                  "imageUrl": imageUrl,
                  "userId": Supabase.instance.client.auth.currentUser!.id,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Post added successful")),
                );

                Navigator.of(context).pop();
              } on PostgrestException catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            },
            child:
                isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Post"),
          ),

          SizedBox(width: 12),
        ],
      ),

      bottomSheet: Row(
        children: [
          IconButton(
            onPressed: () async {
              ImagePicker imagePicker = ImagePicker();
              try {
                final xfile = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                );

                if (xfile != null) {
                  _imageBytes = await xfile.readAsBytes();
                }
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: picking image ${e.toString()}"),
                  ),
                );
              }
            },
            icon: Icon(Icons.image),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: null,
              // minLines: 4,
              decoration: InputDecoration(
                hintText: "Content",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),

                border: InputBorder.none,
              ),
            ),

            SizedBox(
              height: 200,
              width: double.maxFinite,
              child:
                  _imageBytes != null ? Image.memory(_imageBytes!) : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

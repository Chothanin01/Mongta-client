import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

Future<void> sendMessage({
  required String message,
  required String senderId,
  required String conversationId,
  File? imageFile,
}) async {
  var uri = Uri.parse('http://localhost:5000/api/sendchat');
  var request = http.MultipartRequest('POST', uri);

  request.fields['sender_id'] = senderId;
  request.fields['conversation_id'] = conversationId;

  if (imageFile != null) {
    var file = await http.MultipartFile.fromPath('file', imageFile.path);
    request.files.add(file);
  } else {
    request.fields['message'] = message;
  }

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      print('ส่งข้อมูลสำเร็จ');
    } else {
      print('เกิดข้อผิดพลาดในการส่ง: ${response.statusCode}');
    }
  } catch (e) {
    print('ข้อผิดพลาด: $e');
  }
}

Future<File?> pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    return File(pickedFile.path);
  }
  return null;
}

class ChatInput extends StatefulWidget {
  final Map<String, dynamic> chatSession;

  ChatInput({required this.chatSession});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController _controller = TextEditingController();
  File? _imageFile;

  void _sendMessage() async {
    String message = _controller.text.trim();
    String senderId = widget.chatSession["user_id"].toString();
    String conversationId = widget.chatSession["conversationId"].toString();

    if (message.isNotEmpty || _imageFile != null) {
      await sendMessage(
        message: message,
        senderId: senderId,
        conversationId: conversationId,
        imageFile: _imageFile,
      );
      _controller.clear();
      setState(() {
        _imageFile = null;
      });
    }
  }

  void _pickImage() async {
    File? image = await pickImage();
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
      _sendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        height: 62,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF12358F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.image, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'ข้อความ.....',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF12358F),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; 
import 'dart:io'; 

class ChatInput extends StatefulWidget {
  final VoidCallback onMessageSent;

  const ChatInput({super.key, required this.onMessageSent});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  bool _isButtonEnabled = false; // On-Off send button
  bool _showEmoji = false; // Emoji keyboard
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkInput);
  }

  // Check text or file
  void _checkInput() {
    String message = _textController.text.trim();
    setState(() {

      // ปุ่ม send จะเปิดใช้งาน (สีเขียว) ถ้ามีข้อความหรือไฟล์
      _isButtonEnabled = (message.isNotEmpty || _selectedImage != null) && !(message.isNotEmpty && _selectedImage != null);
    });
  }

  // ฟังก์ชัน toggle แป้นพิมพ์ emoji
  void _toggleEmojiKeyboard() {
    FocusScope.of(context).unfocus(); // ซ่อนแป้นพิมพ์หลัก
    setState(() {
      _showEmoji = !_showEmoji; // เปลี่ยนสถานะแสดง emoji
    });
  }

  // Post API
  Future<void> _sendMessage() async {
    String message = _textController.text.trim();

    if (_isButtonEnabled) {
      // Form Data
      Map<String, dynamic> data = {
        "conversation_id": 186265273, // รอแก้
        "sender_id": 1960006314, // รอแก้
        "message": message.isNotEmpty ? message : null,
      };

      // ถ้ามีการเลือกไฟล์ (ภาพ) จะส่งไฟล์ไปพร้อมกับข้อความ
      if (_selectedImage != null) {
        final request = http.MultipartRequest(
          'POST', Uri.parse('http://localhost:5000/api/sendchat'),
        );
        request.fields['conversation_id'] = '186265273'; // รอแก้
        request.fields['sender_id'] = '1960006314'; // รอแก้
        request.files.add(await http.MultipartFile.fromPath(
          'file', _selectedImage!.path, contentType: MediaType('image', 'jpeg')
        ));

        // ส่ง request ไปที่ API
        print('ส่งพร้อมรูปภาพ:');
        print('Fields: ${request.fields}');
        print('Files: ${_selectedImage!.path}');

        try {
          final response = await request.send();
          if (response.statusCode == 201) {
            print('Message and image sent successfully');
          } else {
            print('Failed to send message and image');
          }
        } catch (e) {
          print('Error sending message: $e');
        }
      } else {

        // ถ้าไม่มีไฟล์ ส่งแค่ข้อความ

        print('ส่งข้อความอย่างเดียว:');
        print('Body: ${json.encode(data)}');

        try {
          final response = await http.post(
            Uri.parse('http://localhost:5000/api/sendchat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          );

          if (response.statusCode == 201) {
            print('Message sent successfully');

            widget.onMessageSent();

            _textController.clear();
            setState(() {
              _selectedImage = null;
            _checkInput();
            });
                                                                                                                                                  
          } else {
            print('Failed to send message');
          }
        } catch (e) {
          print('Error sending message: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * .01,
        horizontal: MediaQuery.of(context).size.width * .025),
    child: Row(
      children: [
        // Input text and button
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
            // Emoji Button
            IconButton(
              onPressed: _toggleEmojiKeyboard, // เปิด/ปิด แป้นพิมพ์ Emoji
              icon: const Icon(Icons.emoji_emotions,
              color: Colors.blueAccent, size: 26)),

            // TextField
            Expanded(
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onTap: () {
                  if (_showEmoji) setState(() => _showEmoji = !_showEmoji); // ซ่อน emoji เมื่อคลิกที่ TextField
                },
                decoration: InputDecoration(
                  hintText: 'พิมพ์ข้อความ...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),

            // Image Picker (Gallery)
            IconButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                if (images.isNotEmpty) {
                  setState(() {
                    _selectedImage = images.first; // เก็บไฟล์รูปที่เลือก
                  });
                }
              },
              icon: const Icon(Icons.image,
              color: Colors.blueAccent, size: 26)),

            // Camera Button (Take Photo)
            IconButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _selectedImage = image; // เก็บไฟล์รูปที่ถ่าย
                  });
                }
              },
              icon: const Icon(Icons.camera_alt_rounded,
              color: Colors.blueAccent, size: 26)),
            ],
          ),
          ),
        ),

        // Send Button
        MaterialButton(
          onPressed: _isButtonEnabled
              ? _sendMessage
              : null, // ถ้าข้อมูลไม่ถูกต้อง จะไม่สามารถกดปุ่มได้
          minWidth: 0,
          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
          shape: const CircleBorder(),
          color: _isButtonEnabled ? Colors.green : Colors.grey, // ปรับสีของปุ่ม
          child: Icon(Icons.send, color: Colors.white, size: 28),
        )
      ],
    ),
    );
  }
}
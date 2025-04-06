import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/services/chat_service.dart';
import 'dart:io';

class ChatInput extends StatefulWidget {
  final VoidCallback onMessageSent;
  final int conversationId; 

  const ChatInput({
    super.key, 
    required this.onMessageSent,
    required this.conversationId, 
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _showEmoji = false; 
  XFile? _selectedImage;
  final _chatService = ChatService(); 

  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkInput);
  }

  // Check text or file
  void _checkInput() {
    String message = _textController.text.trim();
    setState(() {
      // Button is enabled if there's text XOR image (not both at the same time)
      _isButtonEnabled = message.isNotEmpty || _selectedImage != null;
    });
  }

  // Ensure the image picker returns valid image files
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _checkInput(); // Re-evaluate button state
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
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
      try {
        if (_selectedImage != null) {
          await _chatService.sendImageMessage(
            widget.conversationId, 
            _selectedImage!
          );
        } else if (message.isNotEmpty) {
          await _chatService.sendTextMessage(
            widget.conversationId, 
            message
          );
        }
        
        // Clear input and notify parent
        widget.onMessageSent();
        _textController.clear();
        setState(() {
          _selectedImage = null;
          _checkInput();
        });
        
      } catch (e) {
        print('Error sending message: $e');
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
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

            // Show selected image preview if there is one
            if (_selectedImage != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImage!.path),
                        width: 40,
                        height: 40, 
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.cancel, color: Colors.grey[700]),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _checkInput();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Image Picker (Gallery)
            IconButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image,
              color: Colors.blueAccent, size: 26)),

            // Camera Button (Take Photo)
            IconButton(
              onPressed: () => _pickImage(ImageSource.camera),
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
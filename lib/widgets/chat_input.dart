import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import 'package:client/core/theme/theme.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/main.dart'; // Import to access global lifecycleObserver

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
  final ChatService _chatService = ChatService();
  bool _isButtonEnabled = false;
  bool _showEmoji = false;
  XFile? _selectedImage;
  bool _isSending = false;
  
  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkInput);
  }

  void _checkInput() {
    String message = _textController.text.trim();
    setState(() {
      // Enable button if there's text OR image, but not both
      _isButtonEnabled = message.isNotEmpty || _selectedImage != null;
    });
  }

  void _toggleEmojiKeyboard() {
    FocusScope.of(context).unfocus();
    setState(() {
      _showEmoji = !_showEmoji;
    });
  }

  Future<void> _sendMessage() async {
    if (!_isButtonEnabled || _isSending) return;

    setState(() => _isSending = true);
    String message = _textController.text.trim();

    try {
      // If image is selected, prioritize sending the image first
      if (_selectedImage != null) {
        // Send only the image, keeping text in the input field
        await _chatService.sendImageMessage(widget.conversationId, _selectedImage!);
        
        // Clear only the image selection, keep text in place
        setState(() {
          _selectedImage = null;
          _isSending = false;
        });
        
        // Notify parent to refresh messages
        widget.onMessageSent();
      } 
      // If no image but we have text, send the text
      else if (message.isNotEmpty) {
        await _chatService.sendTextMessage(widget.conversationId, message);
        
        // Clear the text field
        _textController.clear();
        setState(() {
          _isSending = false;
        });
        
        // Notify parent to refresh messages
        widget.onMessageSent();
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งข้อความไม่สำเร็จ กรุณาลองอีกครั้ง')),
      );
      setState(() => _isSending = false);
    }
  }

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
          _checkInput();
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Make sure to reset the flag even on error
    }
  }

  IconButton _buildImagePickerButton() {
    return IconButton(
      onPressed: () => _pickImage(ImageSource.gallery),
      icon: const Icon(Icons.image, color: MainTheme.chatBlue, size: 26),
    );
  }

  IconButton _buildCameraButton() {
    return IconButton(
      onPressed: () => _pickImage(ImageSource.camera),
      icon: const Icon(Icons.camera_alt_rounded, color: MainTheme.chatBlue, size: 26),
    );
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
            color: MainTheme.chatInfo,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              // Emoji Button
              IconButton(
                onPressed: _toggleEmojiKeyboard,
                icon: const Icon(Icons.emoji_emotions, color: MainTheme.chatBlue, size: 26),
              ),

              // TextField
              Expanded(
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onTap: () {
                    if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                  },
                  decoration: InputDecoration(
                    hintText: 'พิมพ์ข้อความ...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'BaiJamjuree',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Selected image preview
              if (_selectedImage != null)
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImage!.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedImage = null;
                          _checkInput();
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

              if (_selectedImage != null && _textController.text.isNotEmpty) 
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    'กดส่งเพื่อส่งรูปภาพ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontFamily: 'BaiJamjuree',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // Image Picker
              _buildImagePickerButton(),

              // Camera Button
              _buildCameraButton(),

              // Send Button with fixed size
              SizedBox(
                width: 40,
                height: 40,
                child: MaterialButton(
                  onPressed: _isButtonEnabled && !_isSending ? _sendMessage : null,
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  child: _isSending 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(MainTheme.chatBlue),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _isButtonEnabled ? MainTheme.chatBlue : MainTheme.chatGrey,
                        size: 20),
                ),
              ),
            ],
          ),
            ),
        ),
      ]
    ),
    );
  }
}
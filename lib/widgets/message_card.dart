import 'dart:async';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/socket_service.dart';

class MessageCard extends StatefulWidget {
  final int conversationId;
  
  const MessageCard({
    super.key, 
    required this.conversationId,
  });

  @override
  State<MessageCard> createState() => MessageCardState();
}

class MessageCardState extends State<MessageCard> {
  List<dynamic> _chatLog = [];
  String _userId = '';
  bool _isLoading = true;
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _setupMessageListener();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupMessageListener() {
    _messageSubscription = SocketService.onNewMessage.listen((data) {
      if (data['conversation_id'].toString() == widget.conversationId.toString()) {
        // A new message for this conversation - refresh the messages
        fetchChatData();
      }
    });
  }

  void _scrollToBottom() {
    // Use a short delay to ensure the list has been built
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _getCurrentUserId() async {
    final userId = await UserService.getCurrentUserId();
    setState(() {
      _userId = userId;
    });
    
    // Join the conversation room after getting user ID
    SocketService.joinRoom(widget.conversationId.toString(), userId);
    
    // Then fetch chat data
    fetchChatData();
  }

  Future<void> fetchChatData() async {
    if (_userId.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final chatData = await _chatService.getChatMessages(widget.conversationId);
      setState(() {
        _chatLog = chatData['chatlog'] ?? [];
        _isLoading = false;
      });
      
      // Scroll to the bottom when data is loaded
      _scrollToBottom();
    } catch (e) {
      print('Error fetching chat data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void refreshMessages() {
    fetchChatData();
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final thaiYear = date.year + 543;
      const thaiMonths = [
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
        'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
      ];
      final day = date.day;
      final month = thaiMonths[date.month - 1];
      return 'วันที่ $day $month พ.ศ. $thaiYear';
    }
    catch (e) {
      return 'รูปแบบวันที่ไม่ถูกต้อง';
    }
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  // Helper method to detect if a message is an image URL
  bool isImageUrl(String message) {
    return message.startsWith('https://') && 
           (message.contains('firebasestorage.googleapis.com') || 
            message.contains('.jpg') || 
            message.contains('.jpeg') || 
            message.contains('.png') || 
            message.contains('.gif'));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chatLog.isEmpty) {
      return Center(
        child: Text(
          'ยังไม่มีข้อความในการสนทนานี้',
          style: TextStyle(
            fontSize: 16,
            color: MainTheme.chatGrey,
          ),
        ),
      );
    }

    List<dynamic> reversedChatLog = List.from(_chatLog.reversed);

    return ListView.builder(
      controller: _scrollController,  // Add scroll controller
      padding: const EdgeInsets.all(16),
      itemCount: reversedChatLog.length,
      itemBuilder: (context, index) {
        final chat = reversedChatLog[index];
        final String text = chat['chat'] ?? '';
        final String time = _formatTime(chat['timestamp']);
        final String date = _formatDate(chat['timestamp']);
        final int senderId = chat['sender_id'];

        // Show date header if it's a new day
        final bool showDate = index == 0 || 
          _formatDate(reversedChatLog[index - 1]['timestamp']) != date;

        final Widget messageWidget = senderId.toString() == _userId
            ? _pinkMessage(text, time, screenWidth)
            : _whiteMessage(text, time, screenWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDate) _dateMessage(date, screenWidth),
            SizedBox(height: 10),
            messageWidget,
          ],
        );
      },
    );
  }

  // Date
  Widget _dateMessage(String dateMessage, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        width: screenWidth * 0.1,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MainTheme.chatInfo,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          dateMessage,
          style: TextStyle(
            fontSize: 14,
            color: MainTheme.black,
            fontFamily: 'BaiJamjuree',
          ),
        ),
      ),
    );
  }

  //sender message
  Widget _pinkMessage(String text, String time, double screenWidth) {
    bool isImage = isImageUrl(text);
    
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: isImage ? 5 : 15, vertical: isImage ? 5 : 10),
            decoration: BoxDecoration(
              color: MainTheme.chatPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: isImage 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    text,
                    fit: BoxFit.cover,
                    width: screenWidth * 0.6,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: screenWidth * 0.6,
                        height: screenWidth * 0.6,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'ไม่สามารถโหลดรูปภาพได้',
                          style: TextStyle(
                            fontSize: 14,
                            color: MainTheme.black,
                            fontFamily: 'BaiJamjuree',
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: MainTheme.white,
                    fontSize: 16,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: MainTheme.chatGrey,
                fontFamily: 'BaiJamjuree',
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // receiver message
  Widget _whiteMessage(String text, String time, double screenWidth) {
    bool isImage = isImageUrl(text);
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: isImage ? 5 : 15, vertical: isImage ? 5 : 10),
            decoration: BoxDecoration(
              color: MainTheme.chatWhite,
              border: Border.all(color: MainTheme.chatPink),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isImage 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    text,
                    fit: BoxFit.cover,
                    width: screenWidth * 0.6,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: screenWidth * 0.6,
                        height: screenWidth * 0.6,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'ไม่สามารถโหลดรูปภาพได้',
                          style: TextStyle(
                            fontSize: 14,
                            color: MainTheme.black,
                            fontFamily: 'BaiJamjuree',
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: MainTheme.black,
                    fontSize: 16,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: MainTheme.chatGrey,
                fontFamily: 'BaiJamjuree',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
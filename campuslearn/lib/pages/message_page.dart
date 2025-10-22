import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/message_service.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/message.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  Conversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final conversations = await MessageService.getConversations();

      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load conversations: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openChat(Conversation conversation) {
    setState(() {
      _selectedConversation = conversation;
    });

    // On mobile, navigate to full-screen chat
    if (MediaQuery.of(context).size.width < 900) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatView(
            conversation: conversation,
            onMessageSent: _loadConversations,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      // Desktop: Split view
      return Row(
        children: [
          // Conversation list on the left
          SizedBox(
            width: 350,
            child: _buildConversationList(),
          ),
          VerticalDivider(width: 1, color: context.appColors.textSecondary.withOpacity(0.2)),
          // Chat view on the right
          Expanded(
            child: _selectedConversation != null
                ? ChatView(
                    conversation: _selectedConversation!,
                    onMessageSent: _loadConversations,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: context.appColors.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    } else {
      // Mobile: Just conversation list
      return _buildConversationList();
    }
  }

  Widget _buildConversationList() {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: MediaQuery.of(context).size.width < 900
          ? AppBar(
              title: Text('Messages'),
              backgroundColor: context.appColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: context.appColors.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return _buildConversationTile(conversation);
                    },
                  ),
                ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final isSelected = _selectedConversation?.userId == conversation.userId;

    return InkWell(
      onTap: () => _openChat(conversation),
      child: Container(
        color: isSelected ? context.appColors.primary.withOpacity(0.1) : null,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: context.appColors.primary,
              child: Text(
                conversation.userName.isNotEmpty
                    ? conversation.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: context.appColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessage != null)
                        Text(
                          conversation.lastMessage!.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.content ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: conversation.unreadCount > 0
                                ? context.appColors.textPrimary
                                : context.appColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.appColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatView extends StatefulWidget {
  final Conversation conversation;
  final VoidCallback? onMessageSent;

  const ChatView({
    super.key,
    required this.conversation,
    this.onMessageSent,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await AuthService.getUserId();
    if (mounted) {
      setState(() {
        _currentUserId = int.tryParse(userId ?? '');
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final messages = await MessageService.getMessagesWithUser(widget.conversation.userId);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      setState(() {
        _isSending = true;
      });

      await MessageService.sendMessage(
        recipientId: widget.conversation.userId,
        content: content,
      );

      // Reload messages
      await _loadMessages();

      // Notify parent
      widget.onMessageSent?.call();

      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        // Restore message content
        _messageController.text = content;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.appColors.primary,
              radius: 18,
              child: Text(
                widget.conversation.userName.isNotEmpty
                    ? widget.conversation.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.userName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.conversation.userEmail,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: context.appColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet. Start the conversation!',
                          style: TextStyle(color: context.appColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == _currentUserId;
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),

          // Input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              border: Border(
                top: BorderSide(
                  color: context.appColors.textSecondary.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: _isSending
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.send),
                  color: context.appColors.primary,
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: context.appColors.primary,
              radius: 16,
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? context.appColors.primary
                          : context.appColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                        bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : context.appColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                
                Text(
                  message.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) SizedBox(width: 0),// Space for alignment
        ],
      ),
    );
  }
}

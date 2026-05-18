import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/chat_service.dart';
import '../../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HybridChatScreen
// A polished chat screen that routes messages through ChatService.
// Shows a live AI Engine status badge: "☁ Cloud Active" | "🧠 On-Device AI"
// ─────────────────────────────────────────────────────────────────────────────
class HybridChatScreen extends StatefulWidget {
  /// Optional conversation title shown in the app bar.
  final String title;

  /// Optional system persona prepended as a context greeting.
  final String? contextHint;

  const HybridChatScreen({
    super.key,
    this.title = 'GemmaCare AI',
    this.contextHint,
  });

  @override
  State<HybridChatScreen> createState() => _HybridChatScreenState();
}

class _HybridChatScreenState extends State<HybridChatScreen>
    with TickerProviderStateMixin {
  final _chatService = ChatService();
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // ── Badge animation ────────────────────────────────────────
  late AnimationController _badgePulse;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _badgePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _badgeScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _badgePulse, curve: Curves.easeInOut),
    );

    // Show welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final greeting = widget.contextHint ??
          '👋 Hello! I\'m **GemmaCare AI**, your personal health assistant.\n\n'
              'I can help you with **medical questions**, **nutrition**, **exercise safety**, and **medication guidance**.\n\n'
              '_How can I help you today?_';
      setState(() {
        _messages.add(_ChatMessage(text: greeting, isUser: false));
      });
    });
  }

  @override
  void dispose() {
    _badgePulse.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Send message ───────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessage(text);
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: reply, isUser: false));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: '⚠️ Something went wrong. Please try again.',
            isUser: false,
            isError: true,
          ));
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── UI ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatusBanner(),
          Expanded(child: _buildMessageList()),
          _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          Text(
            'Hybrid AI · Gemini + Gemma',
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        // Force-offline toggle
        ValueListenableBuilder<AiEngine>(
          valueListenable: _chatService.activeEngine,
          builder: (_, engine, __) {
            return Tooltip(
              message: _chatService.isForceOffline
                  ? 'Switch to Cloud AI'
                  : 'Switch to On-Device AI',
              child: IconButton(
                icon: Icon(
                  _chatService.isForceOffline
                      ? Icons.wifi_off_rounded
                      : Icons.cloud_done_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _chatService.isForceOffline =
                        !_chatService.isForceOffline;
                  });
                },
              ),
            );
          },
        ),
        // New chat button
        IconButton(
          icon: const Icon(Icons.restart_alt_rounded, color: Colors.white),
          tooltip: 'New Conversation',
          onPressed: () {
            setState(() {
              _messages.clear();
              _chatService.resetSession();
              _messages.add(_ChatMessage(
                text: '🔄 **New conversation started.** How can I help you?',
                isUser: false,
              ));
            });
          },
        ),
      ],
    );
  }

  // ── Status banner ──────────────────────────────────────────
  Widget _buildStatusBanner() {
    return ValueListenableBuilder<AiEngine>(
      valueListenable: _chatService.activeEngine,
      builder: (_, engine, __) {
        final config = _engineConfig(engine);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: config.bgColor,
            boxShadow: [
              BoxShadow(
                color: config.dotColor.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _badgeScale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: config.dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: config.dotColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                config.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: config.textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _EngineConfig _engineConfig(AiEngine engine) {
    switch (engine) {
      case AiEngine.online:
        return _EngineConfig(
          label: '☁  Cloud Active · Gemini 1.5 Flash',
          bgColor: const Color(0xFFE8F5E9),
          dotColor: const Color(0xFF4CAF50),
          textColor: const Color(0xFF1B5E20),
        );
      case AiEngine.offline:
        return _EngineConfig(
          label: '🧠  On-Device AI · Gemma 2 (Local)',
          bgColor: const Color(0xFFEDE7F6),
          dotColor: const Color(0xFF7B1FA2),
          textColor: const Color(0xFF4A148C),
        );
      case AiEngine.unavailable:
        return _EngineConfig(
          label: '⚠  AI Unavailable · Check Connection',
          bgColor: const Color(0xFFFFF3E0),
          dotColor: const Color(0xFFFF9800),
          textColor: const Color(0xFFE65100),
        );
    }
  }

  // ── Message list ───────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: _messages[index]);
      },
    );
  }

  // ── Typing indicator ───────────────────────────────────────
  Widget _buildTypingIndicator() {
    if (!_isTyping) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotAnimation(delay: 0),
                const SizedBox(width: 4),
                _DotAnimation(delay: 200),
                const SizedBox(width: 4),
                _DotAnimation(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────
  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask GemmaCare AI...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(28),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message Bubble Widget
// ─────────────────────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _AiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: message.isError
                    ? Border.all(color: Colors.orange.shade200)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? AppTheme.primaryBlue.withOpacity(0.3)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1A1A2E),
                            height: 1.6),
                        strong: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue),
                        code: GoogleFonts.sourceCodePro(
                            fontSize: 12,
                            backgroundColor: const Color(0xFFF0F4FF)),
                        blockquoteDecoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                              left: BorderSide(
                                  color: AppTheme.primaryBlue, width: 3)),
                        ),
                      ),
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.psychology_rounded,
          color: Colors.white, size: 18),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded,
          color: AppTheme.primaryBlue, size: 18),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot animation for typing indicator
// ─────────────────────────────────────────────────────────────────────────────
class _DotAnimation extends StatefulWidget {
  final int delay;
  const _DotAnimation({required this.delay});

  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}

class _EngineConfig {
  final String label;
  final Color bgColor;
  final Color dotColor;
  final Color textColor;

  _EngineConfig({
    required this.label,
    required this.bgColor,
    required this.dotColor,
    required this.textColor,
  });
}

import 'package:flutter/material.dart';
import '../models/trainer_model.dart';

class LessonChatScreen extends StatefulWidget {
  const LessonChatScreen({Key? key}) : super(key: key);

  @override
  State<LessonChatScreen> createState() => _LessonChatScreenState();
}

class ChatMsg {
  final bool fromUser;
  final String text;
  final DateTime at;
  ChatMsg({required this.fromUser, required this.text, required this.at});
}

class _LessonChatScreenState extends State<LessonChatScreen> {
  final List<ChatMsg> _messages = []; // ✅ 처음엔 비어있음
  final _inputCtrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _hhmm(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _send() {
    final txt = _inputCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _messages.add(ChatMsg(fromUser: true, text: txt, at: DateTime.now()));
    });
    _inputCtrl.clear();
    // 스크롤 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    // 서버 전송 TODO
  }

  @override
  Widget build(BuildContext context) {
    final trainer = ModalRoute.of(context)!.settings.arguments as Trainer?;

    return Scaffold(
      appBar: AppBar(title: Text(trainer != null ? '${trainer.name}' : '채팅')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final align =
                    m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor =
                    m.fromUser ? const Color(0xFF6C47FF) : Colors.grey[200];
                final textColor = m.fromUser ? Colors.white : Colors.black87;

                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          m.fromUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _hhmm(m.at),
                          style: TextStyle(
                            color: textColor.withOpacity(.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 하단 입력창
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: const Color(0xFF6C47FF),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

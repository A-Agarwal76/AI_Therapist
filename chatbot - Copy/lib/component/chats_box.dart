import 'package:chonoes/component/waiting_message.dart';
import 'package:chonoes/models/chat_model.dart';
import 'package:chonoes/services/voice_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class ChatBox extends StatelessWidget {
  ChatModel chatModel;
  final VoiceService? voiceService;
  ChatBox({super.key, required this.chatModel, this.voiceService});

  @override
  Widget build(BuildContext context) {
    if (chatModel.isWaiting) {
      return const WaitingMessage();
    }
    final isSender = chatModel.isSender;
    final bubbleColor = isSender
        ? const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF64b6ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFf093fb), Color(0xFF764ba2)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          );
    final textColor = isSender ? Colors.white : Colors.white;
    final align = isSender ? Alignment.centerRight : Alignment.centerLeft;
    final radius = isSender
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Align(
        alignment: align,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            gradient: bubbleColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: isSender
                    ? Colors.blue.withOpacity(0.12)
                    : Colors.purple.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Padding(
            padding: chatModel.file != null
                ? const EdgeInsets.all(8)
                : const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSender)
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          chatModel.user.firstName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (!isSender) const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (chatModel.file != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                chatModel.file!,
                                fit: BoxFit.cover,
                                width: 180,
                              ),
                            ),
                          if (chatModel.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                chatModel.text,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSender) const SizedBox(width: 8),
                    if (isSender)
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          chatModel.user.firstName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSender)
                      IconButton(
                        icon: const Icon(Icons.copy,
                            size: 16, color: Colors.white70),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: chatModel.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard!'),
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (!isSender && voiceService != null)
                      IconButton(
                        icon: Icon(
                          voiceService!.isSpeaking
                              ? Icons.stop_circle
                              : Icons.volume_up,
                          size: 16,
                          color: Colors.white70,
                        ),
                        onPressed: () async {
                          if (voiceService!.isSpeaking) {
                            await voiceService!.stopSpeaking();
                          } else {
                            await voiceService!.speak(chatModel.text);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, right: 6, top: 2),
                      child: Text(
                        _formatTimestamp(chatModel.createAt),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

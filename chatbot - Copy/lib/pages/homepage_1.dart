import 'package:chonoes/backend/saving_data.dart';
import 'package:chonoes/backend/send_message.dart';
import 'package:chonoes/bloc/bloc.dart';
import 'package:chonoes/component/chats_box.dart';
import 'package:chonoes/models/chat_model.dart';
import 'package:chonoes/models/user_model.dart';
import 'package:chonoes/services/voice_service.dart';
import 'package:chonoes/widgets/language_selector.dart';
import 'package:chonoes/widgets/talking_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User user1;
  User chronoes = User(firstName: 'chronoes', userID: '2');
  bool isWriting = false;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<ChatModel> TextMessages = [];
  late VoiceService _voiceService;
  bool _voiceOutputEnabled = true;
  bool _isInitialized = false;
  // UI state for TTS controls
  String _selectedSpeed = 'Normal';
  String _selectedVoice = 'Neutral';

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService();
    _voiceService.addListener(_onVoiceStateChanged);
    _initializeVoice();
  }

  void _onVoiceStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when voice state changes
      });
    }
  }

  Future<void> _initializeVoice() async {
    final initialized = await _voiceService.initializeSpeech();
    if (mounted) {
      setState(() {
        _isInitialized = initialized;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _voiceService.removeListener(_onVoiceStateChanged);
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _modernAppBar(context),
      ),
      backgroundColor: const Color(0xFF232526),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232526), Color(0xFF414345)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: BlocBuilder<MessageBloc, MessageState>(
                      builder: (context, state) {
                        if (state is InitialState) {
                          user1 = creatingUser();
                          TextMessages = deStructure(user1, chronoes);
                          return _modernChatList();
                        } else if (state is SendingState) {
                          saveData(TextMessages);
                          return _modernChatList();
                        } else if (state is RecievingState) {
                          ChatModel chatModel = ChatModel(
                            text: 'text',
                            user: chronoes,
                            createAt: DateTime.now(),
                            isWaiting: true,
                            isSender: false,
                          );
                          TextMessages.add(chatModel);
                          return _modernChatList();
                        } else {
                          if (TextMessages.length > 2) {
                            TextMessages.removeAt(TextMessages.length - 2);
                            saveData(TextMessages);
                          }
                          return _modernChatList();
                        }
                      },
                    ),
                  ),
                  _modernMessageInput(context),
                ],
              ),
              // Floating talking avatar when speaking
              if (_voiceService.isSpeaking)
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: TalkingAvatar(
                    voiceService: _voiceService,
                    size: 80,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernChatList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: TextMessages.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ChatBox(
            chatModel: TextMessages[index],
            voiceService: _voiceService,
          ),
        );
      },
    );
  }

  Widget _modernMessageInput(BuildContext context) {
    final currentLang = _voiceService.currentLanguage;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        children: [
          // Language and voice settings row
          Row(
            children: [
              LanguageSelector(
                selectedLanguage: currentLang,
                onLanguageChanged: (language) {
                  setState(() {
                    _voiceService.setLanguage(language);
                  });
                },
              ),
              const SizedBox(width: 8),
              // Speed dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF232526),
                    value: _selectedSpeed,
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: 'Slow', child: Text('Slow')),
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'Fast', child: Text('Fast')),
                      DropdownMenuItem(
                          value: 'Very fast', child: Text('Very fast')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedSpeed = value;
                        double rate;
                        switch (value) {
                          case 'Slow':
                            rate = 0.5;
                            break;
                          case 'Fast':
                            rate = 1.0;
                            break;
                          case 'Very fast':
                            rate = 1.2;
                            break;
                          case 'Normal':
                          default:
                            rate = 0.8;
                        }
                        _voiceService.setSpeechRate(rate);
                      });
                    },
                    icon: const Icon(Icons.speed,
                        color: Colors.white70, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Voice profile dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF232526),
                    value: _selectedVoice,
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: 'Calm', child: Text('Calm')),
                      DropdownMenuItem(
                          value: 'Neutral', child: Text('Neutral')),
                      DropdownMenuItem(
                          value: 'Energetic', child: Text('Energetic')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedVoice = value;
                        double pitch;
                        switch (value) {
                          case 'Calm':
                            pitch = 0.9;
                            break;
                          case 'Energetic':
                            pitch = 1.1;
                            break;
                          case 'Neutral':
                          default:
                            pitch = 1.0;
                        }
                        _voiceService.setVoiceProfile(
                          profile: value,
                          pitch: pitch,
                        );
                      });
                    },
                    icon: const Icon(Icons.record_voice_over,
                        color: Colors.white70, size: 16),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _voiceOutputEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white70,
                ),
                tooltip: _voiceOutputEnabled
                    ? 'Voice output ON'
                    : 'Voice output OFF',
                onPressed: () {
                  setState(() {
                    _voiceOutputEnabled = !_voiceOutputEnabled;
                    if (!_voiceOutputEnabled) {
                      _voiceService.stopSpeaking();
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Message input row
          Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            child: Row(
              children: [
                // Voice input button
                IconButton(
                  icon: Icon(
                    _voiceService.isListening ? Icons.mic : Icons.mic_none,
                    color: _voiceService.isListening
                        ? Colors.red
                        : const Color(0xFF667eea),
                    size: 28,
                  ),
                  tooltip: 'Voice input',
                  onPressed: _isInitialized
                      ? () async {
                          if (_voiceService.isListening) {
                            await _voiceService.stopListening();
                          } else {
                            await _voiceService.startListening(
                              onResult: (text) {
                                setState(() {
                                  _controller.text = text;
                                });
                                _voiceService.stopListening();
                              },
                              onError: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Voice recognition error'),
                                  ),
                                );
                              },
                            );
                          }
                          setState(() {});
                        }
                      : null,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type or speak in ${currentLang.nativeName}...",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 32),
                  tooltip: 'Send',
                  color: const Color(0xFF667eea),
                  padding: const EdgeInsets.all(8),
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF667eea)),
                    shape: WidgetStatePropertyAll(CircleBorder()),
                    elevation: WidgetStatePropertyAll(4),
                  ),
                  onPressed: () async {
                    final blocContext = BlocProvider.of<MessageBloc>(context);
                    if (_controller.text.trim().isNotEmpty && !isWriting) {
                      isWriting = true;
                      ChatModel message = ChatModel(
                        createAt: DateTime.now(),
                        text: _controller.text.trim(),
                        user: user1,
                      );
                      _controller.clear();
                      TextMessages.add(message);
                      BlocProvider.of<MessageBloc>(context).add(DataSent());
                      BlocProvider.of<MessageBloc>(context).add(Pending());

                      // Get response with translation support
                      final response = await getdata(
                        message,
                        chronoes,
                        sourceLanguage: _voiceService.currentLanguage.code,
                        targetLanguage: _voiceService.currentLanguage.code,
                      );
                      TextMessages.add(response);

                      // Update UI immediately
                      blocContext.add(DataRecieving());

                      // Auto-play voice response if enabled (non-blocking)
                      if (_voiceOutputEnabled && response.text.isNotEmpty) {
                        // Don't await - let voice play in background
                        _voiceService.speak(response.text);
                      }
                    }
                    isWriting = false;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _modernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      title: Row(
        children: [
          TalkingAvatar(
            voiceService: _voiceService,
            size: 44,
            showInAppBar: true,
          ),
          const SizedBox(width: 12),
          const Text(
            "chronoes",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _voiceService.currentLanguage.nativeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

scrollFun(ScrollController scrollController) {
  scrollController.animateTo(scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
}

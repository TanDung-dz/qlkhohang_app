import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/inventory_tab.dart';
import '../tabs/reports_tab.dart';
import '../tabs/settings_tab.dart';
import '../../services/chatbot_service.dart';  // Import the ChatbotService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _chatController = TextEditingController();
  final List<String> _messages = [];
  final _chatbotService = ChatbotService();  // Initialize the ChatbotService
  bool _isChatVisible = false; // To manage the visibility of the chatbot

  void _logout() {
    _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Function to send the message and get the chatbot response
  void _sendMessage() async {
    if (_chatController.text.isNotEmpty) {
      setState(() {
        _messages.add('You: ${_chatController.text}');
      });

      try {
        final response = await _chatbotService.getChatbotResponse(_chatController.text);
        setState(() {
          _messages.add('Bot: $response');
        });
      } catch (e) {
        setState(() {
          _messages.add('Bot: Sorry, something went wrong.');
        });
      }

      _chatController.clear();
    }
  }

  final List<Widget> _tabs = const [
    DashboardTab(),
    InventoryTab(),
    ReportsTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isManager = _authService.isManager();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Quản lý kho hàng'),
            if (isManager)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Chip(
                  label: Text('Quản lý'),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          // Toggle Button to show/hide chatbot
          IconButton(
            icon: Icon(_isChatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline),
            onPressed: () {
              setState(() {
                _isChatVisible = !_isChatVisible;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Your Tab content
          Expanded(
            child: _tabs[_currentIndex],
          ),

          // Chatbot UI (only visible when _isChatVisible is true)
          if (_isChatVisible)
            Expanded(
              child: Column(
                children: [
                  // Chat Messages
                  Expanded(
                    child: ListView.builder(
                      reverse: true, // To show the newest messages at the bottom
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUserMessage = message.startsWith('You:');

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Align(
                            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                message.substring(4), // Remove 'You:' or 'Bot:' prefix
                                style: TextStyle(
                                  color: isUserMessage ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Input Field and Send Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                          color: Colors.blueAccent,
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Kho hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

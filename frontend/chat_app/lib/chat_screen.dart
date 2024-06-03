import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  List<String> chatHistory = [];

  @override
  void initState() {
    _connectToServer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    socket.disconnect();
    super.dispose();
  }

  void _connectToServer() {
    socket = IO.io('http://localhost:5999', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _setupCommunicationSystem();
  }

  void _setupCommunicationSystem() {
    socket.on('message', (data) {
      setState(() {
        chatHistory.add('ChatBot: ${data.toString()}');
      });
    });

    // Connect to the server
    socket.connect();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      socket.emit('message', _controller.text);
      // chatHistory.add('You: ${_controller.text}');

      chatHistory.add('${_controller.text}');
      _controller.text = '';
      setState(() {}); // Update the UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'ChatBot',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              ),
              ),
             Spacer()
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  final message = chatHistory[index];
                  final isServerMessage = message.startsWith('ChatBot:');
                  return Align(
                    alignment: isServerMessage
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: isServerMessage
                            ? Colors.black12
                            : Colors.black26,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(message),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',

                      labelText: "Have a question?",
                              border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // Adjust as desired
          ),

                    
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                      Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: _sendMessage,
                  color: Colors.black,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black38, // Set button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Add rounded corners
                    ),
                  ),


                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
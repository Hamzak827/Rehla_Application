enum Role { user, assistant }

class ChatGPTModel {
  ChatGPTModel({required this.role, required this.content});
  final Role role;
  final List<String> content;
}
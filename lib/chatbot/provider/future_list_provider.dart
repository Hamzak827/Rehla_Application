import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:Rehla/chatbot/model/chat_model.dart';

Future<List<Content>> getGeminiHistory() async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final db = FirebaseDatabase.instance.reference();
  final defaultPath = db.child(currentUser.uid).child("chat").child("gemini");

  // Fetch last query and delete if role is 'user'
  final lastQueryEvent = await defaultPath.orderByChild("createdAt").limitToLast(1).once();
  final lastQuerySnapshot = lastQueryEvent.snapshot;

  if (lastQuerySnapshot.value != null) {
    final lastData = (lastQuerySnapshot.value as Map).values.first;
    final lastKey = (lastQuerySnapshot.value as Map).keys.first;
    if (lastData['role'] == 'user') {
      await defaultPath.child(lastKey).remove();
    }
  }

  final responseEvent = await defaultPath.orderByChild("createdAt").once();
  final responseSnapshot = responseEvent.snapshot;

  final List<Content> chatList = [];
  if (responseSnapshot.value != null) {
    final sortedEntries = (responseSnapshot.value as Map).entries.toList()
      ..sort((a, b) => (a.value['createdAt'] as int).compareTo(b.value['createdAt'] as int));

    for (var entry in sortedEntries) {
      chatList.add(Content(entry.value['role'], [TextPart(entry.value["content"])]));
    }
  }

  return chatList;
}

class GeminiListNotifier extends StateNotifier<List<Content>> {
  GeminiListNotifier(super.state);

  void addNewChat(Content chat) {
    state = [...state, chat];
  }

  void updateLastChat(String text) {
    final last = state.last;
    final con = Content(last.role, [...last.parts, TextPart(text)]);
    state = [...state.sublist(0, state.length - 1), con];
  }

  void updateState(List<Content> list) {
    state = list;
  }

   void removeAt(int index) {
    state = [...state]..removeAt(index);
  }
}

final geminiListProvider =
    StateNotifierProvider<GeminiListNotifier, List<Content>>((ref) {
  return GeminiListNotifier([]);
});

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:Rehla/chatbot/provider/ai_provider.dart';
import 'package:Rehla/chatbot/provider/future_list_provider.dart';
import 'package:Rehla/chatbot/widgets/chat_screen_widgets/model_text_widget.dart';
import 'package:Rehla/chatbot/widgets/chat_screen_widgets/text_field_widget.dart';
import 'package:Rehla/chatbot/widgets/chat_screen_widgets/user_text_widget.dart';

class GeminiTabWindow extends ConsumerStatefulWidget {
  const GeminiTabWindow({super.key});

  @override
  ConsumerState<GeminiTabWindow> createState() => _GeminiTabWindowState();
}

class _GeminiTabWindowState extends ConsumerState<GeminiTabWindow> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late TextEditingController textController;
  bool isDisableButton = true;
  bool allow = true;
  Set<int> selectedMessages = {}; // Keep track of selected messages
  List<String> messageKeys = []; // Store Firebase keys for each message

  @override
  void initState() {
    textController = TextEditingController();
    textController.addListener(() {
      setState(() {
        isDisableButton = textController.text.trim().isEmpty;
      });
    });

    // Load the chat history when the widget is initialized
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getGeminiHistory().then((history) {
        ref.read(geminiListProvider.notifier).updateState(history);
        // Populate messageKeys when loading chat history
        loadMessageKeys();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    // Clear selected messages when navigating back
    selectedMessages.clear();
    super.dispose();
  }

void loadMessageKeys() async {
  DatabaseReference ref = FirebaseDatabase.instance
      .reference()
      .child(currentUser.uid)
      .child("chat")
      .child("gemini");

  // Using `once` to retrieve a single event
  ref.once().then((DatabaseEvent event) {
    DataSnapshot snapshot = event.snapshot; // Get the snapshot from the event
    if (snapshot.value != null) {
      Map<dynamic, dynamic> messages = snapshot.value as Map<dynamic, dynamic>;
      messages.forEach((key, value) {
        messageKeys.add(key);
      });
    }

    // Log how many keys were loaded
    print("Loaded messageKeys: ${messageKeys.length}");
  }).catchError((error) {
    print("Failed to load message keys: $error");
  });
}






  void getGeminiResponse(
      WidgetRef ref, List<Content> list, String text) async {
    final apiKey = ref.read(geminiKey).toString();
    final chatList = ref.watch(geminiListProvider.notifier);
    try {
      final model = GenerativeModel(
        apiKey: apiKey,
        model: "gemini-pro",
        generationConfig: GenerationConfig(),
      );

      final chat = model.startChat(history: list);

      final content = Content.text(text);

      final response = chat.sendMessageStream(content);
      await for (final item in response) {
        chatList.updateLastChat(item.text!);
      }
    } on GenerativeAIException catch (e) {
      chatList.updateLastChat(e.message);
    } finally {
      ref.read(geminiListProvider).last.parts.removeAt(0);
      if (ref.read(geminiListProvider).last.parts.isEmpty) {
        chatList.updateLastChat("Unable to generate response.");
      }
      DatabaseReference messageRef = FirebaseDatabase.instance
          .reference()
          .child(currentUser.uid)
          .child("chat")
          .child("gemini")
          .push();

      messageRef.set({
        'role': 'model',
        'content': ref
            .read(geminiListProvider)
            .last
            .parts
            .whereType<TextPart>()
            .map((e) => e.text)
            .join(),
        "createdAt": ServerValue.timestamp,
      }).then((_) {
        // Store the Firebase key for the new message
        messageKeys.add(messageRef.key!);
      }).catchError((error) {
        print("Failed to store message key: $error");
      });

      setState(() {
        allow = true;
      });
    }
  }

void deleteMessage(int index) {
  final list = ref.read(geminiListProvider);
  final realIndex = list.length - 1 - index; // Correct index for reversed list

  print('Attempting to delete message at index: $index (realIndex: $realIndex), messageKeys length: ${messageKeys.length}');

  if (realIndex >= 0 && realIndex < messageKeys.length) {
    final messageKey = messageKeys[realIndex];
    
    print('Deleting message with key: $messageKey');
    FirebaseDatabase.instance
        .reference()
        .child(currentUser.uid)
        .child("chat")
        .child("gemini")
        .child(messageKey)
        .remove()
        .then((_) {
          print("Message deleted successfully: $messageKey");
          ref.read(geminiListProvider.notifier).removeAt(realIndex);
          messageKeys.removeAt(realIndex);
        })
        .catchError((error) {
          print("Failed to delete message: $error");
        });
  } else {
    print('Index out of bounds: $realIndex, messageKeys length: ${messageKeys.length}');
  }
}




  void toggleSelection(int index) {
    setState(() {
      if (selectedMessages.contains(index)) {
        selectedMessages.remove(index);
      } else {
        selectedMessages.add(index);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(geminiListProvider);
    final list1 = list.reversed.toList();
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return WillPopScope(
      onWillPop: () async {
        if (selectedMessages.isNotEmpty) {
          clearSelection();
          return false; // Prevent back navigation if messages are selected
        } else {
          return true; // Allow back navigation if no messages are selected
        }
      },
      child: Scaffold(
        backgroundColor:
            isLightTheme ? Color.fromRGBO(206, 199, 191, 4) : Colors.black,
        appBar: selectedMessages.isNotEmpty
            ? AppBar(
  title: Text(
    '${selectedMessages.length} selected',
    style: TextStyle(
      color: Colors.white, // Set title text color to white
    ),
  ),
  backgroundColor: Color.fromRGBO(66, 66, 66, 1),
  iconTheme: IconThemeData(
    color: Colors.white, // Set icon colors to white
  ),
  leading: IconButton(
    icon: Icon(Icons.clear),
    onPressed: clearSelection, // Clear selected messages
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {
        // Implement delete functionality for selected messages
        List<int> selectedList = selectedMessages.toList();
        selectedList.sort((a, b) => b.compareTo(a)); // Sort in descending order
        selectedList.forEach((index) {
          deleteMessage(index);
        });
        // Clear selected messages
        clearSelection();
      },
    ),
  ],
)

            : null,
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
  reverse: true,
  itemCount: list1.length,
  itemBuilder: (context, index) {
    bool isSelected = selectedMessages.contains(index);
    if (list1[index].role == 'user') {
      return GestureDetector(
        onTap: () {
          toggleSelection(index);
        },
        child: Container(
        color: isSelected ? Colors.grey.withOpacity(0.5) : null,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: UserText(
            value: list1[index]
                .parts
                .whereType<TextPart>()
                .map((e) => e.text)
                .join(''),
            onPressed: (String text) {
              textController.text = text;
            },
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          toggleSelection(index);
        },
        child: Container(
          color: isSelected ? Colors.grey.withOpacity(0.5) : null,
          padding: const EdgeInsets.only(bottom: 8.0, left: 2, right: 2),
          child: ModelText(
            text: list1[index]
                .parts
                .whereType<TextPart>()
                .map((e) => e.text)
                .join(''),
            imgAddress: "assets/images/gemini_logo.svg",
          ),
        ),
      );
    }
  },
),
            ),
            TextFieldWidget(
              isDisableButton: isDisableButton,
              textController: textController,
              enableButton: allow,
              onPressed: (String text) {
                DatabaseReference messageRef = FirebaseDatabase.instance
                    .reference()
                    .child(currentUser.uid)
                    .child("chat")
                    .child("gemini")
                    .push();

                messageRef.set({
                  'role': 'user',
                  'content': text,
                  "createdAt": ServerValue.timestamp,
                }).then((_) {
                  // Store the Firebase key for the new message
                  messageKeys.add(messageRef.key!);
                }).catchError((error) {
                  print("Failed to store message key: $error");
                });

                final listRef = ref.read(geminiListProvider.notifier);
                listRef.addNewChat(Content('user', [TextPart(text)]));
                setState(() {
                  allow = false;
                });
                listRef.addNewChat(Content('model', [TextPart("")]));

                final a = ref.read(geminiListProvider);
                getGeminiResponse(ref, a.sublist(0, a.length - 2), text);
              },
            ),
          ],
        ),
      ),
    );
  }
}

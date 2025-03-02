import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final geminiKey = StateProvider<String?>((ref) => dotenv.env['GEMINI_KEY']);
final chatGPTKey = StateProvider<String?>((ref) => dotenv.env['CHATGPT_KEY']);




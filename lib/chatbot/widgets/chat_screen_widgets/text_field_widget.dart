import 'dart:ui';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    Key? key,
    required this.onPressed,
    required this.enableButton,
    required this.textController,
    required this.isDisableButton,
  }) : super(key: key);

  final bool enableButton;
  final bool isDisableButton;
  final TextEditingController textController;
  final void Function(String text) onPressed;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextEditingController textController;

  @override
  void initState() {
    textController = widget.textController;
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Color.fromRGBO(66, 66, 66, 1),
                ),
                child: TextField(
                  controller: textController,
                  minLines: 1,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardAppearance: Brightness.dark,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromRGBO(66, 66, 66, 1),
                    contentPadding: EdgeInsets.only(bottom: 60 / 2, right: 20, left: 20),
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.57)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(66, 66, 66, 1),
              ),
              child: IconButton(
                disabledColor: const Color.fromRGBO(49, 49, 49, 1),
                onPressed: widget.enableButton
                    ? !widget.isDisableButton
                        ? () {
                            widget.onPressed(textController.text.trim());
                            textController.clear();
                            setState(() {
                              // widget.isDisableButton = true;
                            });
                          }
                        : null
                    : null,
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white, // Set the send icon color to white
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

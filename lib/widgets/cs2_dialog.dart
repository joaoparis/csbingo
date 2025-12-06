import 'package:csbingo/widgets/cs2_button.dart';
import 'package:flutter/material.dart';

class Cs2Dialog extends StatelessWidget {
  const Cs2Dialog({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
  });

  final String title;
  final String content;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing: use full width on small screens with padding, 40% on larger screens
    final dialogWidth = screenWidth < 600
        ? screenWidth * 0.9 // 90% width with 5% padding on each side for phones
        : screenWidth * 0.4;

    final dialogHeight = screenHeight * 0.3;

    return Dialog(
      constraints: BoxConstraints.tight(
        Size(dialogWidth, dialogHeight),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: const Color(0xFF2B2B2B),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Bar
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              color: const Color(0xFF1F1F1F),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontFamily: "StratumNo2",
                ),
              ),
            ),
          ),

          // Body Text
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 30, 14, 14),
              alignment: Alignment.topLeft,
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.3,
                  fontFamily: "StratumNo2",
                ),
              ),
            ),
          ),

          // Button
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 14, 14),
              alignment: Alignment.centerRight,
              child: CS2Button(
                text: buttonText,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

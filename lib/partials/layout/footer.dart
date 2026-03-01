import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final String text;

  const Footer({Key? key, this.text = "© 2025 Uni Tech"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              Icon(Icons.linked_camera_outlined, color: Colors.grey, size: 16),
              SizedBox(width: 5),
              Icon(Icons.linked_camera_outlined, color: Colors.grey, size: 16),
              SizedBox(width: 5),
              Icon(Icons.linked_camera_outlined, color: Colors.grey, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

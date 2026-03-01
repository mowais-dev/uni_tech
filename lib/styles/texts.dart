import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const sideMeanuGadient = const LinearGradient(
  colors: [Color.fromARGB(255, 22, 22, 22), Color.fromARGB(255, 30, 30, 30)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final double formSpacing = 15;
final kwarning = Colors.orangeAccent;
final kdanger = Colors.redAccent;
final kinfo = Colors.blue;
final ksuccess = Colors.green;
final primaryButtonText = GoogleFonts.michroma(
  fontSize: 14,
  fontWeight: FontWeight.w700,
);
final primaryButton = ElevatedButton.styleFrom(
  backgroundColor: kwhite,
  foregroundColor: Colors.black,
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
);
final primaryButtonInvert = ElevatedButton.styleFrom(
  backgroundColor: Colors.black,
  foregroundColor: kwhite,
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
);
final iconButtonStyle = IconButton.styleFrom(
  backgroundColor: Color.fromARGB(255, 49, 49, 49),
  foregroundColor: kwhite,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  padding: const EdgeInsets.all(12),
);
const kwhite = Colors.white;
final kmutedtext = const Color.fromARGB(255, 221, 221, 221);

final tableHeaderStyle = GoogleFonts.michroma(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

final formHeaderText = GoogleFonts.michroma(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.w800,
);

final formSubHeaderText = GoogleFonts.michroma(
  color: Colors.white,
  fontSize: 12,
  fontWeight: FontWeight.normal,
);

final whiteText = TextStyle(color: kwhite);
final mutedText = TextStyle(color: const Color.fromARGB(255, 221, 221, 221));

InputDecoration inputDecoration(label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: kwhite),
    floatingLabelStyle: TextStyle(color: kwhite),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kwhite)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 22, 22, 22), width: 2),
    ),
  );
}

final tableCellStyle = GoogleFonts.lato(color: Colors.white, fontSize: 14);

class CustomButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String size;

  const CustomButton({
    required this.label,
    required this.onClick,
    this.size = "medium",
    this.foregroundColor = Colors.black,
    this.backgroundColor = kwhite,
    super.key,
  });

  final String label;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    var padding = EdgeInsets.symmetric(vertical: 8, horizontal: 20);
    double textSize = 14;
    switch (size) {
      case "small":
        padding = EdgeInsets.symmetric(vertical: 6, horizontal: 14);
        textSize = 10;
        break;
      case "medium":
        padding = EdgeInsets.symmetric(vertical: 8, horizontal: 20);
        textSize = 14;
        break;
      case "large":
        padding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
        textSize = 18;
        break;
    }

    return TextButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onClick,
      child: Text(
        label,
        style: GoogleFonts.michroma(
          fontSize: textSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

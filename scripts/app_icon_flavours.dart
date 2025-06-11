// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image/image.dart';

const iconSize = 1024;
const String baseIconPath = 'assets/dev/app_icon.prod.png';

// const pushToTheRight = true;
const pushToTheRight = false;
// const pushToTheBottom = true;
const pushToTheBottom = false;

const blurRadius = 8;
const textScale = 3;
const padding = .12;

final font = arial48;
final Color stgTextColor = ColorRgba8(144, 238, 144, 255);
final Color devTextColor = ColorRgba8(255, 0, 0, 255);
final Color textShadeColor = ColorRgba8(0, 0, 0, 255);

Future<void> main() async {
  await createFlavorIcon('assets/dev/app_icon.dev.png', 'DEV', devTextColor);
  await createFlavorIcon('assets/dev/app_icon.stg.png', 'STG', stgTextColor);
}

Future<void> createFlavorIcon(
    String outputPath, String text, Color textColor) async {
  // Load the original icon
  final originalBytes = await File(baseIconPath).readAsBytes();
  final baseIcon = decodeImage(originalBytes);

  if (baseIcon == null) {
    throw Exception('Could not decode image: $baseIconPath');
  }

  if (iconSize != baseIcon.width || iconSize != baseIcon.height) {
    throw Exception('App icon must be ${iconSize}x$iconSize pixels');
  }

  final flavoredIcon = Image.from(baseIcon);
  final textImage = createTextImage(text, textColor);

  compositeImage(
    flavoredIcon,
    textImage,
    dstX: anchor(textImage.width, pushToTheRight),
    dstY: anchor(textImage.height, pushToTheBottom),
    blend: BlendMode.alpha,
  );

  // Save the result
  final outputBytes = encodePng(flavoredIcon);
  await File(outputPath).writeAsBytes(outputBytes);

  print('Banner "$text" added successfully! Output: $outputPath');
}

int anchor(int size, bool push) {
  int pad = (iconSize * padding).round();
  return push ? iconSize - size - pad : pad;
}

Image createTextImage(String text, Color color) {
  final height = font.lineHeight + (blurRadius * 2);

  var textImage = Image(
    width: height * text.length * 2, // we'll trim the excess later
    height: height,
    numChannels: 4,
  );

  drawString(textImage, text, font: font, x: blurRadius, color: textShadeColor);
  textImage = gaussianBlur(textImage, radius: 4);
  drawString(textImage, text, font: font, x: blurRadius, color: color);

  textImage = resize(
    textImage,
    width: (textImage.width * textScale).round(),
    height: (textImage.height * textScale).round(),
    interpolation: Interpolation.cubic,
  );

  textImage = trim(textImage, mode: TrimMode.transparent);

  textImage = copyRotate(textImage,
      angle: pushToTheBottom == pushToTheRight ? -45 : 45);

  return textImage;
}

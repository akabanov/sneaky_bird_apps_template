// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart';

const iconSize = 1024;

const pushToTheBottom = true;

const textScale = 3;
const padding = .12;

final font = arial48;
final Color stgTextColor = ColorRgba8(144, 238, 144, 255);
final Color devTextColor = ColorRgba8(255, 0, 0, 255);
final Color monochromeTextColor = ColorRgba8(45, 45, 47, 255);
final Color tintedTextColor = ColorRgba8(198, 201, 205, 255);
final Color textShadeColor = ColorRgba8(0, 0, 0, 255);

Future<void> main() async {
  await createFlavorIcon(
      'assets/dev/app_icon.dev.base.png', 'DEV', devTextColor);
  await createFlavorIcon(
      'assets/dev/app_icon.stg.base.png', 'STG', stgTextColor);
  await createFlavorIcon(
      'assets/dev/app_icon.dev.white.png', 'DEV', devTextColor);
  await createFlavorIcon(
      'assets/dev/app_icon.stg.white.png', 'STG', stgTextColor);
  await createFlavorIcon(
      'assets/dev/app_icon.dev.monochrome.png', 'DEV', monochromeTextColor);
  await createFlavorIcon(
      'assets/dev/app_icon.stg.monochrome.png', 'STG', monochromeTextColor);
  await createFlavorIcon(
      'assets/dev/app_icon.dev.tinted.png', 'DEV', tintedTextColor);
  await createFlavorIcon(
      'assets/dev/app_icon.stg.tinted.png', 'STG', tintedTextColor);
}

Future<void> createFlavorIcon(
    String outputPath, String text, Color textColor) async {
  // Load the original icon
  final baseIconPath = outputPath.replaceAll(
      '.${text.toLowerCase()}.', '.prod.');
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
    dstX: ((flavoredIcon.width - textImage.width) / 2).toInt(),
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
  final height = font.lineHeight;

  var textImage = Image(
    width: height * text.length * 2, // we'll trim the excess later
    height: height,
    numChannels: 4,
  );

  drawString(textImage, text, font: font, color: color);

  textImage = resize(
    textImage,
    width: (textImage.width * textScale).round(),
    height: (textImage.height * textScale).round(),
    interpolation: Interpolation.cubic,
  );

  textImage = trim(textImage, mode: TrimMode.transparent);

  return textImage;
}

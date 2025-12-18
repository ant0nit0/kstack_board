import 'dart:io';

import 'package:flutter/material.dart';

import '../dialogs/background_editor_dialog.dart';

mixin BackgroundManagerMixin<T extends StatefulWidget> on State<T> {
  // Background customization variables
  Color backgroundColor = Colors.white;
  Gradient? backgroundGradient = const LinearGradient(
    colors: [Colors.grey, Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  File? backgroundImage;
  double backgroundWidth = 600.0;
  double backgroundHeight = 900.0;

  double get backgroundAspectRatio => backgroundWidth / backgroundHeight;
  double backgroundElevation = 1.0;
  BoxFit backgroundFit = BoxFit.cover;
  bool useGradient = true; // Start with gradient as default
  bool useImage = false;

  /// Background Editor Methods
  void openBackgroundEditor() {
    showDialog(
      context: context,
      builder: (context) => BackgroundEditorDialog(
        backgroundColor: backgroundColor,
        backgroundGradient: backgroundGradient,
        backgroundImage: backgroundImage,
        backgroundWidth: backgroundWidth,
        backgroundHeight: backgroundHeight,
        backgroundElevation: backgroundElevation,
        backgroundFit: backgroundFit,
        useGradient: useGradient,
        useImage: useImage,
        onSave: (
          Color color,
          Gradient? gradient,
          File? image,
          double width,
          double height,
          double elevation,
          BoxFit fit,
          bool useGradient,
          bool useImage,
        ) {
          setState(() {
            backgroundColor = color;
            backgroundGradient = gradient;
            backgroundImage = image;
            backgroundWidth = width;
            backgroundHeight = height;
            backgroundElevation = elevation;
            backgroundFit = fit;
            this.useGradient = useGradient;
            this.useImage = useImage;
          });
        },
      ),
    );
  }

  Widget buildBackground() {
    if (useImage && backgroundImage != null) {
      return Container(
        width: backgroundWidth,
        height: backgroundHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(backgroundImage!),
            fit: backgroundFit,
          ),
        ),
      );
    } else if (useGradient && backgroundGradient != null) {
      return Container(
        width: backgroundWidth,
        height: backgroundHeight,
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
      );
    } else {
      return Container(
        width: backgroundWidth,
        height: backgroundHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
      );
    }
  }
}

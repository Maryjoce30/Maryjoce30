import 'package:flutter/material.dart';

class BeautyProduct {
  final String name;
  final String description;
  final IconData icon;

  const BeautyProduct({
    required this.name,
    required this.description,
    required this.icon,
  });
}

final List<BeautyProduct> beautyProducts = [
  BeautyProduct(
    name: 'Lipstick',
    description: 'Adds color, texture, and protection to the lips.',
    icon: Icons.face,
  ),
  BeautyProduct(
    name: 'Mascara',
    description: 'Enhances the eyelashes by darkening, thickening, lengthening, and/or defining them.',
    icon: Icons.visibility,
  ),
  BeautyProduct(
    name: 'Eyelash Curler',
    description: 'A hand-operated mechanical device for curling eyelashes.',
    icon: Icons.remove_red_eye,
  ),
  BeautyProduct(
    name: 'Compact Powder',
    description: 'A cosmetic powder applied to the face to set makeup.',
    icon: Icons.blur_circular,
  ),
  BeautyProduct(
    name: 'Eyeshadow Palette',
    description: 'A collection of eyeshadows in a single package.',
    icon: Icons.palette,
  ),
  BeautyProduct(
    name: 'Foundation Bottle',
    description: 'Skin-colored makeup applied to the face to create an even, uniform color.',
    icon: Icons.format_color_fill,
  ),
  BeautyProduct(
    name: 'Makeup Brush',
    description: 'A tool with bristles, used for the application of makeup or face painting.',
    icon: Icons.brush,
  ),
  BeautyProduct(
    name: 'Eyeliner Pen',
    description: 'Used to define the eyes. It is applied around the contours of the eye.',
    icon: Icons.edit,
  ),
  BeautyProduct(
    name: 'Makeup Sponge',
    description: 'A sponge used to apply makeup.',
    icon: Icons.bubble_chart,
  ),
  BeautyProduct(
    name: 'False Eyelashes',
    description: 'Artificial lashes used to enhance the length, curl, fullness, and thickness of natural eyelashes.',
    icon: Icons.visibility_off,
  ),
];

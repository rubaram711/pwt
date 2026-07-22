// Maps the original prototype asset paths to the embedded (base64) images,
// so the data layer can keep referencing 'assets/products/PW90.png' verbatim.

import 'package:flutter/widgets.dart';
import 'embedded_images.dart';

bool hasLocalAsset(String assetPath) {
  switch (assetPath) {
    case 'assets/new_logo.png':
    case 'assets/products/PW90.png':
    case 'assets/products/PW50.png':
    case 'assets/products/PW90CT.png':
    case 'assets/products/S4.png':
    case 'assets/products/S18C.png':
      return true;
    default:
      return false;
  }
}

ImageProvider pwtImage(String assetPath) {
  switch (assetPath) {
    case 'assets/new_logo.png':
      return const AssetImage('assets/new_logo.png');
    case 'assets/products/PW90.png':
      return EmbeddedImages.products_PW90Image;
    case 'assets/products/PW50.png':
      return EmbeddedImages.products_PW50Image;
    case 'assets/products/PW90CT.png':
      return EmbeddedImages.products_PW90CTImage;
    case 'assets/products/S4.png':
      return EmbeddedImages.products_S4Image;
    case 'assets/products/S18C.png':
      return EmbeddedImages.products_S18CImage;
    default:
      // Fallback to the logo so a typo never crashes a build.
      return const AssetImage('assets/new_logo.png');
  }
}

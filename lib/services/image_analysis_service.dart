import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../models/product_payload.dart';

/// Runs Google's on-device ML Kit label model against a local camera/gallery
/// image. Its labels are evidence, not guesses from filename or UI state.
class ImageAnalysisService {
  Future<ProductPayload> analyse({
    required String imagePath,
    required String languageCode,
    List<String> additionalImages = const <String>[],
  }) async {
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: .42),
    );
    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(imagePath));
      final evidence = labels
          .where((label) => label.confidence >= .42)
          .toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      final tags = evidence
          .take(5)
          .map((label) => label.label.trim().toLowerCase())
          .where((label) => label.isNotEmpty)
          .toSet()
          .toList(growable: false);
      final catalog = _catalogFor(tags);
      return ProductPayload(
        id: 'craft-${DateTime.now().microsecondsSinceEpoch}',
        heroImagePath: imagePath,
        name: catalog.name,
        category: catalog.category,
        description: _description(catalog, tags, languageCode),
        suggestedPrice: catalog.suggested,
        priceLow: catalog.low,
        priceHigh: catalog.high,
        currency: 'INR',
        tags: tags,
        moreInfo: _evidenceSummary(evidence, languageCode),
        additionalImages: additionalImages,
        comments: const <NativeComment>[],
      );
    } finally {
      await labeler.close();
    }
  }

  _CatalogRule _catalogFor(List<String> tags) {
    final text = tags.join(' ');
    if (RegExp(r'jewel|necklace|ring|bracelet').hasMatch(text)) return const _CatalogRule('Handcrafted jewellery', 'Jewellery', 700, 1800);
    if (RegExp(r'textile|fabric|clothing|dress|scarf').hasMatch(text)) return const _CatalogRule('Handcrafted textile', 'Textiles', 450, 1400);
    if (RegExp(r'pottery|vase|ceramic|cup|bowl').hasMatch(text)) return const _CatalogRule('Handmade ceramic piece', 'Pottery & ceramics', 350, 1200);
    if (RegExp(r'basket|wood|furniture').hasMatch(text)) return const _CatalogRule('Handmade home craft', 'Home decor', 400, 1500);
    return const _CatalogRule('Handcrafted artisan product', 'Handicrafts', 300, 1000);
  }

  String _description(_CatalogRule catalog, List<String> tags, String languageCode) {
    final related = tags.skip(1).take(3).join(', ');
    if (languageCode == 'hi') return '${catalog.name}। AI ने ${related.isEmpty ? 'उत्पाद की तस्वीर' : related} को पहचाना है। सामग्री और आकार बोलकर जोड़ें, फिर प्रकाशित करें।';
    return '${catalog.name}. On-device analysis detected ${related.isEmpty ? 'the product image' : related}. Add material and dimensions by voice, then review before publishing.';
  }

  String _evidenceSummary(List<ImageLabel> labels, String languageCode) {
    if (labels.isEmpty) {
      return languageCode == 'hi' ? 'कोई भरोसेमंद दृश्य लेबल नहीं मिला। आवाज़ से विवरण जोड़ें।' : 'No confident visual label. Add craft details using voice.';
    }
    final values = labels.take(5).map((label) => '${label.label} ${(label.confidence * 100).toStringAsFixed(0)}%').join(' • ');
    return languageCode == 'hi' ? 'डिवाइस पर मिले दृश्य लेबल: $values' : 'On-device visual evidence: $values';
  }
}

class _CatalogRule {
  const _CatalogRule(this.name, this.category, this.low, this.high);
  final String name;
  final String category;
  final int low;
  final int high;
  int get suggested => ((low + high) / 2).round();
}

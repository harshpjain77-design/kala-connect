/// The single structured contract emitted by the edge pipeline / cloud
/// enrichment service. Every product template is hydrated from this payload.
class ProductPayload {
  const ProductPayload({
    required this.id,
    required this.heroImagePath,
    required this.name,
    required this.category,
    required this.description,
    required this.suggestedPrice,
    required this.priceLow,
    required this.priceHigh,
    required this.currency,
    required this.tags,
    required this.moreInfo,
    required this.additionalImages,
    required this.comments,
  });

  final String id;
  final String heroImagePath;
  final String name;
  final String category;
  final String description;
  final int suggestedPrice;
  final int priceLow;
  final int priceHigh;
  final String currency;
  final List<String> tags;
  final String moreInfo;
  final List<String> additionalImages;
  final List<NativeComment> comments;

  factory ProductPayload.fromJson(Map<String, dynamic> json) {
    return ProductPayload(
        id: json['id'] as String,
        heroImagePath: json['heroImagePath'] as String,
        name: json['name'] as String? ?? 'Handcrafted item',
        category: json['category'] as String? ?? 'Handicrafts',
        description: json['description'] as String,
        suggestedPrice: (json['suggestedPrice'] as num).round(),
        priceLow: ((json['priceLow'] ?? json['suggestedPrice']) as num).round(),
        priceHigh: ((json['priceHigh'] ?? json['suggestedPrice']) as num).round(),
      currency: json['currency'] as String? ?? 'INR',
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? const <String>[]),
      moreInfo: json['moreInfo'] as String? ?? '',
      additionalImages: List<String>.from(json['additionalImages'] as List<dynamic>? ?? const <String>[]),
      comments: (json['comments'] as List<dynamic>? ?? const <dynamic>[])
          .map((value) => NativeComment.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'heroImagePath': heroImagePath,
        'name': name,
        'category': category,
        'description': description,
        'suggestedPrice': suggestedPrice,
        'priceLow': priceLow,
        'priceHigh': priceHigh,
        'currency': currency,
        'tags': tags,
        'moreInfo': moreInfo,
        'additionalImages': additionalImages,
        'comments': comments
            .map((comment) => <String, Object?>{
                  'author': comment.author,
                  'message': comment.message,
                  'languageCode': comment.languageCode,
                })
            .toList(growable: false),
      };

  ProductPayload copyWith({
    int? suggestedPrice,
    int? priceLow,
    int? priceHigh,
    List<NativeComment>? comments,
    String? heroImagePath,
    List<String>? additionalImages,
    String? moreInfo,
  }) => ProductPayload(
        id: id,
        heroImagePath: heroImagePath ?? this.heroImagePath,
        name: name,
        category: category,
        description: description,
        suggestedPrice: suggestedPrice ?? this.suggestedPrice,
        priceLow: priceLow ?? this.priceLow,
        priceHigh: priceHigh ?? this.priceHigh,
        currency: currency,
        tags: tags,
        moreInfo: moreInfo ?? this.moreInfo,
        additionalImages: additionalImages ?? this.additionalImages,
        comments: comments ?? this.comments,
      );
}

class NativeComment {
  const NativeComment({required this.author, required this.message, required this.languageCode});

  final String author;
  final String message;
  final String languageCode;

  factory NativeComment.fromJson(Map<String, dynamic> json) => NativeComment(
        author: json['author'] as String? ?? 'Buyer',
        message: json['message'] as String,
        languageCode: json['languageCode'] as String? ?? 'hi',
      );
}

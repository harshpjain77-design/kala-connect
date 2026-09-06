import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/product_payload.dart';
import 'product_repository.dart';

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _products(String artisanId) =>
      _firestore.collection('artisans').doc(artisanId).collection('products');

  @override
  Stream<List<ProductPayload>> watchProducts(String artisanId) => _products(artisanId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((document) => ProductPayload.fromJson(<String, dynamic>{...document.data(), 'id': document.id})).toList(growable: false));

  @override
  Future<ProductPayload> publish({required String artisanId, required ProductPayload product}) async {
    final heroImage = await _uploadIfLocal(artisanId: artisanId, productId: product.id, path: product.heroImagePath, ordinal: 'hero');
    final additionalImages = <String>[];
    for (var index = 0; index < product.additionalImages.length; index++) {
      additionalImages.add(await _uploadIfLocal(artisanId: artisanId, productId: product.id, path: product.additionalImages[index], ordinal: 'gallery-$index'));
    }
    final remote = product.copyWith(heroImagePath: heroImage, additionalImages: additionalImages);
    await _products(artisanId).doc(remote.id).set(<String, Object?>{
      ...remote.toJson(),
      'artisanId': artisanId,
      'updatedAt': FieldValue.serverTimestamp(),
      'publishedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return remote;
  }

  Future<String> _uploadIfLocal({required String artisanId, required String productId, required String path, required String ordinal}) async {
    if (path.startsWith('http')) return path;
    final file = File(path);
    if (!await file.exists()) return path;
    final reference = _storage.ref('artisans/$artisanId/products/$productId/$ordinal.jpg');
    await reference.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return reference.getDownloadURL();
  }
}

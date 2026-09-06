import '../../models/product_payload.dart';

abstract class ProductRepository {
  Stream<List<ProductPayload>> watchProducts(String artisanId);
  Future<ProductPayload> publish({required String artisanId, required ProductPayload product});
}

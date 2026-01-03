/// * More info of StackItem
abstract class StackItemContent {
  const StackItemContent();

  /// * to json
  Map<String, dynamic> toJson();

  /// * Resize content based on scale factor
  /// * [scaleFactor] is the ratio of new size to old size (should be the same for width and height when aspect ratio is preserved)
  StackItemContent resize(double scaleFactor);
}

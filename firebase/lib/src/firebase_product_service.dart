import 'package:tekartik_firebase/firebase.dart';

/// Attached firebase service.
///
/// Init is called
abstract class FirebaseProductService {
  /// Called when [App.addService] is called
  Future<void> init(App app);

  /// Called when [App.delete] is called
  Future<void> close(App app);
}

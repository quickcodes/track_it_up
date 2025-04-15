import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';

class ObjectBox {
  /// The Store of this app.
  late Store store;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, "object-box-db");

    if (Store.isOpen(dbPath)) {
      final localStore = Store.attach(getObjectBoxModel(), dbPath);
      return ObjectBox._create(localStore);
    }

    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: dbPath);
    return ObjectBox._create(store);
  }
}

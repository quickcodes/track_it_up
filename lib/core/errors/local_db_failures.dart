import 'package:track_it_up/core/errors/failure.dart';

class LocalDBInsertFailure extends Failure {
  LocalDBInsertFailure({super.message = "Failed to insert data into local database."});
}

class LocalDBReadFailure extends Failure {
  LocalDBReadFailure({super.message = "Failed to read data from local database."});
}

class LocalDBUpdateFailure extends Failure {
  LocalDBUpdateFailure({super.message = "Failed to update data in local database."});
}

class LocalDBDeleteFailure extends Failure {
  LocalDBDeleteFailure({super.message = "Failed to delete data from local database."});
}

class LocalDBConnectionFailure extends Failure {
  LocalDBConnectionFailure({super.message = "Failed to connect to the local database."});
}

class UnknownLocalFailure extends Failure {
  UnknownLocalFailure({super.message = "An unknown local database error occurred."});
}

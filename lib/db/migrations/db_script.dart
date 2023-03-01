// lib\db\migrations\db_script.dart

import 'package:my_expenses/db/migrations/init_db.dart';

class DbMigrator {
  static final Map<int, String> migrations = {
    1: initDbScript,
    2: createExpenseDbScript,
  };
}

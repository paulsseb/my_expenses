// lib\db\migrations\init_db.dart

const String initDbScript = """
  CREATE TABLE Category (
      id INTEGER PRIMARY KEY,
      title TEXT,
      desc TEXT,
      iconCodePoint INTEGER
    );
  """;
const String createExpenseDbScript = """
  CREATE TABLE Expense (
      id INTEGER PRIMARY KEY,
      categoryId INTEGER, 
      title TEXT,
      notes TEXT,
      amount REAL,
      date TEXT
      );
    """;

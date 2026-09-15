// lib\db\migrations\init_db.dart

import 'package:flutter/material.dart';

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

final String seedDefaultCategoriesScript = """
  INSERT INTO Category (title, desc, iconCodePoint) VALUES
    ('Food & Dining', 'Meals, restaurants, and takeout', ${Icons.fastfood.codePoint}),
    ('Groceries', 'Supermarket and grocery shopping', ${Icons.local_grocery_store.codePoint}),
    ('Transport', 'Fuel, fares, and vehicle costs', ${Icons.directions_car.codePoint}),
    ('Shopping', 'Clothing and general purchases', ${Icons.shopping_bag.codePoint}),
    ('Bills & Utilities', 'Electricity, water, internet, and other bills', ${Icons.receipt_long.codePoint}),
    ('Rent', 'Housing and rent payments', ${Icons.home.codePoint}),
    ('Health', 'Medical care and pharmacy expenses', ${Icons.local_hospital.codePoint}),
    ('Education', 'Tuition, books, and courses', ${Icons.school.codePoint}),
    ('Entertainment', 'Movies, games, and outings', ${Icons.movie.codePoint}),
    ('Travel', 'Trips, flights, and accommodation', ${Icons.flight.codePoint}),
    ('Savings', 'Money set aside or invested', ${Icons.savings.codePoint}),
    ('Other', 'Anything that doesn''t fit elsewhere', ${Icons.category.codePoint});
""";

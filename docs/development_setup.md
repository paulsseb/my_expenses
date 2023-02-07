# Setting Up Development Environment

##### 1. Setup your flutter environment 
https://docs.flutter.dev/get-started/install

##### 2. Create the flutter project and try to run it as a basic project
```
> flutter create my_expenses
> cd my_expenses
> flutter pub get 
> flutter run
```
##### 3. After the basic, this project is into models,business logic(Block files), screens and an db (sql lite) 
NB: We auto generate the remaining part of these files after creating model files using the build runner command:.
built value type model has many benefits over reference type such as immutability and easy json serialization which Flutter has challenges with.

```> flutter packages pub run build_runner build```

##### 4. References
Flutter expense App tutorial
1. https://stacksecrets.com/flutter/flutter-tutorial-building-an-expense-manager-app-2    (Built value and runner usage)
2. https://stacksecrets.com/flutter/flutter-tutorial-building-an-expense-manager-app-in-flutter-1

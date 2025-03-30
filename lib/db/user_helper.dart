import 'dart:developer';

import 'package:pharm/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../db/model/user.dart';

class UserHelper {
  static final UserHelper _instance = UserHelper._internal();
  static UserHelper get instance => _instance;
  factory UserHelper() => _instance;
  UserHelper._internal();

  // Insert User
  Future<int> insertUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('user', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get a Single User by ID
  Future<User?> getUser(int id) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> result = await db.query('user', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Get All Users
  Future<List<User>> getAllUsers() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> result = await db.query('user');
    return result.map((map) => User.fromMap(map)).toList();
  }

  // Update User
  Future<int> updateUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update('user', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Delete User
  Future<int> deleteUser(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  // Get User by Username
  Future<User?> getUserByUsername(String username) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('user', where: 'username = ?', whereArgs: [username]);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // check the user name and password is correct
  Future<User?> checkUser(String username, String password) async {

    List<User>users= await getAllUsers();
    for(User user in users){
      log('User: ${user.username} ${user.password}');
    }
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('user', where: 'username = ? AND password = ?', whereArgs: [username, password]);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}

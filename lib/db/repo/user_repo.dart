import 'dart:developer';

import 'package:pharm/db/db_helper.dart';
import 'package:pharm/db/model/user.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  Future<int> addUser(User user) async {
    log('Adding user: $user');
    final db = await DatabaseHelper.database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByUserName(String username) async {
    final db = await DatabaseHelper.database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await DatabaseHelper.database;
    List<Map<String, dynamic>> result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await DatabaseHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await DatabaseHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

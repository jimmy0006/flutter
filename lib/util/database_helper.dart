import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/note_model.dart';

class DatabaseHelper{
  final String tableName = 'notes';
  final int _version = 1;
  static Database? _database;

  static final DatabaseHelper db = DatabaseHelper._internal();

  DatabaseHelper._internal();

  factory DatabaseHelper() =>db;

  Future<Database> get database async =>
      _database ??=await _initDB('note.db');

  Future<Database> _initDB(String filePath)async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,filePath);
    return await openDatabase(path, version:_version,onCreate: _createDB);
  }

  Future _createDB(Database database, int version)async{
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';

    await database.execute(
      '''
      CREATE TABLE $tableName (id $idType,title $textType,body $textType, createDate $textType)
      '''
    );
  }

  Future addNote(NoteModel note)async{
    final db = await database;

    db.insert(tableName, note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  }
  Future<List?> getAllNotes()async{
    final db = await database;

    final orderBy = 'id ASC';

    var maps = await db.query(tableName, orderBy: orderBy);

    if(maps.isEmpty){
      return null;
    }else{
      return maps;
    }
  }

  Future closeDB() async {
    final db = await database;
    db.close();
  }
}
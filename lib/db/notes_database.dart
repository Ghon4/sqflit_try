import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/note.dart';
import 'package:sqflit_try/utils/constants.dart';

class NotesDatabase {
  //INSTANCE OF THE DB
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  //INITIAL THE DB
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  //CREATING THE DATABASE PATH
  Future<Database> _initDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 1, onCreate: _oncreatDB);
  }

  //CREATING THE DATABASE IF IT IS NOT EXIST
  Future _oncreatDB(Database database, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await database.execute('''
    CREATE TABLE $tableNotes(
    ${NoteFields.id} $idType,
    ${NoteFields.isImportant} $boolType,
    ${NoteFields.number} $integerType,
    ${NoteFields.title} $textType,
    ${NoteFields.description} $textType,
    ${NoteFields.time} $textType,
    )
    ''');
  }

  //INSERT INTO THE DATABASE METHOD
  Future<Note> create(Note note) async {
    final db = await instance.database;
    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  //READ ONE  THING FROM THE DB
  Future<Note> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('The ID $id have not exist');
    }
  }

  //READING ALL THE DATA INSIDE THE DB
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    final orderby = '${NoteFields.time} Asc';
    final result = await db.query(tableNotes, orderBy: orderby);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  // UPDATING THE DB OBJECT
  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id}=?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableNotes,
      where: '${NoteFields.id}=?',
      whereArgs: [id],
    );
  }

  //CLOSE THE DATABASE
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

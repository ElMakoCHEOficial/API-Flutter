import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('familia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    await db.execute('''
      CREATE TABLE usuarios (
        id $idType,
        nombre $textType,
        apellido_materno $textType,
        apellido_paterno $textType,
        edad $integerType,
        tios TEXT,
        hermanos TEXT,
        padres TEXT,
        abuelos TEXT,
        estado_civil $textType,
        esposa TEXT
      )
    ''');
  }

  // Insertar usuario
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario.toMap());
  }

  // Obtener todos los usuarios
  Future<List<Usuario>> getAllUsuarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  // Actualizar usuario
  Future<int> updateUsuario(Usuario usuario) async {
    final db = await database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // Eliminar usuario
  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Limpiar toda la tabla
  Future<void> clearAllUsuarios() async {
    final db = await database;
    await db.delete('usuarios');
  }

  // Insertar múltiples usuarios
  Future<void> insertMultipleUsuarios(List<Usuario> usuarios) async {
    final db = await database;
    final batch = db.batch();
    
    for (var usuario in usuarios) {
      batch.insert('usuarios', usuario.toMap());
    }
    
    await batch.commit(noResult: true);
  }

  // Cerrar base de datos
  Future close() async {
    final db = await database;
    db.close();
  }
}
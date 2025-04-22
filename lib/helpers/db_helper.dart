import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cliente.dart';
import '../models/servico.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'cadastro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        telefone TEXT,
        endereco TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE servico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER,
        descricao TEXT,
        data TEXT,
        horas REAL,
        valor_unitario REAL,
        valor_total REAL,
        FOREIGN KEY (cliente_id) REFERENCES cliente(id)
      )
    ''');
  }

  // Cliente

  Future<int> inserirCliente(Cliente cliente) async {
    final db = await database;
    return await db.insert('cliente', cliente.toMap());
  }

  Future<List<Cliente>> getClientes() async {
    final db = await database;
    final maps = await db.query('cliente');
    return maps.map((map) => Cliente.fromMap(map)).toList();
  }

  Future<int> atualizarCliente(Cliente cliente) async {
    final db = await database;
    return await db.update(
      'cliente',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> deletarCliente(int id) async {
    final db = await database;
    return await db.delete(
      'cliente',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Serviço

  Future<int> inserirServico(Servico servico) async {
    final db = await database;
    return await db.insert('servico', servico.toMap());
  }

  Future<List<Servico>> getServicos() async {
    final db = await database;
    final maps = await db.query('servico');
    return maps.map((map) => Servico.fromMap(map)).toList();
  }

  Future<int> atualizarServico(Servico servico) async {
    final db = await database;
    return await db.update(
      'servico',
      servico.toMap(),
      where: 'id = ?',
      whereArgs: [servico.id],
    );
  }

  Future<int> deletarServico(int id) async {
    final db = await database;
    return await db.delete(
      'servico',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

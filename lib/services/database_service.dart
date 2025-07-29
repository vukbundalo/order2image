import 'dart:io';
import 'package:order2image/models/audit.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  late final DatabaseFactory databaseFactory = databaseFactoryFfi;
  Database? _db;

  /// Returns the initialized database, creating it if necessary.
  Future<Database> get db async {
    if (_db != null) return _db!;

    // Initialize FFI
    sqfliteFfiInit();

    // Prepare the database directory
    final dbDir = Directory(p.join(Directory.current.path, 'data', 'db'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final dbPath = p.join(dbDir.path, 'order2image.sqlite');

    // Open or create the database
    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: 1, onCreate: _createSchema),
    );
    return _db!;
  }

  /// Creates tables and seeds initial data.
  Future _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Patient (
        PatientID TEXT PRIMARY KEY,
        MRN TEXT,
        EncounterID TEXT,
        FirstName TEXT,
        LastName TEXT,
        DOB TEXT,
        Gender TEXT,
        Allergies TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE "Order" (
        OrderID TEXT PRIMARY KEY,
        PatientID TEXT,
        ProcedureCode TEXT,
        OrderDateTime TEXT,
        FOREIGN KEY(PatientID) REFERENCES Patient(PatientID)
      );
    ''');
    await db.execute('''
    CREATE TABLE Image (
  ImageID TEXT PRIMARY KEY,
  OrderID TEXT,
  PatientID TEXT,
  FilePath TEXT,
  StudyDate TEXT,
  Modality TEXT,
  FOREIGN KEY(PatientID) REFERENCES Patient(PatientID),
  FOREIGN KEY(OrderID) REFERENCES \"Order\"(OrderID)
);
    ''');
    await db.execute('''
      CREATE TABLE Audit (
        EventID INTEGER PRIMARY KEY AUTOINCREMENT,
        Time TEXT,
        EventType TEXT,
        RefID TEXT
      );
    ''');

    // Defining mock patient data
    await db.insert('Patient', {
      'PatientID': 'P1001',
      'MRN': '1001',
      'EncounterID': 'E2001',
      'FirstName': 'Alice',
      'LastName': 'Smith',
      'DOB': '1975-02-15',
      'Gender': 'F',
      'Allergies': 'Penicillin',
    });
    await db.insert('Patient', {
      'PatientID': 'P1002',
      'MRN': '1002',
      'EncounterID': 'E2002',
      'FirstName': 'Bob',
      'LastName': 'Jones',
      'DOB': '1982-07-30',
      'Gender': 'M',
      'Allergies': 'Iodine Contrast',
    });
    await db.insert('Patient', {
      'PatientID': 'P1003',
      'MRN': '1003',
      'EncounterID': 'E2003',
      'FirstName': 'Carol',
      'LastName': 'Lee',
      'DOB': '1990-11-05',
      'Gender': 'F',
      'Allergies': '',
    });
  }

  /// Retrieves all patients from the database.
  Future<List<Map<String, dynamic>>> getAllPatients() async {
    final database = await db;
    return database.query('Patient', orderBy: 'LastName, FirstName');
  }

  /// Closes the database.
  Future<void> close() async {
    await _db?.close();
  }

  Future<void> insertOrder({
    required String orderId,
    required String patientId,
    required String procedureCode,
    required String orderDateTime,
  }) async {
    final dbInstance = await db;
    await dbInstance.insert('Order', {
      'OrderID': orderId,
      'PatientID': patientId,
      'ProcedureCode': procedureCode,
      'OrderDateTime': orderDateTime,
    });
  }

  Future<void> logAudit(String eventType, String refId) async {
    final dbInstance = await db;
    await dbInstance.insert('Audit', {
      'Time': DateTime.now().toIso8601String(),
      'EventType': eventType,
      'RefID': refId,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    final dbInstance = await db;
    return dbInstance.rawQuery('''
 SELECT o.OrderID, o.PatientID, o.ProcedureCode, o.OrderDateTime,
       p.FirstName, p.LastName
FROM "Order" o
JOIN Patient p ON o.PatientID = p.PatientID
LEFT JOIN Image i ON o.OrderID = i.OrderID
WHERE i.ImageID IS NULL
ORDER BY o.OrderDateTime DESC

  ''');
  }

  Future<void> insertImage({
    required String imageId,
    required String orderId,
    required String patientId,
    required String filePath,
    required String studyDate,
    required String modality,
  }) async {
    final dbInstance = await db;
    await dbInstance.insert('Image', {
      'ImageID': imageId,
      'OrderID': orderId,
      'PatientID': patientId,
      'FilePath': filePath,
      'StudyDate': studyDate,
      'Modality': modality,
    });
  }

  Future<List<AuditEvent>> getAuditLog() async {
    final dbInstance = await db;
    final rows = await dbInstance.query(
      'Audit',
      orderBy: 'Time ASC',
      limit: 100,
    );
    return rows.map((row) => AuditEvent.fromMap(row)).toList();
  }
}

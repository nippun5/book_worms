import '../db_helper.dart';
import '../../models/loan_transaction.dart';

class LoanRepository {
  final _dbHelper = DBHelper.instance;

  Future<LoanTransaction> requestLoan(LoanTransaction loan) async {
    final db = await _dbHelper.database;
    final id = await db.insert('loans', loan.toMap()..remove('id'));
    return LoanTransaction(
      id: id,
      listingId: loan.listingId,
      bookId: loan.bookId,
      ownerUserId: loan.ownerUserId,
      borrowerUserId: loan.borrowerUserId,
      status: loan.status,
      requestedAt: loan.requestedAt,
      dueDate: loan.dueDate,
      returnedAt: loan.returnedAt,
    );
  }

  Future<LoanTransaction?> findById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('loans', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return LoanTransaction.fromMap(rows.first);
  }

  /// Books the user has borrowed (they are the borrower).
  Future<List<LoanTransaction>> getBorrowedBy(int userId) async {
    final db = await _dbHelper.database;
    final rows =
        await db.query('loans', where: 'borrowerUserId = ?', whereArgs: [userId], orderBy: 'requestedAt DESC');
    return rows.map(LoanTransaction.fromMap).toList();
  }

  /// Books the user has lent out (they are the owner).
  Future<List<LoanTransaction>> getLentBy(int userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('loans', where: 'ownerUserId = ?', whereArgs: [userId], orderBy: 'requestedAt DESC');
    return rows.map(LoanTransaction.fromMap).toList();
  }

  Future<bool> hasOpenRequest(int listingId, int borrowerUserId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'loans',
      where: "listingId = ? AND borrowerUserId = ? AND status IN ('requested','active')",
      whereArgs: [listingId, borrowerUserId],
    );
    return rows.isNotEmpty;
  }

  Future<int> countActive() async {
    final db = await _dbHelper.database;
    final r = await db.rawQuery("SELECT COUNT(*) AS c FROM loans WHERE status = 'active'");
    return (r.first['c'] as int?) ?? 0;
  }

  Future<void> updateStatus(int loanId, LoanStatus status, {DateTime? dueDate, DateTime? returnedAt}) async {
    final db = await _dbHelper.database;
    final values = <String, dynamic>{'status': status.name};
    if (dueDate != null) values['dueDate'] = dueDate.toIso8601String();
    if (returnedAt != null) values['returnedAt'] = returnedAt.toIso8601String();
    await db.update('loans', values, where: 'id = ?', whereArgs: [loanId]);
  }

  /// When the owner approves one request, every other pending request for the
  /// same listing is declined so the book is never double-lent.
  Future<void> declineOtherRequests(int listingId, int exceptLoanId) async {
    final db = await _dbHelper.database;
    await db.update(
      'loans',
      {'status': LoanStatus.declined.name},
      where: "listingId = ? AND id != ? AND status = 'requested'",
      whereArgs: [listingId, exceptLoanId],
    );
  }
}

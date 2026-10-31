import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../../models/loan_transaction.dart';

class LoanRepository {
  String get _base => '${ApiConfig.baseUrl}/loans';

  Future<LoanTransaction> requestLoan(LoanTransaction loan) async {
    final payload = loan.toMap()..remove('id');
    final res = await http.post(
      Uri.parse(_base),
      headers: ApiConfig.headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return LoanTransaction.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to request loan: ${res.statusCode}${res.body}');
  }

  Future<LoanTransaction?> findById(int id) async {
    final res = await http.get(Uri.parse('$_base/$id'), headers: ApiConfig.headers);
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return LoanTransaction.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<LoanTransaction>> _fetchAllLoans() async {
    final res = await http.get(Uri.parse(_base), headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      return list.map((e) => LoanTransaction.fromMap(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<LoanTransaction>> getBorrowedBy(int userId) async {
    final uri = Uri.parse(_base).replace(queryParameters: {'borrowerUserId': '$userId'});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final loans = list
          .map((e) => LoanTransaction.fromMap(e as Map<String, dynamic>))
          .where((l) => l.borrowerUserId == userId)
          .toList();
      loans.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return loans;
    }
    return [];
  }

  Future<List<LoanTransaction>> getLentBy(int userId) async {
    final uri = Uri.parse(_base).replace(queryParameters: {'ownerUserId': '$userId'});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final loans = list
          .map((e) => LoanTransaction.fromMap(e as Map<String, dynamic>))
          .where((l) => l.ownerUserId == userId)
          .toList();
      loans.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return loans;
    }
    return [];
  }

  Future<bool> hasOpenRequest(int listingId, int borrowerUserId) async {
    final borrowed = await getBorrowedBy(borrowerUserId);
    return borrowed.any((l) =>
        l.listingId == listingId &&
        (l.status == LoanStatus.requested || l.status == LoanStatus.active));
  }

  Future<int> countActive() async {
    final all = await _fetchAllLoans();
    return all.where((l) => l.status == LoanStatus.active).length;
  }

  Future<void> updateStatus(int loanId, LoanStatus status,
      {DateTime? dueDate, DateTime? returnedAt}) async {
    final body = <String, dynamic>{'status': status.name};
    if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();
    if (returnedAt != null) body['returnedAt'] = returnedAt.toIso8601String();

    final patchRes = await http.patch(
      Uri.parse('$_base/$loanId/status'),
      headers: ApiConfig.headers,
      body: jsonEncode(body),
    );
    if (patchRes.statusCode == 200 || patchRes.statusCode == 204) return;

    final existing = await findById(loanId);
    if (existing != null) {
      final updated = existing.copyWith(
        status: status,
        dueDate: dueDate,
        returnedAt: returnedAt,
      );
      await http.put(
        Uri.parse('$_base/$loanId'),
        headers: ApiConfig.headers,
        body: jsonEncode(updated.toMap()),
      );
    }
  }

  Future<void> declineOtherRequests(int listingId, int exceptLoanId) async {
    final all = await _fetchAllLoans();
    final others = all.where((l) =>
        l.listingId == listingId &&
        l.id != exceptLoanId &&
        l.status == LoanStatus.requested);
    for (final loan in others) {
      if (loan.id != null) {
        await updateStatus(loan.id!, LoanStatus.declined);
      }
    }
  }
}
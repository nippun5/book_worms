enum LoanStatus { requested, declined, active, returned }

LoanStatus loanStatusFromString(String v) =>
    LoanStatus.values.firstWhere((e) => e.name == v, orElse: () => LoanStatus.requested);

extension LoanStatusLabel on LoanStatus {
  String get label {
    switch (this) {
      case LoanStatus.requested:
        return 'Requested';
      case LoanStatus.declined:
        return 'Declined';
      case LoanStatus.active:
        return 'On Loan';
      case LoanStatus.returned:
        return 'Returned';
    }
  }
}

class LoanTransaction {
  final int? id;
  final int listingId;
  final int bookId;
  final int ownerUserId; // the lender
  final int borrowerUserId; // the requester
  final LoanStatus status;
  final DateTime requestedAt;
  final DateTime? dueDate;
  final DateTime? returnedAt;

  LoanTransaction({
    this.id,
    required this.listingId,
    required this.bookId,
    required this.ownerUserId,
    required this.borrowerUserId,
    this.status = LoanStatus.requested,
    DateTime? requestedAt,
    this.dueDate,
    this.returnedAt,
  }) : requestedAt = requestedAt ?? DateTime.now();

  LoanTransaction copyWith({LoanStatus? status, DateTime? dueDate, DateTime? returnedAt}) {
    return LoanTransaction(
      id: id,
      listingId: listingId,
      bookId: bookId,
      ownerUserId: ownerUserId,
      borrowerUserId: borrowerUserId,
      status: status ?? this.status,
      requestedAt: requestedAt,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'bookId': bookId,
      'ownerUserId': ownerUserId,
      'borrowerUserId': borrowerUserId,
      'status': status.name,
      'requestedAt': requestedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'returnedAt': returnedAt?.toIso8601String(),
    };
  }

  factory LoanTransaction.fromMap(Map<String, dynamic> map) {
    return LoanTransaction(
      id: map['id'] as int?,
      listingId: map['listingId'] as int,
      bookId: map['bookId'] as int,
      ownerUserId: map['ownerUserId'] as int,
      borrowerUserId: map['borrowerUserId'] as int,
      status: loanStatusFromString(map['status'] as String),
      requestedAt: DateTime.parse(map['requestedAt'] as String),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      returnedAt: map['returnedAt'] != null ? DateTime.parse(map['returnedAt'] as String) : null,
    );
  }
}

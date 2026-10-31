enum ListingType { sale, loan }

enum ListingCondition { likeNew, good, fair }

enum ListingStatus { available, pending, unavailable }

ListingType listingTypeFromString(String v) =>
    ListingType.values.firstWhere((e) => e.name == v, orElse: () => ListingType.loan);

ListingCondition listingConditionFromString(String v) => ListingCondition.values
    .firstWhere((e) => e.name == v, orElse: () => ListingCondition.good);

ListingStatus listingStatusFromString(String v) => ListingStatus.values
    .firstWhere((e) => e.name == v, orElse: () => ListingStatus.available);

extension ListingConditionLabel on ListingCondition {
  String get label {
    switch (this) {
      case ListingCondition.likeNew:
        return 'Like New';
      case ListingCondition.good:
        return 'Good';
      case ListingCondition.fair:
        return 'Fair';
    }
  }
}

class BookListing {
  final int? id;
  final int bookId;
  final int ownerUserId;
  final ListingType type;
  final double? price; // null when type == loan
  final ListingCondition condition;
  final ListingStatus status;
  final String note;
  final DateTime createdAt;

  BookListing({
    this.id,
    required this.bookId,
    required this.ownerUserId,
    required this.type,
    this.price,
    this.condition = ListingCondition.good,
    this.status = ListingStatus.available,
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  BookListing copyWith({ListingStatus? status}) {
    return BookListing(
      id: id,
      bookId: bookId,
      ownerUserId: ownerUserId,
      type: type,
      price: price,
      condition: condition,
      status: status ?? this.status,
      note: note,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'ownerUserId': ownerUserId,
      'type': type.name.toUpperCase(),
      'price': price,
      'condition': condition.name,
      'status': status.name,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookListing.fromMap(Map<String, dynamic> map) {
    return BookListing(
      id: map['id'] as int?,
      bookId: map['bookId'] as int,
      ownerUserId: map['ownerUserId'] as int,
      type: ListingType.values.firstWhere(
  (e) => e.name.toUpperCase() == (map['type'] as String).toUpperCase()),
      price: (map['price'] as num?)?.toDouble(),
      condition: listingConditionFromString(map['condition'] as String),
      status: listingStatusFromString(map['status'] as String),
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

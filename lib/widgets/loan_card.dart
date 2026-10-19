import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/format.dart';
import '../models/loan_transaction.dart';
import '../models/views.dart';
import 'book_cover.dart';
import 'common.dart';

/// One row on the My Loans screen. [asLender] decides which counterpart is
/// shown and which actions are offered.
class LoanCard extends StatelessWidget {
  final LoanView view;
  final bool asLender;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final VoidCallback? onReturned;
  final VoidCallback? onTap;

  const LoanCard({
    super.key,
    required this.view,
    required this.asLender,
    this.onApprove,
    this.onDecline,
    this.onReturned,
    this.onTap,
  });

  Color _statusColor(LoanStatus s) {
    switch (s) {
      case LoanStatus.requested:
        return AppColors.gold;
      case LoanStatus.active:
        return AppColors.green;
      case LoanStatus.returned:
        return AppColors.brown300;
      case LoanStatus.declined:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = view.loan;
    final textTheme = Theme.of(context).textTheme;
    final counterpart = asLender ? view.borrower.name : view.owner.name;
    final overdue = l.status == LoanStatus.active && l.dueDate != null && l.dueDate!.isBefore(DateTime.now());

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(book: view.book, width: 54, height: 76, radius: 8),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(view.book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(fontSize: 16)),
                        Text('by ${view.book.author}', style: textTheme.bodySmall),
                        const SizedBox(height: 6),
                        Text(asLender ? 'Lent to $counterpart' : 'From $counterpart', style: textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        PillLabel(
                          text: l.status == LoanStatus.active && overdue ? 'Overdue' : l.status.label,
                          background: overdue ? AppColors.red : _statusColor(l.status),
                          foreground: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (l.status == LoanStatus.active && l.dueDate != null)
                Text('Due ${formatDate(l.dueDate!)}',
                    style: textTheme.bodySmall?.copyWith(color: overdue ? AppColors.red : AppColors.grayText))
              else if (l.status == LoanStatus.returned && l.returnedAt != null)
                Text('Returned ${formatDate(l.returnedAt!)}', style: textTheme.bodySmall)
              else if (l.status == LoanStatus.requested)
                Text(asLender ? 'Requested ${timeAgo(l.requestedAt)}' : 'Waiting for the owner to respond',
                    style: textTheme.bodySmall),
              if (asLender && l.status == LoanStatus.requested) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: onDecline, child: const Text('Decline'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: onApprove, child: const Text('Approve'))),
                  ],
                ),
              ],
              if (asLender && l.status == LoanStatus.active) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: onReturned, child: const Text('Mark as returned')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

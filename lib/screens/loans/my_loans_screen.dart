import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/views.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/loan_card.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final me = context.read<AuthProvider>().user;
      if (me != null) context.read<LoanProvider>().load(me);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    final loans = context.watch<LoanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Borrowed'),
            Tab(text: loans.pendingRequestsForMe > 0 ? 'Lent (${loans.pendingRequestsForMe})' : 'Lent'),
          ],
        ),
      ),
      body: me == null
          ? const SizedBox.shrink()
          : loans.loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _LoanList(
                      items: loans.borrowed,
                      asLender: false,
                      emptyTitle: 'Nothing borrowed yet',
                      emptyMessage: 'Books you request to borrow will show up here.',
                      onApprove: null,
                      onDecline: null,
                      onReturned: null,
                    ),
                    _LoanList(
                      items: loans.lent,
                      asLender: true,
                      emptyTitle: 'Nothing lent out yet',
                      emptyMessage: 'List a book for loan and requests will show up here.',
                      onApprove: (v) => loans.approve(me, v),
                      onDecline: (v) => loans.decline(me, v),
                      onReturned: (v) => loans.markReturned(me, v),
                    ),
                  ],
                ),
    );
  }
}

class _LoanList extends StatelessWidget {
  final List<LoanView> items;
  final bool asLender;
  final String emptyTitle;
  final String emptyMessage;
  final void Function(LoanView)? onApprove;
  final void Function(LoanView)? onDecline;
  final void Function(LoanView)? onReturned;

  const _LoanList({
    required this.items,
    required this.asLender,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onApprove,
    required this.onDecline,
    required this.onReturned,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(icon: Icons.swap_horiz_rounded, title: emptyTitle, message: emptyMessage);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final view = items[i];
        return LoanCard(
          view: view,
          asLender: asLender,
          onApprove: onApprove == null ? null : () => onApprove!(view),
          onDecline: onDecline == null
              ? null
              : () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Decline this request?',
                    message: '${view.borrower.name} will be notified their request was declined.',
                    confirmLabel: 'Decline',
                    destructive: true,
                  );
                  if (ok) onDecline!(view);
                },
          onReturned: onReturned == null
              ? null
              : () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Mark as returned?',
                    message: 'This makes the book available to lend again.',
                    confirmLabel: 'Confirm',
                  );
                  if (ok) onReturned!(view);
                },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/point_transaction_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PointTransactionHistoryPage extends StatefulWidget {
  const PointTransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<PointTransactionHistoryPage> createState() =>
      _PointTransactionHistoryPageState();
}

class _PointTransactionHistoryPageState
    extends State<PointTransactionHistoryPage> {
  final PointTransactionService _transactionService = PointTransactionService();
  TransactionFilter _currentFilter = TransactionFilter.all;
  bool _isLoading = false;
  List<Map<String, dynamic>> _transactions = [];

  DateTime _getDateFromTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime(2000, 1, 1);
    }
    return (timestamp as Timestamp).toDate();
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final user = context.read<AppAuthProvider>().user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> transactions;

      switch (_currentFilter) {
        case TransactionFilter.all:
          transactions = await _transactionService.getUserTransactionHistory(
            user.uid,
            includeAllStatuses: false,
          );
          break;
        case TransactionFilter.credit:
          transactions = await _transactionService.getUserTransactionHistory(
            user.uid,
            type: PointTransactionType.purchase,
            includeAllStatuses: false,
          );
          final rewards = await _transactionService.getUserTransactionHistory(
            user.uid,
            type: PointTransactionType.reward,
            includeAllStatuses: false,
          );
          transactions.addAll(rewards);
          transactions.sort((a, b) {
            final aTime = _getDateFromTimestamp(a['completedAt']);
            final bTime = _getDateFromTimestamp(b['completedAt']);
            return bTime.compareTo(aTime);
          });
          break;
        case TransactionFilter.debit:
          transactions = await _transactionService.getUserTransactionHistory(
            user.uid,
            type: PointTransactionType.usage,
            includeAllStatuses: false,
          );
          break;
      }

      transactions.sort((a, b) {
        final aTime = _getDateFromTimestamp(a['completedAt']);
        final bTime = _getDateFromTimestamp(b['completedAt']);
        return bTime.compareTo(aTime);
      });

      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('거래 내역을 불러오는 중 오류가 발생했습니다: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 768 ? 768.0 : screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 내역'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: contentWidth,
            margin: EdgeInsets.symmetric(
              horizontal: (screenWidth - contentWidth) / 2,
              vertical: 16,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SegmentedButton<TransactionFilter>(
                  selected: {_currentFilter},
                  onSelectionChanged: (Set<TransactionFilter> selected) {
                    setState(() {
                      _currentFilter = selected.first;
                      _loadTransactions();
                    });
                  },
                  segments: const [
                    ButtonSegment(
                      value: TransactionFilter.all,
                      label: Text('전체'),
                    ),
                    ButtonSegment(
                      value: TransactionFilter.credit,
                      label: Text('적립'),
                    ),
                    ButtonSegment(
                      value: TransactionFilter.debit,
                      label: Text('사용'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(
                        child: Text(
                          '거래 내역이 없습니다',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: (screenWidth - contentWidth) / 2,
                        ),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          final previousDate = index > 0
                              ? DateFormat('yyyy-MM-dd').format(
                                  _getDateFromTimestamp(
                                      _transactions[index - 1]['completedAt']))
                              : '';
                          final currentDate = DateFormat('yyyy-MM-dd').format(
                              _getDateFromTimestamp(
                                  transaction['completedAt']));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentDate != previousDate)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text(
                                    currentDate,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              TransactionCard(transaction: transaction),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

enum TransactionFilter {
  all,
  credit,
  debit,
}

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  DateTime _getDateFromTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime(2000, 1, 1);
    }
    return (timestamp as Timestamp).toDate();
  }

  @override
  Widget build(BuildContext context) {
    final type = PointTransactionType.values.firstWhere(
      (e) => e.toString() == transaction['type'],
    );

    final isCredit = type == PointTransactionType.purchase ||
        type == PointTransactionType.reward;

    final completedAt = _getDateFromTimestamp(transaction['completedAt']);
    final time = DateFormat('HH:mm').format(completedAt);
    final points = transaction['points'] as int;
    final metadata = transaction['metadata'] as Map<String, dynamic>?;

    String getTransactionTitle() {
      switch (type) {
        case PointTransactionType.purchase:
          return '포인트 구매';
        case PointTransactionType.reward:
          return '포인트 적립';
        case PointTransactionType.usage:
          return metadata?['problemSetTitle'] != null
              ? '문제 구매: ${metadata!['problemSetTitle']}'
              : '포인트 사용';
        default:
          return '기타';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCredit
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
              ),
              child: Icon(
                isCredit ? Icons.arrow_forward : Icons.arrow_back,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTransactionTitle(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (metadata?['price'] != null)
                    Text(
                      '${NumberFormat('#,###').format(metadata!['price'])}원',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${points.abs()}P',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

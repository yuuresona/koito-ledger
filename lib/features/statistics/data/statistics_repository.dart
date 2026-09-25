import '../../../core/time/year_month.dart';
import '../../transactions/data/transaction_repository.dart';
import '../domain/monthly_statistics.dart';

class StatisticsRepository {
  const StatisticsRepository(this._transactions);

  final TransactionRepository _transactions;

  Stream<MonthlyStatistics> watchMonth(YearMonth month) {
    return _transactions
        .watchMonth(month)
        .map(MonthlyStatistics.fromTransactions);
  }
}

import 'accountability_scope.dart';

enum AccountabilityDataStatus {
  available,
  empty,
  unavailable,
}

class AccountabilitySummaryItem {
  const AccountabilitySummaryItem({
    required this.scope,
    required this.status,
    required this.summary,
    this.details = const <String>[],
  });

  final AccountabilityScope scope;
  final AccountabilityDataStatus status;
  final String summary;
  final List<String> details;

  factory AccountabilitySummaryItem.empty(
    AccountabilityScope scope,
    String message,
  ) {
    return AccountabilitySummaryItem(
      scope: scope,
      status: AccountabilityDataStatus.empty,
      summary: message,
    );
  }

  factory AccountabilitySummaryItem.unavailable(
    AccountabilityScope scope,
  ) {
    return AccountabilitySummaryItem(
      scope: scope,
      status: AccountabilityDataStatus.unavailable,
      summary:
          'This shared area is temporarily unavailable right now.',
    );
  }
}

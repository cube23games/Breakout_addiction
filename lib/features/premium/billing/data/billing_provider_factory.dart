import '../../../../app/config/qa_billing_gate.dart';
import 'billing_provider.dart';
import 'play_billing_provider.dart';
import 'qa_billing_provider.dart';

class BillingProviderFactory {
  const BillingProviderFactory._();

  static BillingProvider create() {
    if (QaBillingGate.enabled) {
      return QaBillingProvider();
    }
    return PlayBillingProvider();
  }
}

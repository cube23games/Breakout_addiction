import '../../quotes/data/quote_preferences_repository.dart';
import '../../support/data/support_contact_repository.dart';
import '../../support/domain/support_contact.dart';
import '../domain/onboarding_state.dart';
import 'onboarding_repository.dart';

class OnboardingCompletionService {
  final OnboardingRepository _onboardingRepository =
      OnboardingRepository();
  final QuotePreferencesRepository _quotePreferences =
      QuotePreferencesRepository();
  final SupportContactRepository _contactRepository =
      SupportContactRepository();

  Future<void> complete(OnboardingState state) async {
    await _onboardingRepository.saveState(state);
    await _quotePreferences.saveMode(state.quoteMode);
    await _quotePreferences.saveReligionTag(
      state.religionPreference,
    );

    final contact = SupportContact(
      name: state.trustedContactName,
      phone: state.trustedContactPhone,
    );

    if (contact.isValid) {
      await _contactRepository.saveContact(contact);
    }
  }
}

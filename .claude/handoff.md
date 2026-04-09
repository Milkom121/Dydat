STATUS: CONTINUE
PHASE: 10
BLOCK: B39.9.2
SUMMARY: B39.9.2 completato. Integrato OnboardingPendingBanner in HomeScreen condizionale su onboarding_stato. Aggiunto campo onboardingStato al modello Utente Dart.
NEXT: B39.9.3 - Logica Riprendi con stato preservato
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: frontend/lib/models/utente.dart, frontend/lib/models/utente.g.dart, frontend/lib/presentation/home_screen/home_screen.dart, frontend/test/widgets/b39_9_2_banner_home_test.dart (nuovo), frontend/test/widgets/b35_7_pull_to_refresh_test.dart (fix override)
TESTS: PASS (712 frontend verdi, analyze 0)
VERIFICATION: 712 passed, 0 errori analyze. 9 nuovi test tutti verdi. 0 regressioni.

---

## Contesto dettagliato

### Cosa e stato fatto (B39.9.2)
- 15/38 sub-blocchi B39 completati totali
- Aggiunto onboardingStato al modello Utente (String, default not_started, JsonKey onboarding_stato)
- HomeScreen: watch userProvider, banner condizionale tra WelcomeHeader e bottone CTA
- Tap su banner naviga a /onboarding via context.push
- Fix test b35_7 (aggiunto userProvider override)
- 9 nuovi test (5 widget + 4 modello)

### Prossimo: B39.9.3
- Logica Riprendi con stato preservato
- Tap su Riprendi riapre /onboarding con conversazione precedente intatta
- Backend deve supportare retrieval sessione onboarding esistente
- File da toccare: onboarding_provider.dart, onboarding_screen.dart, backend /onboarding/inizia

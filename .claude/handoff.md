STATUS: CONTINUE
PHASE: 9
BLOCK: B36
SUMMARY: Aggiunge un'impostazione utente per scalare la dimensione dei font dell'app indipendentemente dal TextScaler di sistema. Provider Riverpod con persistenza, sezione Aspetto in Profilo, helper LaTeX coordinato. Branch dedicato wip/B36-font-scale.
NEXT: Test manuale Villa, poi merge wip/B36-font-scale → develop
DECISIONS_NEEDED: nessuna — Villa ha approvato struttura. Lavorare in autonomia.
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (580 frontend verdi, 363 backend verdi, flutter analyze 0)
VERIFICATION: baseline verde post merge wip/notte→develop

---

## ⚠️ ISTRUZIONI CRITICHE PER IL RUNNER

### Branch dedicato
Stai lavorando sul branch **`wip/B36-font-scale`**, NON su `develop`. Prosegui qui. NON fare checkout, NON fare merge verso develop. Dopo la fine del blocco, Villa fa il merge manualmente.

### Singolo blocco
B36 e UN SOLO blocco. Quando hai finito setta `STATUS: PHASE_COMPLETE` e fermati. NON avanzare ad altri blocchi.

---

# B36 — Impostazione dimensione font in-app

## Contesto
Dopo B35.13 l'app rispetta gia il TextScaler di sistema operativo. Tuttavia molti utenti non sanno che esiste o vorrebbero scalare solo Dydat indipendentemente dal sistema. Villa ha richiesto un'impostazione interna scopribile e granulare.

L'impostazione e **complementare** allo scaling di sistema: un utente puo usare entrambi (es. sistema 1.2 + Dydat 1.1 = effetto combinato), oppure solo uno dei due.

## Decisioni gia prese da Villa
- Provider Riverpod con persistenza in SharedPreferences
- 4 opzioni discrete: **Piccolo (0.85)**, **Normale (1.0)**, **Grande (1.15)**, **Molto grande (1.3)**
- Posizionamento: nuova sezione "Aspetto" nelle impostazioni del Profilo (in cima, prima di "Account")
- Helper per coordinare anche le formule LaTeX (`flutter_math_fork` non rispetta TextScaler nativo)

## File da toccare

### 1. Nuovo provider
**`frontend/lib/providers/font_scale_provider.dart`** (NUOVO)

Provider Riverpod (`StateNotifierProvider`) che gestisce la scelta dell'utente. Persistenza in `SharedPreferences` (chiave `font_scale_factor`, valore double 0.85/1.0/1.15/1.3, default 1.0).

Definire enum:
```dart
enum FontScaleOption {
  piccolo(0.85, 'Piccolo'),
  normale(1.0, 'Normale'),
  grande(1.15, 'Grande'),
  moltoGrande(1.3, 'Molto grande');

  final double factor;
  final String label;
  const FontScaleOption(this.factor, this.label);
}
```

Notifier deve:
- Caricare il valore salvato all'init
- Esporre `setOption(FontScaleOption)` che salva e aggiorna lo stato
- Esporre uno stato di tipo `FontScaleOption` (non `double`, per chiarezza UI)

### 2. Wrapper MediaQuery
**`frontend/lib/main.dart`** (modifica)

Wrappare MaterialApp con un Consumer che legge `fontScaleProvider` e applica un `MediaQuery` custom che modifica il `textScaler`. Pattern:

```dart
final fontScale = ref.watch(fontScaleProvider).factor;
return MaterialApp(
  // ...
  builder: (context, child) {
    final mq = MediaQuery.of(context);
    final newScaler = TextScaler.linear(
      mq.textScaler.scale(1.0) * fontScale,
    );
    return MediaQuery(
      data: mq.copyWith(textScaler: newScaler),
      child: child!,
    );
  },
);
```

**Importante**: il `* fontScale` moltiplica lo scaler di sistema per il fattore Dydat. NON sostituire (eliminerebbe l'effetto di B35.13).

### 3. Helper per LaTeX
**`frontend/lib/utils/latex_font_size.dart`** (NUOVO)

Funzione helper che ritorna il fontSize corretto per i widget Math.tex, applicando il fattore di scala del provider:

```dart
double scaledLatexFontSize(WidgetRef ref, double baseFontSize) {
  final scale = ref.watch(fontScaleProvider).factor;
  return baseFontSize * scale;
}
```

Aggiornare `formula_curriculum_card.dart` ed `esempio_inline_card.dart` per usare questo helper invece di valori hardcoded:
- `FormulaCurriculumCard`: era `fontSize: 18.0` → diventa `scaledLatexFontSize(ref, 18.0)`
- `EsempioInlineCard`: era `fontSize: theme.textTheme.bodyMedium?.fontSize ?? 14.0` → diventa `scaledLatexFontSize(ref, baseFontSize)`

**Nota**: questo richiede di trasformare i widget da `StatelessWidget` a `ConsumerWidget` se non lo sono gia. Verificare e adattare.

### 4. UI nel Profilo
**`frontend/lib/presentation/profile_screen/profile_screen.dart`** (modifica)

Aggiungere una nuova sezione "Aspetto" in cima alle impostazioni (prima di Account). La sezione deve contenere:

- Titolo: **Aspetto**
- Sottotitolo: **Dimensione testo**
- 4 chip/pulsanti orizzontali (Piccolo, Normale, Grande, Molto grande) con la selezione corrente evidenziata
- Sotto, una **anteprima live**: una `Card` con un esempio testuale che si scala in tempo reale al cambio di selezione. Esempio:
  > "Anteprima: il tutor ti accoglie con calore e ti spiega i concetti passo passo."
- Helper text: "L'impostazione si combina con la dimensione testo del sistema operativo."

Tap su un pulsante chiama `ref.read(fontScaleProvider.notifier).setOption(...)` e il MediaQuery custom propaga il cambiamento ovunque.

### 5. Test obbligatori (almeno 6)

**`frontend/test/providers/font_scale_provider_test.dart`** (NUOVO):
1. Default e `FontScaleOption.normale` (factor 1.0)
2. `setOption(grande)` aggiorna lo stato a grande
3. `setOption(...)` persiste in SharedPreferences (mock)
4. Stato caricato dal provider corrisponde al valore precedentemente salvato

**`frontend/test/widgets/b36_font_scale_test.dart`** (NUOVO):
5. UI Profilo mostra le 4 opzioni
6. Tap su "Grande" cambia la selezione visualmente
7. (bonus) Anteprima live mostra dimensione testo aumentata dopo tap

## Gate di uscita B36

1. Provider creato e funzionante con persistenza
2. Wrapper MediaQuery applicato in main.dart
3. Helper LaTeX creato e applicato a FormulaCurriculumCard + EsempioInlineCard
4. Sezione Aspetto in Profilo con 4 opzioni e anteprima live
5. 6+ test verdi (4 unit + 2 widget)
6. **TUTTI i test esistenti continuano a passare** (580+ frontend, 363 backend)
7. `flutter analyze` 0 errori
8. Commit atomico unico "B36 — Impostazione dimensione font in-app"
9. Aggiorna ROADMAP.md aggiungendo B36 come completato sotto Fase 9 (oppure crea sezione dedicata se preferisci)
10. Setta `STATUS: PHASE_COMPLETE` e fermati

## NON fare in B36

- Non toccare il backend (impostazione 100% client-side)
- Non aggiungere altre opzioni di tema (no dark/light mode toggle, no font family — solo dimensione)
- Non modificare il TextScaler di sistema o sovrascriverlo (deve combinarsi)
- Non aggiungere dipendenze pesanti (SharedPreferences gia in pubspec)
- Non rifattorare schermate fuori scope (solo profile_screen)
- Non avanzare ad altri blocchi dopo B36
- Non fare merge verso develop (Villa lo fa manualmente)

## File da leggere a inizio sessione

1. `CLAUDE.md`
2. `PROJECT_CONFIG.md`
3. `.claude/handoff.md` (questo)
4. `frontend/lib/main.dart` (per il punto di wrapping del MediaQuery)
5. `frontend/lib/presentation/profile_screen/profile_screen.dart` (per la struttura attuale)
6. `frontend/lib/presentation/quaderno_screen/widgets/formula_curriculum_card.dart` (per il fix LaTeX)
7. `frontend/lib/presentation/quaderno_screen/widgets/esempio_inline_card.dart` (per il fix LaTeX)
8. `frontend/lib/providers/` (per pattern Riverpod esistenti)
9. `frontend/pubspec.yaml` (verifica che `shared_preferences` sia gia disponibile)

## Stato baseline
- Frontend: 580 test verdi, analyze 0
- Backend: 363 test verdi
- Branch: `wip/B36-font-scale` (creato da develop al commit `88bd525`)

## NON fare (riepilogo finale)
- Non toccare il backend
- Non avanzare oltre B36
- Non mergiare verso develop
- Non rifattorare codice fuori scope
- Non aggiungere altre features di tema

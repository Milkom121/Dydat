#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

MAX_BLOCKS=10; TIMEOUT_MINUTES=30; PROJECT_DIR="$(pwd)"; DRY_RUN=false; VERBOSE=false; NOTIFY=true; RESUME=false; TARGET_PHASE=""; TEST_TELEGRAM=false
CLAUDE_MD="CLAUDE.md"; PROJECT_CONFIG="PROJECT_CONFIG.md"; ROADMAP="ROADMAP.md"; PROGRESS_FILE="docs/progress.json"
HANDOFF_FILE=".claude/handoff.md"; SESSION_LOG="docs/session-log.md"; RUNNER_LOG="docs/runner-log.txt"

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift;; --max-blocks) MAX_BLOCKS="$2"; shift 2;; --phase) TARGET_PHASE="$2"; shift 2;;
        --timeout) TIMEOUT_MINUTES="$2"; shift 2;; --project) PROJECT_DIR="$2"; shift 2;; --verbose) VERBOSE=true; shift;;
        --no-notify) NOTIFY=false; shift;; --resume) RESUME=true; shift;;
        --test-telegram) TEST_TELEGRAM=true; shift;;
        -h|--help) echo "Uso: ./metodo-villa-runner.sh [--dry-run] [--max-blocks N] [--phase N] [--timeout N] [--verbose] [--resume] [--test-telegram]"; exit 0;;
        *) echo -e "${RED}Opzione sconosciuta: $1${NC}"; exit 1;;
    esac
done
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))

# Carica variabili da .env.runner se esiste (token Telegram, etc.)
[[ -f "$PROJECT_DIR/.env.runner" ]] && source "$PROJECT_DIR/.env.runner"

log() { local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"; echo -e "${CYAN}[$ts]${NC} $1"; echo "[$ts] $(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g')" >> "$PROJECT_DIR/$RUNNER_LOG"; }
log_verbose() { $VERBOSE && log "$1" || true; }
die() { log "${RED}ERRORE FATALE: $1${NC}"; send_notification "Metodo Villa - Errore" "$1"; exit 1; }

# Telegram — configura token e chat_id per ricevere notifiche sul telefono
# Crea un bot con @BotFather, avvialo, e inserisci i dati in .env.runner
# (NON mettere credenziali in chiaro in file tracciati da git)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

send_telegram() {
    [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]] && return 0
    local msg="$1"
    local silent="${2:-false}"  # se "true" la notifica arriva senza suono/vibrazione
    # Passa tutto via variabili d'ambiente per evitare problemi di escape:
    # - backslash Windows nei percorsi (es. \.claude\handoff.md) rompe le stringhe Python inline
    # - apici, triple-quote e caratteri speciali nei messaggi rompono l'interpolazione bash->Python
    # - true/false bash != True/False Python (NameError silenzioso)
    # Le env vars passano i valori raw senza interpretazione.
    TG_TOKEN="$TELEGRAM_BOT_TOKEN" \
    TG_CHAT="$TELEGRAM_CHAT_ID" \
    TG_MSG="$msg" \
    TG_SILENT="$silent" \
    python -c "
import json, os, sys, urllib.request
try:
    data = json.dumps({
        'chat_id': os.environ['TG_CHAT'],
        'text': os.environ['TG_MSG'],
        'disable_notification': os.environ.get('TG_SILENT', 'false').lower() == 'true',
    }).encode('utf-8')
    req = urllib.request.Request(
        'https://api.telegram.org/bot' + os.environ['TG_TOKEN'] + '/sendMessage',
        data=data,
        headers={'Content-Type': 'application/json; charset=utf-8'},
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        print('TG OK status=' + str(resp.status))
except Exception as e:
    print('TG ERR ' + type(e).__name__ + ': ' + str(e)[:300], file=sys.stderr)
    sys.exit(1)
" >> "$PROJECT_DIR/$RUNNER_LOG" 2>&1 || log_verbose "send_telegram: chiamata fallita (vedi runner-log.txt)"
}

# Formatta un numero di minuti in "Xmin" oppure "Xh Ymin" se >= 60.
format_minutes() {
    local m="${1:-0}"
    if [[ $m -lt 60 ]]; then
        echo "${m}min"
    else
        local h=$((m / 60))
        local r=$((m % 60))
        echo "${h}h ${r}min"
    fi
}

# Trasforma un testo di summary libero in un elenco puntato leggibile.
# Delega a Python via env var per evitare problemi di escape (vedi send_telegram).
# Strategia di split: ". " seguito da maiuscola o cifra, " — ", ";"/";".
# Se il testo e gia una singola frase, ritorna un unico bullet.
format_summary_as_bullets() {
    local raw="$1"
    if [[ -z "$raw" ]]; then
        echo "• (nessuna descrizione)"
        return
    fi
    SUMMARY_RAW="$raw" python -c "
import os, re
text = os.environ.get('SUMMARY_RAW', '').strip()
# Normalizza spazi e newline multipli in singolo spazio
text = re.sub(r'\s+', ' ', text)
if not text:
    print('• (nessuna descrizione)')
else:
    # Split su: fine frase (. seguito da maiuscola o cifra), em dash, punto e virgola
    parts = re.split(r'(?<=\.) (?=[A-Z0-9])| — |; ', text)
    parts = [p.strip() for p in parts if p.strip()]
    if not parts:
        print('• ' + text)
    else:
        for p in parts:
            print('• ' + p)
" 2>/dev/null || echo "• $raw"
}

send_notification() {
    $NOTIFY || return 0; echo -ne '\a'
    # Notifiche desktop (leggere, per il beep)
    if command -v notify-send &>/dev/null; then notify-send "$1" "$2" 2>/dev/null || true
    elif command -v osascript &>/dev/null; then osascript -e "display notification \"$2\" with title \"$1\"" 2>/dev/null || true
    elif command -v powershell.exe &>/dev/null; then powershell.exe -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$2','$1')" 2>/dev/null || true; fi
}

# Resoconto Telegram con dettagli.
# Parametri posizionali:
#   1 status          — BLOCCO_OK / CHECKPOINT / PHASE_COMPLETE / ERROR / BLOCKED / MISSING / FAILED / LIMITE_RAGGIUNTO
#   2 bid             — identificativo del blocco (es. F10BB39.2.4)
#   3 blocks_run      — numero blocchi eseguiti in questa sessione (contatore interno)
#   4 elapsed_total   — minuti dall'inizio della sessione runner
#   5 summary         — testo del SUMMARY dal handoff
#   6 next            — testo del NEXT dal handoff
#   7 elapsed_block   — minuti di durata del singolo blocco appena chiuso (default 0)
#
# Comportamento:
# - BLOCCO_OK → notifica SILENZIOSA (disable_notification=true), senza sezione Dispatch
# - Tutti gli altri stati di STOP → notifica SONORA e include la sezione Dispatch con istruzioni
send_telegram_report() {
    local status="$1" bid="$2" blocks_run="$3" elapsed_total="$4" summary="$5" next="$6" elapsed_block="${7:-0}"
    local icon label silent="false"
    case "$status" in
        CONTINUE) return 0;;  # nessuna notifica su CONTINUE generico — usa BLOCCO_OK
        BLOCCO_OK)       icon="✔️"; label="Blocco completato";        silent="true";;
        CHECKPOINT)      icon="⏸️"; label="Checkpoint — decisione richiesta";;
        PHASE_COMPLETE)  icon="✅"; label="FASE COMPLETATA";;
        ERROR)           icon="❌"; label="Errore";;
        BLOCKED)         icon="🚧"; label="Bloccato";;
        MISSING)         icon="⚠️"; label="Handoff mancante";;
        FAILED)          icon="💥"; label="Sessione fallita";;
        "LIMITE RAGGIUNTO") icon="🏁"; label="Limite blocchi raggiunto";;
        *)               icon="❓"; label="$status";;
    esac

    local project_name; project_name="$(basename "$PROJECT_DIR")"
    local total_fmt block_fmt
    total_fmt="$(format_minutes "$elapsed_total")"
    block_fmt="$(format_minutes "$elapsed_block")"

    # Sezione tempo: per BLOCCO_OK mostra entrambi (blocco + totale), per stop solo il totale
    local time_section
    if [[ "$status" == "BLOCCO_OK" ]]; then
        time_section="⏱ Blocco: ${block_fmt}   |   Sessione: ${total_fmt}"
    else
        time_section="⏱ Sessione totale: ${total_fmt}"
    fi

    # Formatta summary in elenco puntato per leggibilita
    local summary_bullets
    summary_bullets="$(format_summary_as_bullets "$summary")"

    # Header principale
    local msg="${icon} ${project_name}
${label}

📦 ${bid}   (${blocks_run}/${MAX_BLOCKS})
${time_section}

📝 Fatto:
${summary_bullets}"

    # Sezione Prossimo: inclusa solo se next e' valorizzato
    if [[ -n "$next" && "$next" != "Nessuna indicazione" ]]; then
        msg+="

➡️ Prossimo:
${next}"
    fi

    # Sezione Dispatch: SOLO sugli stati di STOP (tutti tranne BLOCCO_OK)
    # Include istruzioni chiare su cosa serve e come usarla.
    if [[ "$status" != "BLOCCO_OK" ]]; then
        local win_dir; win_dir="$(cd "$PROJECT_DIR" && pwd -W 2>/dev/null || pwd)"
        local dispatch_prompt="Leggi i file ${win_dir}\\.claude\\handoff.md e ${win_dir}\\${ROADMAP}. Fammi il punto della situazione e dimmi cosa serve per procedere."
        msg+="

━━━━━━━━━━━━━━━━━━━
💡 Se vuoi riprendere il lavoro su Claude Code, copia il testo qui sotto e incollalo come primo messaggio in una nuova sessione:

${dispatch_prompt}"
    fi

    send_telegram "$msg" "$silent"
}

read_file_safe() { local f="$PROJECT_DIR/$1"; [[ -f "$f" ]] && cat "$f" || echo ""; }

init_progress() {
    local p="$PROJECT_DIR/$PROGRESS_FILE"
    [[ -f "$p" ]] && return; mkdir -p "$(dirname "$p")"
    cat > "$p" << 'EOF'
{
  "current_phase": 0,
  "current_block": 0,
  "blocks_completed": [],
  "total_blocks_run": 0,
  "status": "ready",
  "last_run": null
}
EOF
}

read_progress_field() {
    local p="$PROJECT_DIR/$PROGRESS_FILE"
    if [[ ! -f "$p" ]]; then echo ""; return; fi
    # Estrae il valore del campo usando il nome come ancora (non greedy)
    local val
    val="$(sed -n "s/.*\"$1\" *: *\([^,}]*\).*/\1/p" "$p" | head -1 | sed 's/[" ]//g')"
    # Se il valore è "null" o vuoto, restituisci stringa vuota
    if [[ "$val" == "null" || -z "$val" ]]; then
        echo ""
    else
        echo "$val"
    fi
}

update_progress() {
    local p="$PROJECT_DIR/$PROGRESS_FILE" ts; ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"; local t; t="$(read_progress_field total_blocks_run)"; t="${t:-0}"; t=$((t+1))
    local summary; summary="$(echo "$4" | head -1 | sed 's/"/\\"/g')"
    printf '{\n  "current_phase": "%s",\n  "current_block": "%s",\n  "total_blocks_run": %s,\n  "status": "%s",\n  "last_run": "%s",\n  "last_summary": "%s"\n}\n' \
        "$1" "$2" "$t" "$3" "$ts" "$summary" > "$p"
}

append_session_log() {
    local l="$PROJECT_DIR/$SESSION_LOG" ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"; mkdir -p "$(dirname "$l")"
    [[ -f "$l" ]] || echo -e "# Session Log — Metodo Villa Runner\n---\n" > "$l"
    echo -e "\n## $ts — Blocco $1\n- **Status**: $2\n- **Summary**: $3\n---" >> "$l"
}

parse_handoff_status() { local h="$PROJECT_DIR/$HANDOFF_FILE"; [[ -f "$h" ]] && grep -i "^STATUS:" "$h" | head -1 | sed 's/^STATUS: *//; s/ *$//' | tr '[:lower:]' '[:upper:]' || echo "MISSING"; }
parse_handoff_summary() { local h="$PROJECT_DIR/$HANDOFF_FILE"; [[ -f "$h" ]] && sed -n '/^SUMMARY:/,/^\(NEXT:\|DECISIONS_NEEDED:\|FILES_MODIFIED:\|TESTS:\|---\)/p' "$h" | head -5 | sed '1s/^SUMMARY: *//; $d' || echo "Nessun handoff"; }
parse_handoff_phase() { local h="$PROJECT_DIR/$HANDOFF_FILE"; [[ -f "$h" ]] && grep -i "^PHASE:" "$h" | head -1 | sed 's/^PHASE: *//; s/ *$//' || echo ""; }
parse_handoff_block() { local h="$PROJECT_DIR/$HANDOFF_FILE"; [[ -f "$h" ]] && grep -i "^BLOCK:" "$h" | head -1 | sed 's/^BLOCK: *//; s/ *$//' || echo ""; }
parse_handoff_next() { local h="$PROJECT_DIR/$HANDOFF_FILE"; [[ -f "$h" ]] && grep -i "^NEXT:" "$h" | head -1 | sed 's/^NEXT: *//; s/ *$//' || echo ""; }

check_git_branch() {
    git -C "$PROJECT_DIR" rev-parse --git-dir &>/dev/null || { log "${YELLOW}Non è un repo git${NC}"; return 0; }
    local b; b="$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null)"
    [[ "$b" == "main" || "$b" == "master" ]] && die "Sei su '$b'! Lavora su 'develop' o branch di blocco."
    log_verbose "Branch: ${GREEN}$b${NC}"
    local d; d="$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null)"; if [[ -n "$d" ]]; then log "${YELLOW}Modifiche non committate${NC}"; fi
}

# Committa handoff.md + progress.json + session-log.md se dirty.
# Motivazione: Claude a fine blocco committa il CODICE ma scrive handoff.md
# e progress.json e session-log.md DOPO il commit, quindi questi file restano
# "modified" nel working tree. Senza un commit intermedio, accumulano modifiche
# e lo stato del runner si disallinea dai commit di git (come successo nella
# catena B39 del 2026-04-09: handoff mostrava B39.2.1 anche dopo che il codice
# di B39.2.3 era gia committato). Questa funzione chiude la falla committando
# solo i file di stato del runner, e va chiamata PRIMA del push.
commit_handoff_if_dirty() {
    git -C "$PROJECT_DIR" rev-parse --git-dir &>/dev/null || return 0
    local state_files=".claude/handoff.md docs/progress.json docs/session-log.md"
    local dirty
    dirty="$(git -C "$PROJECT_DIR" status --porcelain -- $state_files 2>/dev/null)"
    if [[ -z "$dirty" ]]; then
        log_verbose "Nessun file di stato dirty, skip commit handoff"
        return 0
    fi
    log "${BLUE}Commit stato runner (handoff+progress+session-log)...${NC}"
    # Aggiungi solo i file di stato, non altro (protezione da commit accidentali)
    git -C "$PROJECT_DIR" add .claude/handoff.md docs/progress.json docs/session-log.md 2>/dev/null || true
    local commit_msg="Runner: aggiorna stato post blocco ($1)"
    local commit_out commit_ec=0
    commit_out="$(git -C "$PROJECT_DIR" commit -m "$commit_msg" 2>&1)" || commit_ec=$?
    if [[ $commit_ec -eq 0 ]]; then
        log "${GREEN}Commit stato OK${NC}"
        log_verbose "$commit_out"
    else
        log "${YELLOW}Commit stato non eseguito (probabile nothing to commit)${NC}"
        log_verbose "$commit_out"
    fi
    return 0
}

# Pusha il branch corrente su origin. Usa -u al primo push (upstream non configurato).
# Protezione: rifiuta main/master. Non fatale in caso di errore (logga e prosegue).
# Da chiamare SOLO dopo un blocco completato con test verdi (stato stabile).
push_current_branch() {
    git -C "$PROJECT_DIR" rev-parse --git-dir &>/dev/null || return 0
    local b; b="$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null)"
    if [[ -z "$b" ]]; then
        log "${YELLOW}Push saltato: detached HEAD${NC}"
        return 0
    fi
    if [[ "$b" == "main" || "$b" == "master" ]]; then
        log "${YELLOW}Push saltato: branch protetto ($b)${NC}"
        return 0
    fi
    # Verifica se il branch ha gia un upstream configurato
    local has_upstream=false
    if git -C "$PROJECT_DIR" rev-parse --abbrev-ref --symbolic-full-name "@{u}" &>/dev/null; then
        has_upstream=true
    fi
    log "${BLUE}Push $b -> origin...${NC}"
    local push_out push_ec=0
    if $has_upstream; then
        push_out="$(git -C "$PROJECT_DIR" push origin "$b" 2>&1)" || push_ec=$?
    else
        push_out="$(git -C "$PROJECT_DIR" push -u origin "$b" 2>&1)" || push_ec=$?
    fi
    if [[ $push_ec -eq 0 ]]; then
        log "${GREEN}Push OK ($b)${NC}"
        log_verbose "$push_out"
    else
        log "${YELLOW}Push fallito (ec=$push_ec) — runner prosegue, lavoro salvo in locale${NC}"
        log_verbose "$push_out"
        # Notifica Telegram solo se configurata, non blocca
        send_telegram "⚠️ Runner: push $b fallito (ec=$push_ec). Lavoro salvo in locale, verifica al risveglio."
    fi
    return 0
}

build_prompt() {
    local phase="$1" block="$2" handoff="$3" first="$4" prompt=""
    local c; c="$(read_file_safe "$CLAUDE_MD")"; [[ -n "$c" ]] && prompt+="$c"$'\n\n'
    c="$(read_file_safe "$PROJECT_CONFIG")"; [[ -n "$c" ]] && prompt+="--- CONTESTO PROGETTO ---"$'\n'"$c"$'\n\n'
    c="$(read_file_safe "$ROADMAP")"; [[ -n "$c" ]] && prompt+="--- ROADMAP ---"$'\n'"$c"$'\n\n'
    prompt+="--- STATO ATTUALE ---"$'\n'"Fase: $phase | Blocco: $block"$'\n'"Blocchi completati: $(read_progress_field total_blocks_run)"$'\n\n'
    if [[ -n "$handoff" && "$first" == "false" ]]; then prompt+="--- HANDOFF PRECEDENTE ---"$'\n'"$handoff"$'\n\n'
    elif [[ "$first" == "true" ]]; then prompt+="--- PRIMO BLOCCO ---"$'\n'"Analizza roadmap e progetto, esegui il primo blocco."$'\n\n'; fi
    prompt+="--- ISTRUZIONI RUNNER (OBBLIGATORIE) ---"$'\n'
    prompt+="Sei in sessione automatizzata Metodo Villa. Villa NON è un programmatore e NON verificherà il tuo codice."$'\n'
    prompt+="La qualità e la correttezza sono INTERAMENTE responsabilità tua."$'\n\n'
    prompt+="WORKFLOW BLOCCO:"$'\n'
    prompt+="1. Leggi CLAUDE.md, PROJECT_CONFIG.md, handoff precedente, file rilevanti"$'\n'
    prompt+="2. Esegui UN blocco dalla roadmap"$'\n'
    prompt+="3. VERIFICA OBBLIGATORIA prima di scrivere l'handoff:"$'\n'
    prompt+="   a) Esegui TUTTI i test del progetto (non solo quelli nuovi)"$'\n'
    prompt+="   b) Verifica che il build compili senza errori"$'\n'
    prompt+="   c) Rileggi ogni file che hai modificato e verifica: logica corretta? edge case gestiti? coerente col resto della codebase?"$'\n'
    prompt+="   d) Controlla che le regole di sicurezza del progetto siano rispettate"$'\n'
    prompt+="   e) Se hai toccato aree critiche: attenzione doppia, verifica incrociata"$'\n'
    prompt+="   f) Se QUALSIASI test fallisce o il build non compila: STATUS: ERROR, descrivi il problema, NON scrivere CONTINUE"$'\n'
    prompt+="4. Scrivi .claude/handoff.md secondo il template in .claude/handoff-template.md"$'\n\n'
    prompt+="FORMATO HANDOFF:"$'\n'
    prompt+="STATUS: CONTINUE|CHECKPOINT|PHASE_COMPLETE|ERROR|BLOCKED"$'\n'
    prompt+="PHASE: [num] BLOCK: [num] SUMMARY: [fatto] NEXT: [prossimo] DECISIONS_NEEDED: [se checkpoint/blocked]"$'\n'
    prompt+="FILES_MODIFIED: [lista] TESTS: PASS|FAIL|SKIPPED"$'\n'
    prompt+="VERIFICATION: [risultato della verifica — quanti test passano, build ok/ko, problemi trovati]"$'\n\n'
    prompt+="REGOLE:"$'\n'
    prompt+="- CONTINUE solo se TUTTI i test passano e il build compila. Mai CONTINUE con test rotti."$'\n'
    prompt+="- CHECKPOINT se serve una decisione di Villa (es. scelta architetturale, trade-off)"$'\n'
    prompt+="- ERROR se qualcosa non funziona e non riesci a fixarlo"$'\n'
    prompt+="- BLOCKED se mancano informazioni o accessi"$'\n'
    prompt+="- Commit atomici in italiano (o secondo le convenzioni del progetto)"$'\n'
    prompt+="- NON procedere al blocco successivo"$'\n'
    prompt+="- Se hai dubbi su qualcosa, è meglio CHECKPOINT che CONTINUE"$'\n'
    echo "$prompt"
}

validate_environment() {
    log "${BOLD}Validazione...${NC}"
    command -v claude &>/dev/null || die "Claude Code CLI non trovato"
    [[ -d "$PROJECT_DIR" ]] || die "Directory non trovata: $PROJECT_DIR"
    [[ -f "$PROJECT_DIR/$CLAUDE_MD" ]] || die "CLAUDE.md mancante"
    [[ -f "$PROJECT_DIR/$PROJECT_CONFIG" ]] || log "${YELLOW}PROJECT_CONFIG.md mancante${NC}"
    mkdir -p "$PROJECT_DIR/docs" "$PROJECT_DIR/.claude"; init_progress
    [[ -f "$PROJECT_DIR/$RUNNER_LOG" ]] || echo -e "# Metodo Villa Runner Log\n# $(date)\n" > "$PROJECT_DIR/$RUNNER_LOG"
    check_git_branch; log "${GREEN}Ambiente OK${NC}"
}

run_claude_session() {
    local prompt="$1" bid="$2"; log "${BLUE}Lancio sessione per blocco $bid...${NC}"
    if $DRY_RUN; then log "${YELLOW}[DRY RUN] Prompt: ${#prompt} char${NC}"; mkdir -p "$PROJECT_DIR/.claude"
        echo -e "STATUS: CONTINUE\nPHASE: 0\nBLOCK: 0\nSUMMARY: [DRY RUN]\nNEXT: [DRY RUN]\nTESTS: SKIPPED" > "$PROJECT_DIR/$HANDOFF_FILE"; return 0; fi
    local pf; pf="$(mktemp)"; echo "$prompt" > "$pf"; local ec=0
    timeout "${TIMEOUT_SECONDS}" claude -p --dangerously-skip-permissions --model opus < "$pf" >> "$PROJECT_DIR/$RUNNER_LOG" 2>&1 || ec=$?
    rm -f "$pf"
    [[ $ec -eq 124 ]] && { log "${RED}Timeout ($TIMEOUT_MINUTES min)${NC}"; return 1; }
    [[ $ec -ne 0 ]] && { log "${RED}Errore (exit: $ec)${NC}"; return 1; }
    log "${GREEN}Sessione OK${NC}"; return 0
}

main() {
    echo -e "\n${BOLD}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║        METODO VILLA RUNNER v1.0              ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}\n"
    log "Config: max=$MAX_BLOCKS timeout=${TIMEOUT_MINUTES}min phase=${TARGET_PHASE:-tutte}"
    $DRY_RUN && log "${YELLOW}DRY RUN${NC}"

    # Modalita TEST TELEGRAM: invia 3 messaggi di prova e esci.
    # Utile per validare il formato dei messaggi senza eseguire un ciclo di sviluppo vero.
    # Salta la validazione ambiente (non servono Claude CLI, git, progress.json).
    if $TEST_TELEGRAM; then
        mkdir -p "$PROJECT_DIR/docs" "$PROJECT_DIR/.claude"
        [[ -f "$PROJECT_DIR/$RUNNER_LOG" ]] || echo -e "# Metodo Villa Runner Log\n# $(date)\n" > "$PROJECT_DIR/$RUNNER_LOG"
        log "${BOLD}=== MODALITA TEST TELEGRAM ===${NC}"
        if [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]; then
            log "${RED}Credenziali Telegram non configurate in .env.runner${NC}"
            log "${RED}Configura TELEGRAM_BOT_TOKEN e TELEGRAM_CHAT_ID prima di testare.${NC}"
            exit 1
        fi
        log "Credenziali Telegram trovate. Invio 3 messaggi di prova..."
        echo

        log "${BLUE}[1/3] BLOCCO_OK (notifica silenziosa, senza dispatch)${NC}"
        send_telegram_report "BLOCCO_OK" "F10BB39.2.4" "12" "28" \
            "B39.2.4 completato — Unit test integrazione estrattore. 5 scenari coperti (utente ricco, parziale, off-topic, vuoto, fallimento LLM con retry). 15 nuovi test, 424 backend verdi." \
            "B39.3.1 — Rules-based decisor puro Python" \
            "4"
        log "${GREEN}Test 1 inviato${NC}"
        sleep 3

        log "${BLUE}[2/3] PHASE_COMPLETE (notifica sonora, con dispatch)${NC}"
        send_telegram_report "PHASE_COMPLETE" "F10BB39.11.1" "38" "512" \
            "Catena B39 Onboarding Narrativo COMPLETATA. 38 sub-blocchi eseguiti con successo in 11 fasi tematiche. Profilo estrattore, placement test, voce trasversale: tutto integrato e testato. Pronto per il test manuale del fondatore." \
            "" \
            "6"
        log "${GREEN}Test 2 inviato${NC}"
        sleep 3

        log "${BLUE}[3/3] ERROR (notifica sonora, con dispatch)${NC}"
        send_telegram_report "ERROR" "F10BB39.5.1" "13" "72" \
            "B39.5.1 fallito — validate_secrets_for_startup non trova OPENAI_API_KEY in produzione. Serve configurare la chiave OpenAI in .env del backend prima di poter proseguire con il motore voce Whisper." \
            "" \
            "8"
        log "${GREEN}Test 3 inviato${NC}"
        echo
        log "${BOLD}${GREEN}Tutti i test inviati. Controlla Telegram.${NC}"
        log "Verifica: Test 1 dovrebbe arrivare senza suono (silenzioso)."
        log "Verifica: Test 2 e Test 3 dovrebbero suonare e contenere la sezione Dispatch."
        exit 0
    fi

    validate_environment
    local cp cb; cp="$(read_progress_field current_phase)"; cb="$(read_progress_field current_block)"; cp="${cp:-0}"; cb="${cb:-0}"
    [[ -n "$TARGET_PHASE" ]] && cp="$TARGET_PHASE"
    local hc="" fb="true"
    if $RESUME && [[ -f "$PROJECT_DIR/$HANDOFF_FILE" ]]; then hc="$(cat "$PROJECT_DIR/$HANDOFF_FILE")"; fb="false"
    elif [[ -f "$PROJECT_DIR/$HANDOFF_FILE" ]] && [[ "$(read_progress_field total_blocks_run)" != "0" ]]; then hc="$(cat "$PROJECT_DIR/$HANDOFF_FILE")"; fb="false"; fi
    local br=0 st; st="$(date +%s)"
    log "${BOLD}=== Inizio ciclo ===${NC}\n"
    while [[ $br -lt $MAX_BLOCKS ]]; do
        br=$((br+1)); local bid="F${cp}B${cb}"
        local block_st; block_st="$(date +%s)"  # tempo inizio blocco per metrica per-block
        log "━━━ ${BOLD}Blocco $bid ($br/$MAX_BLOCKS)${NC} ━━━"
        check_git_branch
        local pr; pr="$(build_prompt "$cp" "$cb" "$hc" "$fb")"
        if ! run_claude_session "$pr" "$bid"; then
            local el_now; el_now="$(( ($(date +%s) - st) / 60 ))"
            local el_block; el_block=$(( ($(date +%s) - block_st) / 60 ))
            append_session_log "$bid" "FAILED" "Errore o timeout"; update_progress "$cp" "$cb" "error" "Fallito"
            send_notification "Metodo Villa" "Blocco $bid fallito"
            send_telegram_report "FAILED" "$bid" "$br" "$el_now" "Sessione crashata o timeout" "" "$el_block"; break; fi
        local s; s="$(parse_handoff_status)"; local sm; sm="$(parse_handoff_summary)"; local sn; sn="$(parse_handoff_next)"
        # Aggiorna fase/blocco dall'handoff (sono stringhe, non numeri)
        local np nb; np="$(parse_handoff_phase)"; nb="$(parse_handoff_block)"
        [[ -n "$np" ]] && cp="$np"
        [[ -n "$nb" ]] && cb="$nb"
        log "Status: ${BOLD}$s${NC} — $sm"
        append_session_log "$bid" "$s" "$sm"; update_progress "$cp" "$cb" "$s" "$sm"
        local el_now; el_now="$(( ($(date +%s) - st) / 60 ))"
        local el_block; el_block=$(( ($(date +%s) - block_st) / 60 ))
        case "$s" in
            CONTINUE) log "${GREEN}Continuo${NC}"; hc="$(cat "$PROJECT_DIR/$HANDOFF_FILE")"; fb="false"
                commit_handoff_if_dirty "$bid"
                push_current_branch
                send_telegram_report "BLOCCO_OK" "$bid" "$br" "$el_now" "$sm" "$sn" "$el_block";;
            CHECKPOINT) log "${YELLOW}CHECKPOINT — decisione umana${NC}"; send_notification "Metodo Villa" "Checkpoint $bid"
                commit_handoff_if_dirty "$bid"
                push_current_branch
                send_telegram_report "CHECKPOINT" "$bid" "$br" "$el_now" "$sm" "$sn" "$el_block"; break;;
            PHASE_COMPLETE) log "${GREEN}FASE $cp COMPLETATA${NC}"; send_notification "Metodo Villa" "Fase $cp completata!"
                commit_handoff_if_dirty "$bid"
                push_current_branch
                send_telegram_report "PHASE_COMPLETE" "$bid" "$br" "$el_now" "$sm" "$sn" "$el_block"; break;;
            ERROR) log "${RED}ERRORE $bid${NC}"; send_notification "Metodo Villa" "Errore $bid"
                send_telegram_report "ERROR" "$bid" "$br" "$el_now" "$sm" "$sn" "$el_block"; break;;
            BLOCKED) log "${YELLOW}BLOCCATO${NC}"; send_notification "Metodo Villa" "Bloccato $bid"
                commit_handoff_if_dirty "$bid"
                push_current_branch
                send_telegram_report "BLOCKED" "$bid" "$br" "$el_now" "$sm" "$sn" "$el_block"; break;;
            MISSING) log "${RED}Handoff mancante${NC}"; send_notification "Metodo Villa" "Handoff mancante"
                send_telegram_report "MISSING" "$bid" "$br" "$el_now" "Handoff non trovato" "" "$el_block"; break;;
            *) log "${YELLOW}Status ignoto: $s${NC}"; break;;
        esac
        [[ $br -lt $MAX_BLOCKS ]] && sleep 5
    done
    local et; et="$(date +%s)"; local el=$(((et-st)/60))
    log "\n━━━ ${BOLD}RIEPILOGO${NC} ━━━\nBlocchi: $br | Tempo: ${el}min | Status: $(parse_handoff_status)"
    if [[ $br -ge $MAX_BLOCKS ]]; then
        log "${YELLOW}Limite $MAX_BLOCKS raggiunto${NC}"
        send_notification "Metodo Villa" "$MAX_BLOCKS blocchi in ${el}min"
        send_telegram_report "LIMITE RAGGIUNTO" "$bid" "$br" "$el" "Completati $MAX_BLOCKS blocchi senza problemi" "$(parse_handoff_next)" "0"
    fi
    echo -ne '\a'
}
main "$@"

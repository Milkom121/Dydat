# SPRINT 1.1-1.2: NUCLEO UTENTI E AUTENTICAZIONE
**Progetto**: Dydat Platform  
**Timeline**: 4 settimane (2 Sprint da 2 settimane)  
**Data Inizio**: 07 gennaio 2025  
**Data Fine Target**: 04 febbraio 2025  

## 🎯 OBIETTIVO STRATEGICO
Implementare il sistema completo di autenticazione e gestione utenti per la piattaforma Dydat, creando le fondamenta sicure per tutte le funzionalità successive. Include backend NestJS con database Aurora PostgreSQL e frontend Next.js con sistema di routing protetto.

**🔑 Sistema Ruoli MVP**: Implementazione semplificata ma future-proof basata su documento "Ruoli e Permessi":
- **3 Ruoli Base**: STUDENT (default), CREATOR, ADMIN
- **Database Schema**: Preparato per espansioni future (Tutor, ruoli organizzativi, Neuroni)
- **Permission System**: Base espandibile per matrice completa

## 🧪 REGOLA FONDAMENTALE: TESTING OBBLIGATORIO
⚠️ CRITICO: Dopo ogni completamento di task, eseguire test automatici accurati PRIMA di procedere al task successivo!

### Protocollo di Testing per ogni Task:
1. **Test Funzionale**: Verificare che la feature funzioni come specificato
2. **Test Edge Cases**: Testare scenari limite e input non validi  
3. **Test Integration**: Verificare che non rompa funzionalità esistenti
4. **Test UX**: Controllare che l'esperienza utente sia fluida
5. **Test Performance**: Verificare che non degradi le performance
6. **Test Security**: Validare sicurezza authentication/authorization
7. **Test Role-based**: Verificare comportamento per ogni ruolo
8. **Documentazione**: Aggiornare eventuali docs/esempi

❌ Non procedere MAI al task successivo senza aver completato tutti i test del task corrente!

## 📝 TRACKING E DOCUMENTAZIONE
🔄 PROCESSO: Dopo ogni task completato, aggiornare questo file con:

### Status Update per ogni Task:
```
✅ [COMPLETATO] Task X.X.X: Nome Task
📅 Data: [DATA COMPLETAMENTO]
👤 Implementato da: [AI Assistant + Human Orchestrator]
🧪 Test Status: [PASSED/FAILED/PARTIAL]

📊 Report Breve:
- Cosa è stato implementato
- Funzionalità chiave aggiunte
- Test eseguiti e risultati
- Issues/limitazioni identificate
- Note per future implementazioni

📂 File Modificati:
- /path/to/file1
- /path/to/file2

🎯 Pronto per: [PROSSIMO TASK]
```

⚠️ Mantenere sempre questo file aggiornato per tracking accurato del progresso!

---

## 🚀 STATO CORRENTE IMPLEMENTAZIONE

### 📍 POSIZIONE ATTUALE:
- **Milestone**: 1 - MVP Dydat Public  
- **Fase**: 1.1-1.2 - Nucleo Utenti e Autenticazione  
- **Task Corrente**: 1.1.1 - Setup Authentication Module nel Monorepo  
- **Status**: 🎯 **PRONTO PER INIZIARE**

### 📈 PROGRESSO OVERALL:
- **Completati**: 1/12 sprint principali (8.3%)  
- **Infrastruttura**: ✅ COMPLETATA (Fase 0)  
- **Prossimo**: Sviluppo Backend + Frontend Autenticazione

### 🏆 TASK COMPLETATI:
- ✅ **Fase 0**: Infrastruttura AWS enterprise-grade (EKS, Aurora, ECR, VPC, CI/CD)
- ✅ **Design System**: Analisi documento Ruoli e Permessi, definizione strategia MVP

---

## 📋 MILESTONES E FASI

### 🔹 MILESTONE 1: MVP DYDAT PUBLIC
**Timeline**: 6 mesi (12 Sprint) | **Obiettivo**: Piattaforma base funzionante con utenti, corsi, pagamenti

#### **FASE 1.1: BACKEND FOUNDATION & AUTH (Sprint 1 - 2 settimane)**

- **TASK 1.1.1**: Setup Authentication Module nel Monorepo → ⏳ **PENDING**
  - Configurare modulo autenticazione nel backend esistente `/apps/backend/`
  - Installare dipendenze per auth: `@nestjs/jwt`, `@nestjs/passport`, `bcrypt`, `class-validator`
  - Setup TypeORM entities per User e RefreshToken nel backend
  - Configurare environment variables per JWT secrets in monorepo
  - Aggiornare CI/CD pipeline esistente per include auth tests

- **TASK 1.1.2**: Database Schema e Connessione → ⏳ **PENDING**
  - Configurare TypeORM con Aurora PostgreSQL
  - Creare entità User con sistema ruoli MVP (STUDENT/CREATOR/ADMIN)
  - Schema future-proof per espansioni (user_organization_roles, specializations)
  - Entità RefreshToken per gestione sessioni
  - Setup migrazioni database automatiche
  - Configurare connection pooling e retry logic
  - Test connessione database con health check

- **TASK 1.1.3**: Core Authentication Service → ⏳ **PENDING**
  - Implementare UserService con CRUD operations
  - Permission service base (canCreateCourses, canManageUsers, canAccessAnalytics)
  - Creare AuthService con bcrypt per password hashing
  - Implementare JWT token generation e validation con role claims
  - Creare refresh token rotation mechanism
  - Setup rate limiting per login attempts

- **TASK 1.1.4**: Authentication Controllers & APIs → ⏳ **PENDING**
  - Implementare AuthController con endpoints:
    - `POST /auth/register` - Registrazione utente (default STUDENT role)
    - `POST /auth/login` - Login con JWT + role info
    - `POST /auth/refresh` - Refresh token
    - `POST /auth/logout` - Logout e token invalidation
    - `GET /auth/me` - Profilo utente + permessi correnti
    - `PATCH /auth/upgrade-role` - Richiesta upgrade a CREATOR (admin approval)
  - Role-based middleware per endpoint protection
  - Validazione input con class-validator
  - Error handling e response standardization

#### **FASE 1.2: FRONTEND FOUNDATION & AUTH UI (Sprint 2 - 2 settimane)**

- **TASK 1.2.1**: Setup Authentication nel Frontend → ⏳ **PENDING**
  - Configurare modulo autenticazione nel frontend esistente `/apps/frontend/`
  - Installare dipendenze: `axios`, `@hookform/resolvers`, `zod`, `react-hook-form`
  - Setup shadcn/ui components se non già installato
  - Configurare environment variables per API backend URL
  - Aggiornare CI/CD pipeline per include frontend auth flow tests

- **TASK 1.2.2**: Authentication Context & API Layer → ⏳ **PENDING**
  - Creare AuthContext con React Context API
  - Implementare API client con Axios/Fetch
  - Setup automatic token refresh interceptors
  - Creare custom hooks: useAuth, useApi, usePermissions
  - Implementare persistent auth state (localStorage/cookies)
  - Role-based UI components (RoleGuard, PermissionGate)

- **TASK 1.2.3**: Authentication Pages → ⏳ **PENDING**
  - Pagina `/register` con role selection (Student/Creator)
  - Pagina `/login` con remember me e forgot password
  - Pagina `/dashboard` dinamica basata su ruolo:
    - STUDENT: "I miei corsi", "Esplora catalogo"
    - CREATOR: + "Crea corso", "Analytics corsi"
    - ADMIN: + "Gestisci utenti", "Dashboard admin"
  - Componente Navbar con login/logout dinamico + role indicator
  - Responsive design per mobile/desktop

- **TASK 1.2.4**: Protected Routing & Security → ⏳ **PENDING**
  - Implementare Higher-Order Component per route protection
  - Role-based routing: `/creator/*`, `/admin/*` routes
  - Creare middleware per automatic redirect se non autenticato
  - Permission-based component rendering
  - Setup CSRF protection e secure headers
  - Implementare session timeout con warning user
  - Error boundary per gestione errori auth

#### **INTEGRAZIONE E TESTING (Ultima settimana)**

- **TASK 1.3.1**: Integration Testing → ⏳ **PENDING**
  - Test E2E del flusso completo registrazione→login→dashboard per ogni ruolo
  - Test role-based access control su API e frontend
  - Test security: SQL injection, XSS, CSRF
  - Test performance: load testing su endpoint auth
  - Test mobile responsiveness
  - Test browser compatibility

- **TASK 1.3.2**: Deployment e Production Setup → ⏳ **PENDING**
  - Deploy backend e frontend su EKS via CI/CD
  - Setup monitoring con CloudWatch e health checks
  - Configurare SSL/TLS certificates
  - Setup backup automatici database
  - Documentazione API con Swagger/OpenAPI
  - Role-based API documentation

---

## 📊 SUMMARY & TIMELINE

**Totale Sprint**: 4 settimane  
**Backend Development**: 2 settimane  
**Frontend Development**: 2 settimane  
**Integration & Testing**: Parallelo + 1 settimana finale  

### 🎯 SUCCESS METRICS

**Funzionalità Core:**
- ✅ Utente può registrarsi come STUDENT o CREATOR
- ✅ Sistema login con JWT + role claims funzionante
- ✅ Dashboard dinamica basata su ruolo utente
- ✅ Sistema refresh token automatico funzionante
- ✅ Role-based access control su API e frontend
- ✅ Logout corretto con invalidazione token

**Role-based Features:**
- ✅ STUDENT: Accesso base a catalogo e corsi
- ✅ CREATOR: + Accesso a strumenti creazione contenuti  
- ✅ ADMIN: + Gestione utenti e dashboard amministrativa
- ✅ Permission system espandibile per future features

**Performance:**
- ✅ Login response time < 500ms
- ✅ Database connection pooling configurato
- ✅ Frontend responsive su mobile/desktop
- ✅ API rate limiting configurato

**Security:**
- ✅ Password hashing con bcrypt (cost 12)
- ✅ JWT token con role claims, expiration (15min access, 7 giorni refresh)
- ✅ HTTPS su tutti gli endpoint
- ✅ Input validation su tutti i form
- ✅ Protection contro common attacks (XSS, CSRF, SQLi)
- ✅ Role-based authorization middleware

### 🔄 DELIVERY APPROACH

- **Sprint Length**: 2 settimane per fase
- **Demo Frequency**: Ogni settimana (venerdì) con test di tutti i ruoli
- **Testing Strategy**: Test-driven development con coverage > 80% + role-based testing
- **Deployment**: Continuous deployment via GitHub Actions su EKS
- **Code Review**: Obbligatorio per ogni PR con focus su security
- **Documentation**: Inline + API docs + README + Role mapping aggiornati

### 🛠️ TECH STACK DETTAGLIATO

**Backend:**
- Framework: NestJS 10+ con TypeScript
- Database: Aurora PostgreSQL (via infrastruttura esistente)
- ORM: TypeORM con migrazioni automatiche
- Authentication: JWT + bcrypt + role-based claims
- Authorization: Custom role & permission decorators
- Validation: class-validator, class-transformer
- Testing: Jest + Supertest per E2E + role-based test suites
- API Documentation: Swagger/OpenAPI 3.0 con role-based docs

**Frontend:**
- Framework: Next.js 14 con App Router
- Styling: Tailwind CSS + shadcn/ui components
- State Management: React Context + custom hooks + role state
- HTTP Client: Axios con interceptors + role-aware requests
- Forms: React Hook Form + Zod validation
- Testing: Jest + React Testing Library + Playwright E2E + role-based tests
- UI Components: Role-aware rendering (RoleGuard, PermissionGate)

**DevOps & Infrastructure:**
- Container: Docker multi-stage builds
- Orchestration: Kubernetes (EKS)
- CI/CD: GitHub Actions con test role-based
- Monitoring: CloudWatch + EKS metrics + role-based analytics
- Security: AWS Security Groups + IAM roles + JWT role claims

---

## 🗂️ DATABASE SCHEMA DETTAGLIATO

### **Schema MVP (Implementazione Sprint 1.1-1.2)**

```sql
-- Tabella Users (MVP)
users:
  id: UUID (primary key)
  email: VARCHAR(255) UNIQUE NOT NULL
  password_hash: VARCHAR(255) NOT NULL
  first_name: VARCHAR(100)
  last_name: VARCHAR(100)
  role: ENUM('STUDENT', 'CREATOR', 'ADMIN') DEFAULT 'STUDENT'
  is_active: BOOLEAN DEFAULT true
  email_verified: BOOLEAN DEFAULT false
  created_at: TIMESTAMP DEFAULT NOW()
  updated_at: TIMESTAMP DEFAULT NOW()

-- Tabella Refresh Tokens
refresh_tokens:
  id: UUID (primary key)
  user_id: UUID (foreign key to users)
  token_hash: VARCHAR(255) NOT NULL
  expires_at: TIMESTAMP NOT NULL
  created_at: TIMESTAMP DEFAULT NOW()
  is_revoked: BOOLEAN DEFAULT false

-- Tabella Login Attempts (per rate limiting)
login_attempts:
  id: UUID (primary key)
  ip_address: INET NOT NULL
  email: VARCHAR(255)
  success: BOOLEAN NOT NULL
  attempted_at: TIMESTAMP DEFAULT NOW()
```

### **Schema Future-Proof (Preparato per espansioni)**

```sql
-- Per Sprint futuri (Tutor, Neuroni, Organizzazioni)
user_specializations:
  id: UUID (primary key)
  user_id: UUID (foreign key to users)
  discipline: VARCHAR(100) NOT NULL
  mastery_level: INTEGER CHECK (mastery_level BETWEEN 1 AND 100)
  verified_at: TIMESTAMP

organizations:
  id: UUID (primary key)
  name: VARCHAR(255) NOT NULL
  type: ENUM('COMPANY', 'INSTITUTE') NOT NULL
  created_at: TIMESTAMP DEFAULT NOW()

user_organization_roles:
  id: UUID (primary key)
  user_id: UUID (foreign key to users)
  organization_id: UUID (foreign key to organizations)
  org_role: ENUM('MEMBER', 'MANAGER', 'ORG_ADMIN') NOT NULL
  created_at: TIMESTAMP DEFAULT NOW()

-- Tabella per economia Neuroni (future)
neuron_wallets:
  id: UUID (primary key)
  user_id: UUID (foreign key to users)
  balance: INTEGER DEFAULT 0
  created_at: TIMESTAMP DEFAULT NOW()
```

---

## 🚨 BLOCKERS E DIPENDENZE

**Dipendenze Esterne:**
- ✅ Infrastruttura AWS (EKS, Aurora, ECR) - DISPONIBILE
- ✅ GitHub repository access - DISPONIBILE
- ✅ Documento Ruoli e Permessi - ANALIZZATO
- ✅ Domain/SSL certificates per production - DA CONFIGURARE

**Potenziali Blockers:**
- ⚠️ Database connection from EKS to Aurora
- ⚠️ JWT secret management in Kubernetes
- ⚠️ Cross-origin configuration between frontend/backend
- ⚠️ Role-based middleware performance impact

**Mitigation Strategy:**
- Test database connectivity nel primo task
- Utilizzare Kubernetes secrets per JWT management
- Configurare CORS appropriatamente nel backend
- Performance testing per authorization middleware

---

## 🎯 ALIGNMENT CON DOCUMENTO RUOLI E PERMESSI

**MVP Implementation (Sprint 1.1-1.2):**
- ✅ **Guest**: Non autenticato (accesso limitato)
- ✅ **Student**: Ruolo default, accesso base
- ✅ **Creator**: Specializzazione per creazione contenuti
- ✅ **Admin**: Gestione piattaforma

**Future Expansions (Sprint successivi):**
- 📅 **Tutor**: Role + Neuroni economy + Mercatino
- 📅 **Ruoli Organizzativi**: Member, Manager, Org Admin
- 📅 **Advanced Workflows**: Commissioni, Bacheca, Analytics
- 📅 **Gamification**: XP, Livelli, Badge, Neuroni

**Benefici Approccio:**
- ✅ **Coerenza**: Allineato con visione a lungo termine
- ✅ **Velocità**: MVP semplice ma completo
- ✅ **Scalabilità**: Database e architettura future-proof
- ✅ **Testing**: Base solida per features complesse

---

## 📈 NEXT SPRINT PREVIEW

**Sprint 1.3-1.4**: Catalogo e Creazione Corsi
- Leveraging role CREATOR per gestione contenuti
- Permission system espanso per CRUD corsi
- Role-based UI per Creator dashboard
- API endpoints con role-based authorization

---

*Generated from Template @ 07 gennaio 2025*
*Updated with Role & Permissions Analysis @ 07 gennaio 2025* 
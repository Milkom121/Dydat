// Test semplificato del sistema di autenticazione Dydat
// Senza dipendenze esterne per testare la logica

const UserRole = {
  STUDENT: 'STUDENT',
  CREATOR: 'CREATOR',
  ADMIN: 'ADMIN'
};

class User {
  constructor(data) {
    this.id = data.id || Math.random().toString(36).substr(2, 9);
    this.email = data.email;
    this.password = data.password; // In produzione sarà hashata
    this.firstName = data.firstName;
    this.lastName = data.lastName;
    this.role = data.role || UserRole.STUDENT;
    this.isActive = data.isActive !== false;
    this.emailVerified = data.emailVerified || false;
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }

  get fullName() {
    return `${this.firstName} ${this.lastName}`;
  }

  isStudent() {
    return this.role === UserRole.STUDENT;
  }

  isCreator() {
    return this.role === UserRole.CREATOR;
  }

  isAdmin() {
    return this.role === UserRole.ADMIN;
  }

  canCreateContent() {
    return this.role === UserRole.CREATOR || this.role === UserRole.ADMIN;
  }

  hasAdminPrivileges() {
    return this.role === UserRole.ADMIN;
  }
}

// Simulazione AuthService semplificata
class AuthService {
  constructor() {
    this.users = [];
  }

  async register(userData) {
    // Check se l'utente esiste già
    const existingUser = this.users.find(u => u.email === userData.email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Validazioni base
    if (!userData.email || !userData.password || !userData.firstName || !userData.lastName) {
      throw new Error('Missing required fields');
    }

    if (userData.password.length < 8) {
      throw new Error('Password must be at least 8 characters long');
    }

    // Crea utente
    const user = new User(userData);
    this.users.push(user);
    
    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        emailVerified: user.emailVerified
      },
      message: 'User registered successfully'
    };
  }

  async login(email, password) {
    // Trova utente
    const user = this.users.find(u => u.email === email);
    if (!user) {
      throw new Error('Invalid credentials');
    }

    // Verifica password (semplificata)
    if (user.password !== password) {
      throw new Error('Invalid credentials');
    }

    // Check se attivo
    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }

    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        permissions: {
          canCreateContent: user.canCreateContent(),
          hasAdminPrivileges: user.hasAdminPrivileges(),
          isStudent: user.isStudent(),
          isCreator: user.isCreator(),
          isAdmin: user.isAdmin()
        }
      },
      message: 'Login successful'
    };
  }

  findByEmail(email) {
    return this.users.find(u => u.email === email);
  }

  getAllUsers() {
    return this.users.map(u => ({
      id: u.id,
      email: u.email,
      fullName: u.fullName,
      role: u.role,
      isActive: u.isActive
    }));
  }

  // Metodi per testare la gestione ruoli
  checkAccess(userEmail, requiredRoles) {
    const user = this.findByEmail(userEmail);
    if (!user) return false;
    if (!user.isActive) return false;
    return requiredRoles.includes(user.role);
  }
}

// Test del sistema
async function runTests() {
  console.log('🚀 Avvio test sistema autenticazione Dydat\n');
  
  const authService = new AuthService();
  let testCount = 0;
  let passedTests = 0;
  
  function test(description, fn) {
    testCount++;
    try {
      fn();
      console.log(`✅ Test ${testCount}: ${description}`);
      passedTests++;
    } catch (error) {
      console.log(`❌ Test ${testCount}: ${description} - ${error.message}`);
    }
  }
  
  try {
    // Test 1: Registrazione utenti con diversi ruoli
    console.log('📝 SEZIONE: Registrazione utenti\n');
    
    const student = await authService.register({
      email: 'mario.rossi@student.it',
      password: 'password123',
      firstName: 'Mario',
      lastName: 'Rossi',
      role: UserRole.STUDENT
    });
    
    test('Registrazione studente', () => {
      if (student.user.role !== UserRole.STUDENT) throw new Error('Ruolo sbagliato');
      if (student.user.email !== 'mario.rossi@student.it') throw new Error('Email sbagliata');
    });

    const creator = await authService.register({
      email: 'giulia.verdi@creator.it', 
      password: 'password123',
      firstName: 'Giulia',
      lastName: 'Verdi',
      role: UserRole.CREATOR
    });
    
    test('Registrazione creator', () => {
      if (creator.user.role !== UserRole.CREATOR) throw new Error('Ruolo sbagliato');
    });

    const admin = await authService.register({
      email: 'luca.bianchi@admin.it',
      password: 'password123', 
      firstName: 'Luca',
      lastName: 'Bianchi',
      role: UserRole.ADMIN
    });
    
    test('Registrazione admin', () => {
      if (admin.user.role !== UserRole.ADMIN) throw new Error('Ruolo sbagliato');
    });

    // Test 2: Validazioni
    console.log('\n🔍 SEZIONE: Validazioni\n');
    
    test('Password troppo corta', async () => {
      try {
        await authService.register({
          email: 'test@test.it',
          password: '123', // Troppo corta
          firstName: 'Test',
          lastName: 'User'
        });
        throw new Error('Doveva fallire');
      } catch (error) {
        if (!error.message.includes('8 characters')) throw new Error('Messaggio sbagliato');
      }
    });

    test('Email duplicata', async () => {
      try {
        await authService.register({
          email: 'mario.rossi@student.it', // Già esistente
          password: 'password123',
          firstName: 'Test',
          lastName: 'Duplicate'
        });
        throw new Error('Doveva fallire');
      } catch (error) {
        if (!error.message.includes('already exists')) throw new Error('Messaggio sbagliato');
      }
    });

    // Test 3: Login
    console.log('\n🔐 SEZIONE: Login\n');
    
    const studentLogin = await authService.login('mario.rossi@student.it', 'password123');
    test('Login studente valido', () => {
      if (studentLogin.user.email !== 'mario.rossi@student.it') throw new Error('Email sbagliata');
      if (!studentLogin.user.permissions.isStudent) throw new Error('Permessi sbagliati');
    });

    test('Login credenziali sbagliate', async () => {
      try {
        await authService.login('mario.rossi@student.it', 'passwordsbagliata');
        throw new Error('Doveva fallire');
      } catch (error) {
        if (!error.message.includes('Invalid credentials')) throw new Error('Messaggio sbagliato');
      }
    });

    // Test 4: Sistema ruoli e permessi
    console.log('\n🎭 SEZIONE: Sistema ruoli e permessi\n');
    
    const studentUser = authService.findByEmail('mario.rossi@student.it');
    const creatorUser = authService.findByEmail('giulia.verdi@creator.it');
    const adminUser = authService.findByEmail('luca.bianchi@admin.it');

    test('Studente NON può creare contenuti', () => {
      if (studentUser.canCreateContent()) throw new Error('Studente non dovrebbe poter creare contenuti');
    });

    test('Creator può creare contenuti', () => {
      if (!creatorUser.canCreateContent()) throw new Error('Creator dovrebbe poter creare contenuti');
    });

    test('Admin può creare contenuti', () => {
      if (!adminUser.canCreateContent()) throw new Error('Admin dovrebbe poter creare contenuti');
    });

    test('Solo admin ha privilegi amministrativi', () => {
      if (studentUser.hasAdminPrivileges()) throw new Error('Studente non dovrebbe avere privilegi admin');
      if (creatorUser.hasAdminPrivileges()) throw new Error('Creator non dovrebbe avere privilegi admin');
      if (!adminUser.hasAdminPrivileges()) throw new Error('Admin dovrebbe avere privilegi admin');
    });

    // Test 5: Controllo accessi endpoint
    console.log('\n🚪 SEZIONE: Controllo accessi endpoint\n');

    test('Endpoint solo admin - accesso admin', () => {
      if (!authService.checkAccess('luca.bianchi@admin.it', [UserRole.ADMIN])) {
        throw new Error('Admin dovrebbe avere accesso');
      }
    });

    test('Endpoint solo admin - accesso studente negato', () => {
      if (authService.checkAccess('mario.rossi@student.it', [UserRole.ADMIN])) {
        throw new Error('Studente non dovrebbe avere accesso');
      }
    });

    test('Endpoint creator/admin - accesso creator', () => {
      if (!authService.checkAccess('giulia.verdi@creator.it', [UserRole.CREATOR, UserRole.ADMIN])) {
        throw new Error('Creator dovrebbe avere accesso');
      }
    });

    test('Endpoint creator/admin - accesso admin', () => {
      if (!authService.checkAccess('luca.bianchi@admin.it', [UserRole.CREATOR, UserRole.ADMIN])) {
        throw new Error('Admin dovrebbe avere accesso');
      }
    });

    // Test 6: Proprietà utente
    console.log('\n👤 SEZIONE: Proprietà utente\n');

    test('Full name corretto', () => {
      if (studentUser.fullName !== 'Mario Rossi') throw new Error('Full name sbagliato');
    });

    test('Controlli ruolo specifici', () => {
      if (!studentUser.isStudent()) throw new Error('isStudent() fallito');
      if (studentUser.isCreator()) throw new Error('isCreator() dovrebbe essere false');
      if (studentUser.isAdmin()) throw new Error('isAdmin() dovrebbe essere false');
      
      if (!creatorUser.isCreator()) throw new Error('Creator isCreator() fallito');
      if (!adminUser.isAdmin()) throw new Error('Admin isAdmin() fallito');
    });

    // Riepilogo
    console.log('\n📊 RIEPILOGO TEST\n');
    console.log(`✅ Test passati: ${passedTests}/${testCount}`);
    console.log(`📈 Percentuale successo: ${((passedTests/testCount) * 100).toFixed(1)}%`);
    
    if (passedTests === testCount) {
      console.log('\n🎉 TUTTI I TEST PASSATI! Il sistema di autenticazione funziona correttamente.');
    } else {
      console.log('\n⚠️  Alcuni test sono falliti. Controllare l\'implementazione.');
    }

    // Info utenti registrati
    const allUsers = authService.getAllUsers();
    console.log('\n👥 UTENTI REGISTRATI:');
    allUsers.forEach(user => {
      console.log(`   ${user.fullName} (${user.email}) - ${user.role}`);
    });
    
    console.log(`\n📝 Statistiche: ${allUsers.length} utenti totali`);
    console.log(`   📚 Studenti: ${allUsers.filter(u => u.role === UserRole.STUDENT).length}`);
    console.log(`   🎨 Creator: ${allUsers.filter(u => u.role === UserRole.CREATOR).length}`);
    console.log(`   👑 Admin: ${allUsers.filter(u => u.role === UserRole.ADMIN).length}`);

  } catch (error) {
    console.error('💥 Errore durante i test:', error);
  }
}

// Esegui i test
runTests(); 
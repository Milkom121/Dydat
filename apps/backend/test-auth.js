const bcrypt = require('bcryptjs');

// Simulazione del sistema di autenticazione
const UserRole = {
  STUDENT: 'STUDENT',
  CREATOR: 'CREATOR',
  ADMIN: 'ADMIN'
};

class User {
  constructor(data) {
    this.id = data.id || Math.random().toString(36).substr(2, 9);
    this.email = data.email;
    this.password = data.password;
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

// Simulazione AuthService
class AuthService {
  constructor() {
    this.users = [];
  }

  async hashPassword(password) {
    return await bcrypt.hash(password, 12);
  }

  async comparePassword(password, hashedPassword) {
    return await bcrypt.compare(password, hashedPassword);
  }

  async register(userData) {
    // Check se l'utente esiste già
    const existingUser = this.users.find(u => u.email === userData.email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await this.hashPassword(userData.password);

    // Crea utente
    const user = new User({
      ...userData,
      password: hashedPassword
    });

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

    // Verifica password
    const isValid = await this.comparePassword(password, user.password);
    if (!isValid) {
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
}

// Test del sistema
async function runTests() {
  console.log('🚀 Avvio test sistema autenticazione Dydat\n');
  
  const authService = new AuthService();
  
  try {
    // Test 1: Registrazione utenti con diversi ruoli
    console.log('📝 Test 1: Registrazione utenti...');
    
    const student = await authService.register({
      email: 'mario.rossi@student.it',
      password: 'password123',
      firstName: 'Mario',
      lastName: 'Rossi',
      role: UserRole.STUDENT
    });
    console.log('✅ Studente registrato:', student.user.email, '-', student.user.role);

    const creator = await authService.register({
      email: 'giulia.verdi@creator.it', 
      password: 'password123',
      firstName: 'Giulia',
      lastName: 'Verdi',
      role: UserRole.CREATOR
    });
    console.log('✅ Creator registrato:', creator.user.email, '-', creator.user.role);

    const admin = await authService.register({
      email: 'luca.bianchi@admin.it',
      password: 'password123', 
      firstName: 'Luca',
      lastName: 'Bianchi',
      role: UserRole.ADMIN
    });
    console.log('✅ Admin registrato:', admin.user.email, '-', admin.user.role);

    // Test 2: Login utenti
    console.log('\n🔐 Test 2: Login utenti...');
    
    const studentLogin = await authService.login('mario.rossi@student.it', 'password123');
    console.log('✅ Login studente:', studentLogin.user.email);
    console.log('   Permessi:', studentLogin.user.permissions);

    const creatorLogin = await authService.login('giulia.verdi@creator.it', 'password123');
    console.log('✅ Login creator:', creatorLogin.user.email);
    console.log('   Permessi:', creatorLogin.user.permissions);

    const adminLogin = await authService.login('luca.bianchi@admin.it', 'password123');
    console.log('✅ Login admin:', adminLogin.user.email);
    console.log('   Permessi:', adminLogin.user.permissions);

    // Test 3: Controllo duplicati
    console.log('\n🚫 Test 3: Controllo duplicati...');
    try {
      await authService.register({
        email: 'mario.rossi@student.it', // Email già esistente
        password: 'password123',
        firstName: 'Test',
        lastName: 'Duplicate'
      });
    } catch (error) {
      console.log('✅ Errore duplicato corretto:', error.message);
    }

    // Test 4: Login con credenziali sbagliate
    console.log('\n❌ Test 4: Login con credenziali sbagliate...');
    try {
      await authService.login('mario.rossi@student.it', 'passwordsbagliata');
    } catch (error) {
      console.log('✅ Errore login corretto:', error.message);
    }

    // Test 5: Verifiche logiche ruoli
    console.log('\n🎭 Test 5: Verifiche logiche ruoli...');
    
    const studentUser = authService.findByEmail('mario.rossi@student.it');
    const creatorUser = authService.findByEmail('giulia.verdi@creator.it');
    const adminUser = authService.findByEmail('luca.bianchi@admin.it');

    console.log('📚 Studente può creare contenuti?', studentUser.canCreateContent()); // false
    console.log('🎨 Creator può creare contenuti?', creatorUser.canCreateContent()); // true
    console.log('👑 Admin può creare contenuti?', adminUser.canCreateContent()); // true
    console.log('👑 Admin ha privilegi amministrativi?', adminUser.hasAdminPrivileges()); // true
    console.log('📚 Studente ha privilegi amministrativi?', studentUser.hasAdminPrivileges()); // false

    // Test 6: Lista utenti
    console.log('\n👥 Test 6: Lista utenti registrati...');
    const allUsers = authService.getAllUsers();
    allUsers.forEach(user => {
      console.log(`   ${user.fullName} (${user.email}) - ${user.role}`);
    });

    console.log('\n🎉 Tutti i test completati con successo!');
    console.log('\n📊 Riepilogo:');
    console.log(`   - ${allUsers.length} utenti registrati`);
    console.log(`   - ${allUsers.filter(u => u.role === UserRole.STUDENT).length} studenti`);
    console.log(`   - ${allUsers.filter(u => u.role === UserRole.CREATOR).length} creator`);
    console.log(`   - ${allUsers.filter(u => u.role === UserRole.ADMIN).length} admin`);

  } catch (error) {
    console.error('💥 Errore durante i test:', error);
  }
}

// Esegui i test solo se il file è eseguito direttamente
if (require.main === module) {
  runTests();
}

module.exports = { AuthService, User, UserRole }; 
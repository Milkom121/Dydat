'use client';

import { useAuthStore, useIsAuthenticated, useCurrentUser } from '@/stores/auth';
import { UserRole } from '@/types/auth';
import { DarkModeToggle } from '@/components/ui/dark-mode-toggle';
import { 
  Button, 
  Card, 
  CardHeader, 
  CardTitle, 
  CardDescription, 
  CardContent,
  Input,
  Alert,
  AlertDescription,
  Spinner,
  Modal,
  ModalTrigger,
  ModalContent,
  ModalHeader,
  ModalTitle,
  ModalDescription,
  ModalFooter
} from '@/components/ui';
import { Header, Footer, Container, Grid, GridItem } from '@/components/layout';
import { Search, Mail, Lock, Star, Users, BookOpen, Layout, Layers, Box } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';

export default function Home() {
  const isAuthenticated = useIsAuthenticated();
  const user = useCurrentUser();
  const [showComponentsDemo, setShowComponentsDemo] = useState(false);

  return (
    <div className="min-h-screen hero-bg">
      {/* Header */}
      <Header />

      {/* Main Content */}
      <main>
        {/* Hero Section */}
        <Container className="py-16">
          <div className="text-center max-w-4xl mx-auto">
            {/* Hero Header */}
            <h1 className="text-5xl lg:text-6xl font-bold text-gradient-educational mb-6 animate-fade-in">
              Benvenuti in Dydat
            </h1>
            
            <p className="text-xl lg:text-2xl text-gray-600 dark:text-gray-300 mb-8 leading-relaxed animate-slide-up">
              L'ecosistema di apprendimento intelligente che trasforma l'educazione
              con <span className="text-blue-600 dark:text-blue-400 font-semibold">AI</span> e{' '}
              <span className="text-success-600 dark:text-success-400 font-semibold">gamification</span>
            </p>

            {/* Auth Status Display */}
            {isAuthenticated && user ? (
              <Card className="max-w-md mx-auto mb-8 animate-fade-in" variant="elevated">
                <CardContent className="text-center pt-6">
                  <div className="w-16 h-16 bg-gradient-primary rounded-full flex items-center justify-center mx-auto mb-4 animate-glow">
                    <span className="text-2xl font-bold text-white">
                      {user.firstName.charAt(0)}{user.lastName.charAt(0)}
                    </span>
                  </div>
                  <CardTitle className="mb-2">
                    Benvenuto, {user.firstName}!
                  </CardTitle>
                  <CardDescription className="mb-4">
                    Ruolo: <span className="font-medium text-primary-600 dark:text-primary-400">
                      {user.role === UserRole.STUDENT && 'Studente'}
                      {user.role === UserRole.CREATOR && 'Creator'}
                      {user.role === UserRole.ADMIN && 'Amministratore'}
                    </span>
                  </CardDescription>
                  <Link href="/dashboard">
                    <Button>Vai alla Dashboard</Button>
                  </Link>
                </CardContent>
              </Card>
            ) : (
              <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
                <Link href="/auth/register">
                  <Button size="lg" className="animate-glow">Inizia Ora - Gratis</Button>
                </Link>
                <Link href="/auth/login">
                  <Button variant="secondary" size="lg">Accedi</Button>
                </Link>
              </div>
            )}

            {/* Demo Toggle */}
            <Button 
              variant="ghost" 
              size="sm"
              onClick={() => setShowComponentsDemo(!showComponentsDemo)}
              className="mb-8"
            >
              {showComponentsDemo ? 'Nascondi' : 'Mostra'} Componenti Demo
            </Button>
          </div>
        </Container>

        {/* Components Demo Section */}
        {showComponentsDemo && (
          <Container className="py-16 animate-slide-up">
            <h2 className="text-3xl font-bold text-center text-gray-900 dark:text-white mb-8">
              🎨 Showcase Componenti UI & Layout
            </h2>
            
            <div className="space-y-12">
              {/* Layout Components Demo */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Layout className="w-5 h-5" />
                    Layout Components
                  </CardTitle>
                  <CardDescription>Container e Grid system responsive</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-8">
                    {/* Container Demo */}
                    <div>
                      <h4 className="font-semibold mb-4 flex items-center gap-2">
                        <Box className="w-4 h-4" />
                        Container Variants
                      </h4>
                      <div className="space-y-4">
                        <Container size="sm" className="bg-primary-50 dark:bg-primary-900/20 p-4 rounded-lg">
                          <p className="text-sm text-center">Container Small (max-w-screen-sm)</p>
                        </Container>
                        <Container size="md" className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
                          <p className="text-sm text-center">Container Medium (max-w-screen-md)</p>
                        </Container>
                        <Container size="lg" className="bg-success-50 dark:bg-success-900/20 p-4 rounded-lg">
                          <p className="text-sm text-center">Container Large (max-w-screen-lg)</p>
                        </Container>
                      </div>
                    </div>

                    {/* Grid Demo */}
                    <div>
                      <h4 className="font-semibold mb-4 flex items-center gap-2">
                        <Layers className="w-4 h-4" />
                        Grid System
                      </h4>
                      <div className="space-y-4">
                        <Grid cols={3} gap={4}>
                          <GridItem className="bg-primary-100 dark:bg-primary-900/30 p-4 rounded-lg text-center">
                            <p className="text-sm">Grid Item 1</p>
                          </GridItem>
                          <GridItem className="bg-blue-100 dark:bg-blue-900/30 p-4 rounded-lg text-center">
                            <p className="text-sm">Grid Item 2</p>
                          </GridItem>
                          <GridItem className="bg-success-100 dark:bg-success-900/30 p-4 rounded-lg text-center">
                            <p className="text-sm">Grid Item 3</p>
                          </GridItem>
                        </Grid>

                        <Grid cols={4} gap={3} className="lg:grid-cols-2">
                          <GridItem span={2} className="bg-warning-100 dark:bg-warning-900/30 p-4 rounded-lg text-center">
                            <p className="text-sm">Span 2 Columns</p>
                          </GridItem>
                          <GridItem className="bg-error-100 dark:bg-error-900/30 p-4 rounded-lg text-center">
                            <p className="text-sm">Item 1</p>
                          </GridItem>
                          <GridItem className="bg-gray-100 dark:bg-gray-800 p-4 rounded-lg text-center">
                            <p className="text-sm">Item 2</p>
                          </GridItem>
                        </Grid>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Buttons Demo */}
              <Card>
                <CardHeader>
                  <CardTitle>Buttons</CardTitle>
                  <CardDescription>Varianti e dimensioni dei button</CardDescription>
                </CardHeader>
                <CardContent>
                  <Grid cols={1} gap={4}>
                    <GridItem>
                      <h4 className="font-medium mb-3">Varianti</h4>
                      <div className="flex flex-wrap gap-2">
                        <Button variant="primary">Primary</Button>
                        <Button variant="secondary">Secondary</Button>
                        <Button variant="success">Success</Button>
                        <Button variant="warning">Warning</Button>
                        <Button variant="error">Error</Button>
                        <Button variant="outline">Outline</Button>
                        <Button variant="ghost">Ghost</Button>
                        <Button variant="gradient">Gradient</Button>
                      </div>
                    </GridItem>
                    <GridItem>
                      <h4 className="font-medium mb-3">Dimensioni</h4>
                      <div className="flex flex-wrap gap-2">
                        <Button size="sm">Small</Button>
                        <Button size="default">Default</Button>
                        <Button size="lg">Large</Button>
                        <Button size="xl">Extra Large</Button>
                      </div>
                    </GridItem>
                    <GridItem>
                      <h4 className="font-medium mb-3">Stati</h4>
                      <div className="flex flex-wrap gap-2">
                        <Button leftIcon={<Star className="w-4 h-4" />}>Con Icona</Button>
                        <Button loading>Loading</Button>
                        <Button disabled>Disabled</Button>
                      </div>
                    </GridItem>
                  </Grid>
                </CardContent>
              </Card>

              {/* Inputs Demo */}
              <Card>
                <CardHeader>
                  <CardTitle>Inputs</CardTitle>
                  <CardDescription>Input fields con varianti e icone</CardDescription>
                </CardHeader>
                <CardContent>
                  <Grid cols={1} md={2} gap={6}>
                    <GridItem>
                      <div className="space-y-4">
                        <Input placeholder="Input standard" />
                        <Input 
                          placeholder="Con icona sinistra" 
                          leftIcon={<Search className="w-4 h-4" />} 
                        />
                        <Input 
                          type="email"
                          placeholder="Email"
                          leftIcon={<Mail className="w-4 h-4" />}
                          label="Email"
                        />
                      </div>
                    </GridItem>
                    <GridItem>
                      <div className="space-y-4">
                        <Input 
                          type="password"
                          placeholder="Password"
                          leftIcon={<Lock className="w-4 h-4" />}
                          label="Password"
                          helperText="Minimo 8 caratteri"
                        />
                        <Input 
                          placeholder="Input con errore"
                          error="Questo campo è obbligatorio"
                          variant="error"
                        />
                      </div>
                    </GridItem>
                  </Grid>
                </CardContent>
              </Card>

              {/* Cards Demo */}
              <Card>
                <CardHeader>
                  <CardTitle>Cards</CardTitle>
                  <CardDescription>Varianti di card con contenuto</CardDescription>
                </CardHeader>
                <CardContent>
                  <Grid cols={1} md={3} gap={4}>
                    <GridItem>
                      <Card variant="default">
                        <CardContent className="pt-6">
                          <h4 className="font-semibold mb-2">Card Standard</h4>
                          <p className="text-sm text-gray-600 dark:text-gray-300">
                            Contenuto della card standard
                          </p>
                        </CardContent>
                      </Card>
                    </GridItem>
                    <GridItem>
                      <Card variant="elevated" hover>
                        <CardContent className="pt-6">
                          <h4 className="font-semibold mb-2">Card Elevated</h4>
                          <p className="text-sm text-gray-600 dark:text-gray-300">
                            Card con ombra e hover effect
                          </p>
                        </CardContent>
                      </Card>
                    </GridItem>
                    <GridItem>
                      <Card variant="gradient">
                        <CardContent className="pt-6">
                          <h4 className="font-semibold mb-2">Card Gradient</h4>
                          <p className="text-sm text-gray-600 dark:text-gray-300">
                            Card con sfondo gradiente
                          </p>
                        </CardContent>
                      </Card>
                    </GridItem>
                  </Grid>
                </CardContent>
              </Card>

              {/* Other Components */}
              <Grid cols={1} md={2} gap={6}>
                <GridItem>
                  <Card>
                    <CardHeader>
                      <CardTitle>Alerts</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-3">
                        <Alert variant="default">
                          <AlertDescription>Alert standard</AlertDescription>
                        </Alert>
                        <Alert variant="success">
                          <AlertDescription>Operazione completata!</AlertDescription>
                        </Alert>
                        <Alert variant="warning">
                          <AlertDescription>Attenzione richiesta</AlertDescription>
                        </Alert>
                        <Alert variant="error">
                          <AlertDescription>Errore verificato</AlertDescription>
                        </Alert>
                      </div>
                    </CardContent>
                  </Card>
                </GridItem>
                <GridItem>
                  <Card>
                    <CardHeader>
                      <CardTitle>Spinners</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-4">
                        <div className="flex items-center gap-4">
                          <Spinner size="sm" />
                          <Spinner size="default" />
                          <Spinner size="lg" />
                        </div>
                        <div className="flex items-center gap-4">
                          <Spinner variant="primary" />
                          <Spinner variant="warning" />
                          <Spinner variant="success" />
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </GridItem>
              </Grid>
            </div>
          </Container>
        )}

        {/* Features Section */}
        <Container className="py-16">
          <h2 className="text-3xl font-bold text-center text-gray-900 dark:text-white mb-12">
            ✨ Caratteristiche Principali
          </h2>
          
          <Grid cols={1} md={2} lg={3} gap={6}>
            <GridItem>
              <Card hover className="h-full">
                <CardContent className="pt-6">
                  <div className="w-12 h-12 bg-gradient-primary rounded-lg flex items-center justify-center mb-4">
                    <BookOpen className="w-6 h-6 text-white" />
                  </div>
                  <CardTitle className="mb-2">Apprendimento Personalizzato</CardTitle>
                  <CardDescription>
                    AI che si adatta al tuo stile di apprendimento per un'esperienza unica
                  </CardDescription>
                </CardContent>
              </Card>
            </GridItem>
            <GridItem>
              <Card hover className="h-full">
                <CardContent className="pt-6">
                  <div className="w-12 h-12 bg-gradient-secondary rounded-lg flex items-center justify-center mb-4">
                    <Users className="w-6 h-6 text-white" />
                  </div>
                  <CardTitle className="mb-2">Community Attiva</CardTitle>
                  <CardDescription>
                    Connettiti con altri studenti e condividi il tuo percorso di apprendimento
                  </CardDescription>
                </CardContent>
              </Card>
            </GridItem>
            <GridItem>
              <Card hover className="h-full">
                <CardContent className="pt-6">
                  <div className="w-12 h-12 bg-gradient-success rounded-lg flex items-center justify-center mb-4">
                    <Star className="w-6 h-6 text-white" />
                  </div>
                  <CardTitle className="mb-2">Gamification</CardTitle>
                  <CardDescription>
                    Raggiungi obiettivi, sblocca achievement e compete con i tuoi amici
                  </CardDescription>
                </CardContent>
              </Card>
            </GridItem>
          </Grid>
        </Container>

        {/* Status Section */}
        <Container className="py-16">
          <Card variant="glass" className="text-center">
            <CardContent className="pt-8">
              <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                🚀 Stato del Progetto
              </h3>
              <Grid cols={1} md={3} gap={6} className="mt-8">
                <GridItem>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-success-600 dark:text-success-400">95%</div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">Quality Score</div>
                  </div>
                </GridItem>
                <GridItem>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-primary-600 dark:text-primary-400">6/8</div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">Task Completati</div>
                  </div>
                </GridItem>
                <GridItem>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-blue-600 dark:text-blue-400">✅</div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">Build Success</div>
                  </div>
                </GridItem>
              </Grid>
            </CardContent>
          </Card>
        </Container>
      </main>

      {/* Footer */}
      <Footer />
    </div>
  );
} 
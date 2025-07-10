import { Metadata } from 'next';
import { TutorSidebar } from '@/components/tutor/TutorSidebar';
import { TutorHeader } from '@/components/tutor/TutorHeader';
import { TutorAuthGuard } from '@/components/tutor/TutorAuthGuard';

export const metadata: Metadata = {
  title: 'Dashboard Tutor - Dydat',
  description: 'Gestisci le tue sessioni di tutoring, studenti e performance su Dydat',
};

export default function TutorLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <TutorAuthGuard>
      <div className="min-h-screen bg-stone-50 dark:bg-stone-900">
        <div className="flex">
          {/* Sidebar */}
          <TutorSidebar />
          
          {/* Main Content */}
          <div className="flex-1 lg:ml-64">
            <TutorHeader />
            <main className="p-4 lg:p-6">
              {children}
            </main>
          </div>
        </div>
      </div>
    </TutorAuthGuard>
  );
} 
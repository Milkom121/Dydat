import React, { useState } from 'react';
import { TutorGrid } from './TutorGrid';
import { TutoringFilters } from './TutoringFilters';
import { QuickRequestForm } from './QuickRequestForm';
import { MyTutoringSessions } from './MyTutoringSessions';
import { TutoringStats } from './TutoringStats';
import { useUserRoles } from '../../hooks/useUserRoles';

export const TutoringMarketplace: React.FC = () => {
  const [activeTab, setActiveTab] = useState('find-tutor');
  const [searchQuery, setSearchQuery] = useState('');
  const [filters, setFilters] = useState({
    specialization: '',
    priceRange: '',
    availability: '',
    rating: '',
    language: 'it',
    verificationLevel: ''
  });
  const [sortBy, setSortBy] = useState('rating');

  const { hasPermission } = useUserRoles();

  const tabs = [
    { id: 'find-tutor', label: 'Trova Tutor', icon: '🔍' },
    { id: 'my-sessions', label: 'Le Mie Sessioni', icon: '📚' },
    { id: 'quick-request', label: 'Richiesta Rapida', icon: '⚡' },
    ...(hasPermission('canOfferTutoring') ? [
      { id: 'my-tutoring', label: 'I Miei Studenti', icon: '👨‍🏫' }
    ] : [])
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-50 via-emerald-50/20 to-teal-50/10 dark:from-stone-950 dark:via-stone-900 dark:to-stone-900">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 via-teal-500/5 to-cyan-500/5 dark:from-emerald-400/5 dark:via-teal-400/5 dark:to-cyan-400/5"></div>
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_60%_40%,rgba(16,185,129,0.1),transparent_50%)] dark:bg-[radial-gradient(circle_at_60%_40%,rgba(16,185,129,0.05),transparent_50%)]"></div>
        
        <div className="relative max-w-7xl mx-auto px-6 py-16">
          <div className="text-center mb-12">
            <div className="inline-flex items-center space-x-2 bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm px-4 py-2 rounded-full border border-emerald-200/50 dark:border-emerald-800/50 mb-6">
              <div className="w-2 h-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full animate-pulse"></div>
              <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">Mercatino del Tutoraggio</span>
            </div>
            
            <h1 className="text-5xl md:text-6xl font-bold bg-gradient-to-r from-stone-900 via-emerald-800 to-teal-800 dark:from-stone-100 dark:via-emerald-200 dark:to-teal-200 bg-clip-text text-transparent mb-6 leading-tight">
              Impara con i Migliori
            </h1>
            <p className="text-xl text-stone-600 dark:text-stone-300 max-w-3xl mx-auto leading-relaxed">
              Connettiti con <span className="font-semibold text-emerald-700 dark:text-emerald-300">tutor esperti</span> per 
              sessioni personalizzate. Risolvi dubbi, approfondisci argomenti e accelera il tuo apprendimento.
            </p>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-4xl mx-auto">
            <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
              <div className="text-3xl font-bold text-emerald-600 dark:text-emerald-400 mb-1">500+</div>
              <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Tutor Attivi</div>
            </div>
            <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
              <div className="text-3xl font-bold text-teal-600 dark:text-teal-400 mb-1">50+</div>
              <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Materie</div>
            </div>
            <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
              <div className="text-3xl font-bold text-cyan-600 dark:text-cyan-400 mb-1">4.8</div>
              <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Rating Medio</div>
            </div>
            <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
              <div className="text-3xl font-bold text-purple-600 dark:text-purple-400 mb-1">24/7</div>
              <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Disponibilità</div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Navigation Tabs */}
        <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-2 mb-8">
          <div className="flex flex-wrap gap-2">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center space-x-3 px-6 py-3 rounded-xl font-medium transition-all duration-200 ${
                  activeTab === tab.id
                    ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white shadow-lg'
                    : 'text-stone-600 dark:text-stone-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 hover:text-emerald-600 dark:hover:text-emerald-400'
                }`}
              >
                <span className="text-lg">{tab.icon}</span>
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Content based on active tab */}
        <div className="space-y-8">
          {activeTab === 'find-tutor' && (
            <>
              <TutoringFilters
                searchQuery={searchQuery}
                onSearch={setSearchQuery}
                filters={filters}
                onFilterChange={(key, value) => setFilters(prev => ({ ...prev, [key]: value }))}
                sortBy={sortBy}
                onSortChange={setSortBy}
              />
              <TutorGrid
                searchQuery={searchQuery}
                filters={filters}
                sortBy={sortBy}
              />
            </>
          )}

          {activeTab === 'my-sessions' && (
            <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
              <div className="lg:col-span-3">
                <MyTutoringSessions />
              </div>
              <div>
                <TutoringStats />
              </div>
            </div>
          )}

          {activeTab === 'quick-request' && (
            <div className="max-w-4xl mx-auto">
              <QuickRequestForm />
            </div>
          )}

          {activeTab === 'my-tutoring' && hasPermission('canOfferTutoring') && (
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8 text-center">
              <div className="text-6xl mb-4">👨‍🏫</div>
              <h3 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Dashboard Tutor
              </h3>
              <p className="text-stone-600 dark:text-stone-400 mb-6">
                Gestisci le tue sessioni di tutoraggio, visualizza le statistiche e interagisci con i tuoi studenti.
              </p>
              <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-8 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
                Accedi alla Dashboard
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
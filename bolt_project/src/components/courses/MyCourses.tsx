import React, { useState } from 'react';
import { CourseProgress } from './CourseProgress';
import { CourseFilters } from './CourseFilters';
import { CourseGrid } from './CourseGrid';
import { StudyStats } from './StudyStats';
import { RecentActivity } from './RecentActivity';
import { LearningGoals } from './LearningGoals';

export const MyCourses: React.FC = () => {
  const [activeTab, setActiveTab] = useState('all');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [sortBy, setSortBy] = useState('recent');
  const [searchQuery, setSearchQuery] = useState('');

  const tabs = [
    { id: 'all', label: 'Tutti i Corsi', count: 12 },
    { id: 'in-progress', label: 'In Corso', count: 5 },
    { id: 'completed', label: 'Completati', count: 4 },
    { id: 'wishlist', label: 'Lista Desideri', count: 8 },
    { id: 'certificates', label: 'Certificati', count: 3 }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-50 via-amber-50/20 to-orange-50/10 dark:from-stone-950 dark:via-stone-900 dark:to-stone-900">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-amber-500/5 via-orange-500/5 to-red-500/5 dark:from-amber-400/5 dark:via-orange-400/5 dark:to-red-400/5"></div>
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_70%_30%,rgba(251,191,36,0.1),transparent_50%)] dark:bg-[radial-gradient(circle_at_70%_30%,rgba(251,191,36,0.05),transparent_50%)]"></div>
        
        <div className="relative max-w-7xl mx-auto px-6 py-12">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-8">
            <div>
              <div className="inline-flex items-center space-x-2 bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm px-4 py-2 rounded-full border border-amber-200/50 dark:border-amber-800/50 mb-4">
                <div className="w-2 h-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full animate-pulse"></div>
                <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">Il Tuo Percorso</span>
              </div>
              
              <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-stone-900 via-amber-800 to-orange-800 dark:from-stone-100 dark:via-amber-200 dark:to-orange-200 bg-clip-text text-transparent mb-4 leading-tight">
                I Miei Corsi
              </h1>
              <p className="text-xl text-stone-600 dark:text-stone-300 max-w-2xl leading-relaxed">
                Continua il tuo percorso di apprendimento e monitora i tuoi progressi verso il successo.
              </p>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-amber-600 dark:text-amber-400 mb-1">12</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Corsi Totali</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-emerald-600 dark:text-emerald-400 mb-1">5</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">In Corso</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-blue-600 dark:text-blue-400 mb-1">4</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Completati</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-purple-600 dark:text-purple-400 mb-1">68%</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Completamento</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-3 space-y-8">
            {/* Navigation Tabs */}
            <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-2">
              <div className="flex flex-wrap gap-2">
                {tabs.map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`flex items-center space-x-2 px-6 py-3 rounded-xl font-medium transition-all duration-200 ${
                      activeTab === tab.id
                        ? 'bg-gradient-to-r from-amber-400 to-orange-500 text-white shadow-lg'
                        : 'text-stone-600 dark:text-stone-400 hover:bg-amber-50 dark:hover:bg-amber-900/20 hover:text-amber-600 dark:hover:text-amber-400'
                    }`}
                  >
                    <span>{tab.label}</span>
                    <span className={`text-xs px-2 py-1 rounded-full ${
                      activeTab === tab.id
                        ? 'bg-white/20 text-white'
                        : 'bg-stone-200 dark:bg-stone-700 text-stone-600 dark:text-stone-400'
                    }`}>
                      {tab.count}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Filters and Controls */}
            <CourseFilters
              searchQuery={searchQuery}
              onSearch={setSearchQuery}
              viewMode={viewMode}
              onViewModeChange={setViewMode}
              sortBy={sortBy}
              onSortChange={setSortBy}
            />

            {/* Course Progress Overview */}
            {activeTab === 'in-progress' && <CourseProgress />}

            {/* Course Grid */}
            <CourseGrid
              activeTab={activeTab}
              viewMode={viewMode}
              sortBy={sortBy}
              searchQuery={searchQuery}
            />
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            <StudyStats />
            <LearningGoals />
            <RecentActivity />
          </div>
        </div>
      </div>
    </div>
  );
};
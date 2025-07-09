import React, { useState } from 'react';
import { SearchFilters } from './SearchFilters';
import { CourseGrid } from './CourseGrid';
import { FeaturedCourses } from './FeaturedCourses';
import { PersonalizedRecommendations } from './PersonalizedRecommendations';
import { TrendingTopics } from './TrendingTopics';

export const CourseMarketplace: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilters, setActiveFilters] = useState({
    category: '',
    level: '',
    duration: '',
    price: '',
    rating: '',
    language: 'it'
  });
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [sortBy, setSortBy] = useState('relevance');

  const handleSearch = (query: string) => {
    setSearchQuery(query);
  };

  const handleFilterChange = (filterType: string, value: string) => {
    setActiveFilters(prev => ({
      ...prev,
      [filterType]: value
    }));
  };

  const clearFilters = () => {
    setActiveFilters({
      category: '',
      level: '',
      duration: '',
      price: '',
      rating: '',
      language: 'it'
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-50 via-amber-50/30 to-orange-50/20 dark:from-stone-950 dark:via-stone-900 dark:to-stone-900">
      {/* Hero Section with Search */}
      <div className="relative overflow-hidden">
        {/* Background Pattern */}
        <div className="absolute inset-0 bg-gradient-to-br from-amber-500/5 via-orange-500/5 to-red-500/5 dark:from-amber-400/5 dark:via-orange-400/5 dark:to-red-400/5"></div>
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(251,191,36,0.1),transparent_50%)] dark:bg-[radial-gradient(circle_at_30%_20%,rgba(251,191,36,0.05),transparent_50%)]"></div>
        
        <div className="relative max-w-7xl mx-auto px-6 py-16">
          <div className="text-center mb-12">
            <div className="inline-flex items-center space-x-2 bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm px-4 py-2 rounded-full border border-amber-200/50 dark:border-amber-800/50 mb-6">
              <div className="w-2 h-2 bg-gradient-to-r from-amber-400 to-orange-500 rounded-full animate-pulse"></div>
              <span className="text-sm font-medium text-amber-700 dark:text-amber-300">Marketplace Premium</span>
            </div>
            
            <h1 className="text-5xl md:text-6xl font-bold bg-gradient-to-r from-stone-900 via-amber-800 to-orange-800 dark:from-stone-100 dark:via-amber-200 dark:to-orange-200 bg-clip-text text-transparent mb-6 leading-tight">
              Catalogo Corsi
            </h1>
            <p className="text-xl text-stone-600 dark:text-stone-300 max-w-3xl mx-auto leading-relaxed">
              Scopri <span className="font-semibold text-amber-700 dark:text-amber-300">migliaia di corsi</span> personalizzati per te. 
              Acquista corsi completi o singole lezioni per un apprendimento su misura.
            </p>
          </div>
          
          <SearchFilters
            searchQuery={searchQuery}
            onSearch={handleSearch}
            activeFilters={activeFilters}
            onFilterChange={handleFilterChange}
            onClearFilters={clearFilters}
            viewMode={viewMode}
            onViewModeChange={setViewMode}
            sortBy={sortBy}
            onSortChange={setSortBy}
          />
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-12">
        {/* Personalized Recommendations */}
        {!searchQuery && (
          <>
            <PersonalizedRecommendations />
            <FeaturedCourses />
            <TrendingTopics />
          </>
        )}

        {/* Course Results */}
        <CourseGrid
          searchQuery={searchQuery}
          filters={activeFilters}
          viewMode={viewMode}
          sortBy={sortBy}
        />
      </div>
    </div>
  );
}; 
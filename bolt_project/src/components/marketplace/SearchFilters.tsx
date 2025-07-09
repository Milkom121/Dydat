import React, { useState } from 'react';
import { Search, Filter, Grid, List, SlidersHorizontal, X } from 'lucide-react';

interface SearchFiltersProps {
  searchQuery: string;
  onSearch: (query: string) => void;
  activeFilters: any;
  onFilterChange: (filterType: string, value: string) => void;
  onClearFilters: () => void;
  viewMode: 'grid' | 'list';
  onViewModeChange: (mode: 'grid' | 'list') => void;
  sortBy: string;
  onSortChange: (sort: string) => void;
}

export const SearchFilters: React.FC<SearchFiltersProps> = ({
  searchQuery,
  onSearch,
  activeFilters,
  onFilterChange,
  onClearFilters,
  viewMode,
  onViewModeChange,
  sortBy,
  onSortChange
}) => {
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);

  const categories = [
    'Programmazione', 'Design', 'Marketing', 'Business', 'Data Science',
    'Lingue', 'Fotografia', 'Musica', 'Cucina', 'Fitness'
  ];

  const levels = ['Principiante', 'Intermedio', 'Avanzato', 'Esperto'];
  const durations = ['< 2 ore', '2-5 ore', '5-10 ore', '10-20 ore', '20+ ore'];
  const priceRanges = ['Gratuito', '€1-€25', '€25-€50', '€50-€100', '€100+'];
  const ratings = ['4.5+', '4.0+', '3.5+', '3.0+'];

  const sortOptions = [
    { value: 'relevance', label: 'Rilevanza' },
    { value: 'rating', label: 'Valutazione' },
    { value: 'price_low', label: 'Prezzo: dal più basso' },
    { value: 'price_high', label: 'Prezzo: dal più alto' },
    { value: 'newest', label: 'Più recenti' },
    { value: 'popular', label: 'Più popolari' }
  ];

  const activeFilterCount = Object.values(activeFilters).filter(value => value && value !== 'it').length;

  return (
    <div className="space-y-8">
      {/* Main Search Bar */}
      <div className="relative max-w-3xl mx-auto">
        <div className="relative group">
          <Search className="absolute left-6 top-1/2 transform -translate-y-1/2 w-6 h-6 text-amber-500 dark:text-amber-400 transition-colors group-focus-within:text-amber-600 dark:group-focus-within:text-amber-300" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearch(e.target.value)}
            placeholder="Cerca corsi, argomenti, istruttori..."
            className="w-full pl-16 pr-6 py-5 text-lg bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm border-2 border-white/50 dark:border-stone-800/50 rounded-2xl text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 focus:bg-white dark:focus:bg-stone-900 transition-all duration-300 shadow-lg hover:shadow-xl"
          />
          <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-amber-400/10 to-orange-400/10 opacity-0 group-focus-within:opacity-100 transition-opacity duration-300 pointer-events-none"></div>
        </div>
      </div>

      {/* Quick Filters Pills */}
      <div className="flex flex-wrap justify-center gap-3 max-w-4xl mx-auto">
        {['Programmazione', 'Design', 'Marketing', 'AI & Data Science', 'Business'].map((category) => (
          <button
            key={category}
            onClick={() => onFilterChange('category', activeFilters.category === category ? '' : category)}
            className={`px-6 py-3 rounded-full text-sm font-medium transition-all duration-200 ${
              activeFilters.category === category
                ? 'bg-gradient-to-r from-amber-400 to-orange-500 text-white shadow-lg transform scale-105'
                : 'bg-white/80 dark:bg-stone-800/80 backdrop-blur-sm text-stone-700 dark:text-stone-300 border border-stone-200/50 dark:border-stone-700/50 hover:bg-amber-50 dark:hover:bg-amber-900/20 hover:border-amber-300 dark:hover:border-amber-600'
            }`}
          >
            {category}
          </button>
        ))}
      </div>

      {/* Advanced Controls */}
      <div className="bg-white/60 dark:bg-stone-900/60 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 shadow-lg">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center space-x-4">
            <button
              onClick={() => setShowAdvancedFilters(!showAdvancedFilters)}
              className={`flex items-center space-x-3 px-6 py-3 rounded-xl border-2 transition-all duration-200 ${
                showAdvancedFilters || activeFilterCount > 0
                  ? 'bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20 border-amber-300 dark:border-amber-600 text-amber-700 dark:text-amber-300 shadow-md'
                  : 'bg-white/80 dark:bg-stone-800/80 border-stone-200/50 dark:border-stone-700/50 text-stone-600 dark:text-stone-400 hover:bg-stone-50 dark:hover:bg-stone-700/50'
              }`}
            >
              <SlidersHorizontal className="w-5 h-5" />
              <span className="font-medium">Filtri Avanzati</span>
              {activeFilterCount > 0 && (
                <span className="bg-gradient-to-r from-amber-500 to-orange-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-sm">
                  {activeFilterCount}
                </span>
              )}
            </button>

            {activeFilterCount > 0 && (
              <button
                onClick={onClearFilters}
                className="flex items-center space-x-2 text-stone-500 dark:text-stone-400 hover:text-red-600 dark:hover:text-red-400 transition-colors px-4 py-2 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20"
              >
                <X className="w-4 h-4" />
                <span className="text-sm font-medium">Cancella filtri</span>
              </button>
            )}
          </div>

          <div className="flex items-center space-x-4">
            {/* Sort Dropdown */}
            <div className="relative">
              <select
                value={sortBy}
                onChange={(e) => onSortChange(e.target.value)}
                className="appearance-none px-6 py-3 pr-12 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/80 dark:bg-stone-800/80 backdrop-blur-sm text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200 font-medium"
              >
                {sortOptions.map(option => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
              <div className="absolute right-4 top-1/2 transform -translate-y-1/2 pointer-events-none">
                <svg className="w-4 h-4 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </div>

            {/* View Mode Toggle */}
            <div className="flex border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl overflow-hidden bg-white/80 dark:bg-stone-800/80 backdrop-blur-sm">
              <button
                onClick={() => onViewModeChange('grid')}
                className={`p-3 transition-all duration-200 ${
                  viewMode === 'grid'
                    ? 'bg-gradient-to-r from-amber-400 to-orange-500 text-white shadow-md'
                    : 'text-stone-600 dark:text-stone-400 hover:bg-amber-50 dark:hover:bg-amber-900/20'
                }`}
              >
                <Grid className="w-5 h-5" />
              </button>
              <button
                onClick={() => onViewModeChange('list')}
                className={`p-3 transition-all duration-200 ${
                  viewMode === 'list'
                    ? 'bg-gradient-to-r from-amber-400 to-orange-500 text-white shadow-md'
                    : 'text-stone-600 dark:text-stone-400 hover:bg-amber-50 dark:hover:bg-amber-900/20'
                }`}
              >
                <List className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Advanced Filters Panel */}
      {showAdvancedFilters && (
        <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-8 border-2 border-amber-200/30 dark:border-amber-800/30 shadow-xl space-y-8">
          <div className="text-center">
            <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-2">Filtri Avanzati</h3>
            <p className="text-stone-600 dark:text-stone-400">Personalizza la tua ricerca per trovare il corso perfetto</p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
            {/* Category Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Categoria
              </label>
              <select
                value={activeFilters.category}
                onChange={(e) => onFilterChange('category', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200"
              >
                <option value="">Tutte le categorie</option>
                {categories.map(category => (
                  <option key={category} value={category}>{category}</option>
                ))}
              </select>
            </div>

            {/* Level Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Livello
              </label>
              <select
                value={activeFilters.level}
                onChange={(e) => onFilterChange('level', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200"
              >
                <option value="">Tutti i livelli</option>
                {levels.map(level => (
                  <option key={level} value={level}>{level}</option>
                ))}
              </select>
            </div>

            {/* Duration Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Durata
              </label>
              <select
                value={activeFilters.duration}
                onChange={(e) => onFilterChange('duration', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200"
              >
                <option value="">Qualsiasi durata</option>
                {durations.map(duration => (
                  <option key={duration} value={duration}>{duration}</option>
                ))}
              </select>
            </div>

            {/* Price Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Prezzo
              </label>
              <select
                value={activeFilters.price}
                onChange={(e) => onFilterChange('price', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200"
              >
                <option value="">Qualsiasi prezzo</option>
                {priceRanges.map(range => (
                  <option key={range} value={range}>{range}</option>
                ))}
              </select>
            </div>

            {/* Rating Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Valutazione
              </label>
              <select
                value={activeFilters.rating}
                onChange={(e) => onFilterChange('rating', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200"
              >
                <option value="">Qualsiasi valutazione</option>
                {ratings.map(rating => (
                  <option key={rating} value={rating}>{rating} stelle e più</option>
                ))}
              </select>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
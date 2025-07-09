import React, { useState } from 'react';
import { Search, Filter, SlidersHorizontal, X, Star } from 'lucide-react';

interface TutoringFiltersProps {
  searchQuery: string;
  onSearch: (query: string) => void;
  filters: any;
  onFilterChange: (filterType: string, value: string) => void;
  sortBy: string;
  onSortChange: (sort: string) => void;
}

export const TutoringFilters: React.FC<TutoringFiltersProps> = ({
  searchQuery,
  onSearch,
  filters,
  onFilterChange,
  sortBy,
  onSortChange
}) => {
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);

  const specializations = [
    'Programmazione', 'Matematica', 'Fisica', 'Chimica', 'Inglese',
    'Spagnolo', 'Francese', 'Storia', 'Geografia', 'Filosofia',
    'Design', 'Marketing', 'Business', 'Data Science', 'AI & Machine Learning'
  ];

  const priceRanges = ['€10-€20/h', '€20-€30/h', '€30-€50/h', '€50-€80/h', '€80+/h'];
  const availabilities = ['Mattino', 'Pomeriggio', 'Sera', 'Weekend', '24/7'];
  const ratings = ['4.8+', '4.5+', '4.0+', '3.5+'];
  const verificationLevels = ['Verificato', 'Esperto', 'Certificato', 'Premium'];

  const sortOptions = [
    { value: 'rating', label: 'Valutazione' },
    { value: 'price_low', label: 'Prezzo più basso' },
    { value: 'price_high', label: 'Prezzo più alto' },
    { value: 'experience', label: 'Esperienza' },
    { value: 'sessions', label: 'Numero sessioni' },
    { value: 'availability', label: 'Disponibilità' }
  ];

  const activeFilterCount = Object.values(filters).filter(value => value && value !== 'it').length;

  return (
    <div className="space-y-6">
      {/* Main Search Bar */}
      <div className="relative max-w-4xl mx-auto">
        <div className="relative group">
          <Search className="absolute left-6 top-1/2 transform -translate-y-1/2 w-6 h-6 text-emerald-500 dark:text-emerald-400 transition-colors group-focus-within:text-emerald-600 dark:group-focus-within:text-emerald-300" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearch(e.target.value)}
            placeholder="Cerca tutor per materia, nome, competenze..."
            className="w-full pl-16 pr-6 py-5 text-lg bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm border-2 border-white/50 dark:border-stone-800/50 rounded-2xl text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 focus:bg-white dark:focus:bg-stone-900 transition-all duration-300 shadow-lg hover:shadow-xl"
          />
          <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-emerald-400/10 to-teal-400/10 opacity-0 group-focus-within:opacity-100 transition-opacity duration-300 pointer-events-none"></div>
        </div>
      </div>

      {/* Quick Filters Pills */}
      <div className="flex flex-wrap justify-center gap-3 max-w-5xl mx-auto">
        {['Programmazione', 'Matematica', 'Inglese', 'Design', 'Data Science', 'Business'].map((specialization) => (
          <button
            key={specialization}
            onClick={() => onFilterChange('specialization', filters.specialization === specialization ? '' : specialization)}
            className={`px-6 py-3 rounded-full text-sm font-medium transition-all duration-200 ${
              filters.specialization === specialization
                ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white shadow-lg transform scale-105'
                : 'bg-white/80 dark:bg-stone-800/80 backdrop-blur-sm text-stone-700 dark:text-stone-300 border border-stone-200/50 dark:border-stone-700/50 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 hover:border-emerald-300 dark:hover:border-emerald-600'
            }`}
          >
            {specialization}
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
                  ? 'bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/20 dark:to-teal-900/20 border-emerald-300 dark:border-emerald-600 text-emerald-700 dark:text-emerald-300 shadow-md'
                  : 'bg-white/80 dark:bg-stone-800/80 border-stone-200/50 dark:border-stone-700/50 text-stone-600 dark:text-stone-400 hover:bg-stone-50 dark:hover:bg-stone-700/50'
              }`}
            >
              <SlidersHorizontal className="w-5 h-5" />
              <span className="font-medium">Filtri Avanzati</span>
              {activeFilterCount > 0 && (
                <span className="bg-gradient-to-r from-emerald-500 to-teal-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-sm">
                  {activeFilterCount}
                </span>
              )}
            </button>

            {activeFilterCount > 0 && (
              <button
                onClick={() => {
                  Object.keys(filters).forEach(key => {
                    if (key !== 'language') onFilterChange(key, '');
                  });
                }}
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
                className="appearance-none px-6 py-3 pr-12 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/80 dark:bg-stone-800/80 backdrop-blur-sm text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200 font-medium"
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
          </div>
        </div>
      </div>

      {/* Advanced Filters Panel */}
      {showAdvancedFilters && (
        <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-8 border-2 border-emerald-200/30 dark:border-emerald-800/30 shadow-xl space-y-8">
          <div className="text-center">
            <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-2">Filtri Avanzati</h3>
            <p className="text-stone-600 dark:text-stone-400">Trova il tutor perfetto per le tue esigenze</p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
            {/* Specialization Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Specializzazione
              </label>
              <select
                value={filters.specialization}
                onChange={(e) => onFilterChange('specialization', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
              >
                <option value="">Tutte le materie</option>
                {specializations.map(spec => (
                  <option key={spec} value={spec}>{spec}</option>
                ))}
              </select>
            </div>

            {/* Price Range Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Fascia di Prezzo
              </label>
              <select
                value={filters.priceRange}
                onChange={(e) => onFilterChange('priceRange', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
              >
                <option value="">Tutti i prezzi</option>
                {priceRanges.map(range => (
                  <option key={range} value={range}>{range}</option>
                ))}
              </select>
            </div>

            {/* Availability Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Disponibilità
              </label>
              <select
                value={filters.availability}
                onChange={(e) => onFilterChange('availability', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
              >
                <option value="">Qualsiasi orario</option>
                {availabilities.map(availability => (
                  <option key={availability} value={availability}>{availability}</option>
                ))}
              </select>
            </div>

            {/* Rating Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Valutazione
              </label>
              <select
                value={filters.rating}
                onChange={(e) => onFilterChange('rating', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
              >
                <option value="">Tutte le valutazioni</option>
                {ratings.map(rating => (
                  <option key={rating} value={rating}>{rating} stelle</option>
                ))}
              </select>
            </div>

            {/* Verification Level Filter */}
            <div className="space-y-3">
              <label className="block text-sm font-semibold text-stone-700 dark:text-stone-300">
                Livello di Verifica
              </label>
              <select
                value={filters.verificationLevel}
                onChange={(e) => onFilterChange('verificationLevel', e.target.value)}
                className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
              >
                <option value="">Tutti i livelli</option>
                {verificationLevels.map(level => (
                  <option key={level} value={level}>{level}</option>
                ))}
              </select>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}; 
import React from 'react';
import { Search, Filter, Star, Clock, Globe, Shield } from 'lucide-react';
import { SPECIALIZATIONS } from '../../types/tutoring';

interface TutoringFiltersProps {
  searchQuery: string;
  onSearch: (query: string) => void;
  filters: any;
  onFilterChange: (key: string, value: string) => void;
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
  const priceRanges = [
    { value: '0-50', label: '0-50 N/ora' },
    { value: '50-100', label: '50-100 N/ora' },
    { value: '100-200', label: '100-200 N/ora' },
    { value: '200+', label: '200+ N/ora' }
  ];

  const availabilityOptions = [
    { value: 'now', label: 'Disponibile ora' },
    { value: 'today', label: 'Disponibile oggi' },
    { value: 'week', label: 'Questa settimana' },
    { value: 'flexible', label: 'Flessibile' }
  ];

  const ratingOptions = [
    { value: '4.5+', label: '4.5+ stelle' },
    { value: '4.0+', label: '4.0+ stelle' },
    { value: '3.5+', label: '3.5+ stelle' }
  ];

  const verificationLevels = [
    { value: 'expert', label: 'Esperto Certificato' },
    { value: 'verified', label: 'Verificato' },
    { value: 'basic', label: 'Base' }
  ];

  const sortOptions = [
    { value: 'rating', label: 'Valutazione' },
    { value: 'price_low', label: 'Prezzo: dal più basso' },
    { value: 'price_high', label: 'Prezzo: dal più alto' },
    { value: 'experience', label: 'Esperienza' },
    { value: 'availability', label: 'Disponibilità' },
    { value: 'response_time', label: 'Tempo di risposta' }
  ];

  return (
    <div className="space-y-6">
      {/* Main Search */}
      <div className="relative max-w-2xl mx-auto">
        <Search className="absolute left-6 top-1/2 transform -translate-y-1/2 w-6 h-6 text-emerald-500 dark:text-emerald-400" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => onSearch(e.target.value)}
          placeholder="Cerca tutor per materia, nome o competenza..."
          className="w-full pl-16 pr-6 py-4 text-lg bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm border-2 border-white/50 dark:border-stone-800/50 rounded-2xl text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-300 shadow-lg"
        />
      </div>

      {/* Quick Specialization Pills */}
      <div className="flex flex-wrap justify-center gap-3 max-w-5xl mx-auto">
        {SPECIALIZATIONS.slice(0, 8).map((spec) => (
          <button
            key={spec}
            onClick={() => onFilterChange('specialization', filters.specialization === spec ? '' : spec)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
              filters.specialization === spec
                ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white shadow-md transform scale-105'
                : 'bg-white/80 dark:bg-stone-800/80 backdrop-blur-sm text-stone-700 dark:text-stone-300 border border-stone-200/50 dark:border-stone-700/50 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 hover:border-emerald-300 dark:hover:border-emerald-600'
            }`}
          >
            {spec}
          </button>
        ))}
      </div>

      {/* Advanced Filters */}
      <div className="bg-white/60 dark:bg-stone-900/60 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-4">
          {/* Specialization Dropdown */}
          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-sm font-medium text-stone-700 dark:text-stone-300">
              <Filter className="w-4 h-4" />
              <span>Materia</span>
            </label>
            <select
              value={filters.specialization}
              onChange={(e) => onFilterChange('specialization', e.target.value)}
              className="w-full px-3 py-2 border border-stone-200/50 dark:border-stone-700/50 rounded-lg bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            >
              <option value="">Tutte le materie</option>
              {SPECIALIZATIONS.map(spec => (
                <option key={spec} value={spec}>{spec}</option>
              ))}
            </select>
          </div>

          {/* Price Range */}
          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-sm font-medium text-stone-700 dark:text-stone-300">
              <span>💰</span>
              <span>Prezzo</span>
            </label>
            <select
              value={filters.priceRange}
              onChange={(e) => onFilterChange('priceRange', e.target.value)}
              className="w-full px-3 py-2 border border-stone-200/50 dark:border-stone-700/50 rounded-lg bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            >
              <option value="">Qualsiasi prezzo</option>
              {priceRanges.map(range => (
                <option key={range.value} value={range.value}>{range.label}</option>
              ))}
            </select>
          </div>

          {/* Availability */}
          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-sm font-medium text-stone-700 dark:text-stone-300">
              <Clock className="w-4 h-4" />
              <span>Disponibilità</span>
            </label>
            <select
              value={filters.availability}
              onChange={(e) => onFilterChange('availability', e.target.value)}
              className="w-full px-3 py-2 border border-stone-200/50 dark:border-stone-700/50 rounded-lg bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            >
              <option value="">Qualsiasi</option>
              {availabilityOptions.map(option => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
          </div>

          {/* Rating */}
          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-sm font-medium text-stone-700 dark:text-stone-300">
              <Star className="w-4 h-4" />
              <span>Valutazione</span>
            </label>
            <select
              value={filters.rating}
              onChange={(e) => onFilterChange('rating', e.target.value)}
              className="w-full px-3 py-2 border border-stone-200/50 dark:border-stone-700/50 rounded-lg bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            >
              <option value="">Qualsiasi</option>
              {ratingOptions.map(option => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
          </div>

          {/* Verification Level */}
          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-sm font-medium text-stone-700 dark:text-stone-300">
              <Shield className="w-4 h-4" />
              <span>Verifica</span>
            </label>
            <select
              value={filters.verificationLevel}
              onChange={(e) => onFilterChange('verificationLevel', e.target.value)}
              className="w-full px-3 py-2 border border-stone-200/50 dark:border-stone-700/50 rounded-lg bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            >
              <option value="">Tutti i livelli</option>
              {verificationLevels.map(level => (
                <option key={level.value} value={level.value}>{level.label}</option>
              ))}
            </select>
          </div>

          {/* Sort */}
          <div className="space-y-2">
            <label className="text-sm font-medium text-stone-700 dark:text-stone-300">
              Ordina per
            </label>
            <select
              value={sortBy}
              onChange={(e) => onSortChange(e.target.value)}
              className="w-full px-3 py-2 border border-stone-200/50 dark:border-stone-700/50 rounded-lg bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            >
              {sortOptions.map(option => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
          </div>
        </div>
      </div>
    </div>
  );
};
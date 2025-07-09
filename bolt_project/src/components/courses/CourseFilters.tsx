import React from 'react';
import { Search, Grid, List, Filter } from 'lucide-react';

interface CourseFiltersProps {
  searchQuery: string;
  onSearch: (query: string) => void;
  viewMode: 'grid' | 'list';
  onViewModeChange: (mode: 'grid' | 'list') => void;
  sortBy: string;
  onSortChange: (sort: string) => void;
}

export const CourseFilters: React.FC<CourseFiltersProps> = ({
  searchQuery,
  onSearch,
  viewMode,
  onViewModeChange,
  sortBy,
  onSortChange
}) => {
  const sortOptions = [
    { value: 'recent', label: 'Più Recenti' },
    { value: 'progress', label: 'Progresso' },
    { value: 'alphabetical', label: 'Alfabetico' },
    { value: 'completion', label: 'Completamento' },
    { value: 'rating', label: 'Valutazione' }
  ];

  return (
    <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        {/* Search Bar */}
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-amber-500 dark:text-amber-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearch(e.target.value)}
            placeholder="Cerca nei tuoi corsi..."
            className="w-full pl-12 pr-4 py-3 bg-white/90 dark:bg-stone-800/90 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200"
          />
        </div>

        <div className="flex items-center space-x-4">
          {/* Sort Dropdown */}
          <div className="relative">
            <select
              value={sortBy}
              onChange={(e) => onSortChange(e.target.value)}
              className="appearance-none px-4 py-3 pr-10 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 dark:focus:border-amber-500 transition-all duration-200 font-medium"
            >
              {sortOptions.map(option => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
            <div className="absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
              <svg className="w-4 h-4 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
              </svg>
            </div>
          </div>

          {/* View Mode Toggle */}
          <div className="flex border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl overflow-hidden bg-white/90 dark:bg-stone-800/90">
            <button
              onClick={() => onViewModeChange('grid')}
              className={`p-3 transition-all duration-200 ${
                viewMode === 'grid'
                  ? 'bg-gradient-to-r from-amber-400 to-orange-500 text-white'
                  : 'text-stone-600 dark:text-stone-400 hover:bg-amber-50 dark:hover:bg-amber-900/20'
              }`}
            >
              <Grid className="w-5 h-5" />
            </button>
            <button
              onClick={() => onViewModeChange('list')}
              className={`p-3 transition-all duration-200 ${
                viewMode === 'list'
                  ? 'bg-gradient-to-r from-amber-400 to-orange-500 text-white'
                  : 'text-stone-600 dark:text-stone-400 hover:bg-amber-50 dark:hover:bg-amber-900/20'
              }`}
            >
              <List className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
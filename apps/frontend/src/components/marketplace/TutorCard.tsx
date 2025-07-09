import React from 'react';
import { Star, Clock, MessageCircle, Video, BookOpen, Award, Globe } from 'lucide-react';

interface TutorCardProps {
  tutor: {
    id: number;
    name: string;
    specializations: string[];
    rating: number;
    reviewCount: number;
    completedSessions: number;
    hourlyRate: number;
    avatar: string;
    description: string;
    availability: string[];
    verificationLevel: string;
    responseTime: string;
    languages: string[];
    experience: number;
  };
}

export const TutorCard: React.FC<TutorCardProps> = ({ tutor }) => {
  const getVerificationColor = (level: string) => {
    switch (level) {
      case 'Premium':
        return 'from-purple-400 to-purple-600';
      case 'Esperto':
        return 'from-blue-400 to-blue-600';
      case 'Certificato':
        return 'from-green-400 to-green-600';
      default:
        return 'from-gray-400 to-gray-600';
    }
  };

  return (
    <div className="group bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden hover:-translate-y-1">
      {/* Header with Avatar */}
      <div className="relative p-6 bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-900/20 dark:to-teal-900/20">
        <div className="flex items-start space-x-4">
          <div className="relative">
            <img
              src={tutor.avatar}
              alt={tutor.name}
              className="w-16 h-16 rounded-xl object-cover border-2 border-white shadow-lg"
            />
            {/* Online Status */}
            <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-green-400 border-2 border-white rounded-full"></div>
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between">
              <div>
                <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100 group-hover:text-emerald-600 dark:group-hover:text-emerald-400 transition-colors">
                  {tutor.name}
                </h3>
                <div className="flex items-center space-x-2 mt-1">
                  <div className="flex items-center space-x-1 text-amber-500">
                    <Star className="w-4 h-4 fill-current" />
                    <span className="text-sm font-semibold text-stone-700 dark:text-stone-300">
                      {tutor.rating}
                    </span>
                    <span className="text-xs text-stone-500 dark:text-stone-400">
                      ({tutor.reviewCount})
                    </span>
                  </div>
                </div>
              </div>

              {/* Verification Badge */}
              <div className={`bg-gradient-to-r ${getVerificationColor(tutor.verificationLevel)} text-white px-3 py-1 rounded-full text-xs font-bold shadow-md`}>
                {tutor.verificationLevel}
              </div>
            </div>
          </div>
        </div>

        {/* Response Time */}
        <div className="mt-4 flex items-center justify-between text-xs text-stone-600 dark:text-stone-400">
          <div className="flex items-center space-x-2">
            <Clock className="w-4 h-4" />
            <span>Risponde in {tutor.responseTime}</span>
          </div>
          <div className="flex items-center space-x-2">
            <BookOpen className="w-4 h-4" />
            <span>{tutor.completedSessions} sessioni</span>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-6 space-y-4">
        {/* Specializations */}
        <div>
          <div className="flex flex-wrap gap-2">
            {tutor.specializations.slice(0, 3).map((spec, index) => (
              <span
                key={index}
                className="inline-block bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 text-xs font-medium px-3 py-1 rounded-full"
              >
                {spec}
              </span>
            ))}
            {tutor.specializations.length > 3 && (
              <span className="inline-block bg-stone-100 dark:bg-stone-800 text-stone-600 dark:text-stone-400 text-xs font-medium px-3 py-1 rounded-full">
                +{tutor.specializations.length - 3} altre
              </span>
            )}
          </div>
        </div>

        {/* Description */}
        <p className="text-sm text-stone-600 dark:text-stone-400 line-clamp-2">
          {tutor.description}
        </p>

        {/* Languages */}
        <div className="flex items-center space-x-2">
          <Globe className="w-4 h-4 text-stone-500 dark:text-stone-400" />
          <span className="text-xs text-stone-600 dark:text-stone-400">
            {tutor.languages.join(', ')}
          </span>
        </div>

        {/* Availability */}
        <div>
          <span className="text-xs font-medium text-stone-500 dark:text-stone-400 uppercase tracking-wide mb-2 block">
            Disponibilità
          </span>
          <div className="flex flex-wrap gap-1">
            {tutor.availability.map((time, index) => (
              <span
                key={index}
                className="inline-block bg-teal-100 dark:bg-teal-900/30 text-teal-700 dark:text-teal-300 text-xs font-medium px-2 py-1 rounded"
              >
                {time}
              </span>
            ))}
          </div>
        </div>

        {/* Pricing */}
        <div className="flex items-center justify-between pt-4 border-t border-stone-200 dark:border-stone-700">
          <div>
            <div className="text-2xl font-bold text-stone-900 dark:text-stone-100">
              €{tutor.hourlyRate}
              <span className="text-sm font-normal text-stone-500 dark:text-stone-400">/ora</span>
            </div>
            <div className="text-xs text-stone-500 dark:text-stone-400">
              {tutor.experience} anni di esperienza
            </div>
          </div>

          <div className="flex items-center space-x-2">
            <Award className="w-4 h-4 text-amber-500" />
            <span className="text-xs text-stone-600 dark:text-stone-400">
              Top Tutor
            </span>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex space-x-2 pt-2">
          <button className="flex-1 bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-semibold py-3 px-4 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center justify-center space-x-2">
            <Video className="w-4 h-4" />
            <span>Prenota</span>
          </button>
          <button className="flex-1 border-2 border-emerald-400 text-emerald-600 dark:text-emerald-400 font-semibold py-3 px-4 rounded-xl hover:bg-emerald-50 dark:hover:bg-emerald-900/20 transition-all duration-200 flex items-center justify-center space-x-2">
            <MessageCircle className="w-4 h-4" />
            <span>Messaggio</span>
          </button>
        </div>

        {/* Quick Actions */}
        <div className="flex justify-center space-x-4 pt-2 text-xs text-stone-500 dark:text-stone-400">
          <button className="hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">
            Vedi profilo completo
          </button>
          <span>•</span>
          <button className="hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">
            Aggiungi ai preferiti
          </button>
        </div>
      </div>
    </div>
  );
}; 
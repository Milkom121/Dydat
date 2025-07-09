import React, { useState } from 'react';
import { Star, Clock, MessageCircle, Video, Shield, Zap, Globe, Calendar } from 'lucide-react';
import { TutorProfile } from '../../types/tutoring';

interface TutorCardProps {
  tutor: TutorProfile;
}

export const TutorCard: React.FC<TutorCardProps> = ({ tutor }) => {
  const [showBookingModal, setShowBookingModal] = useState(false);

  const getVerificationIcon = (level: string) => {
    switch (level) {
      case 'expert':
        return <Shield className="w-4 h-4 text-purple-500" />;
      case 'verified':
        return <Shield className="w-4 h-4 text-blue-500" />;
      default:
        return <Shield className="w-4 h-4 text-stone-400" />;
    }
  };

  const getVerificationColor = (level: string) => {
    switch (level) {
      case 'expert':
        return 'border-purple-200 dark:border-purple-800 bg-purple-50 dark:bg-purple-900/10';
      case 'verified':
        return 'border-blue-200 dark:border-blue-800 bg-blue-50 dark:bg-blue-900/10';
      default:
        return 'border-stone-200 dark:border-stone-800 bg-stone-50 dark:bg-stone-900/10';
    }
  };

  return (
    <div className={`group bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border-2 ${getVerificationColor(tutor.verificationLevel)} overflow-hidden hover:shadow-xl transition-all duration-300 hover:scale-105`}>
      {/* Header with Avatar and Status */}
      <div className="relative p-6 pb-4">
        <div className="flex items-start space-x-4">
          <div className="relative">
            <img 
              src={tutor.avatar}
              alt={tutor.name}
              className="w-16 h-16 rounded-full object-cover border-3 border-white dark:border-stone-800 shadow-lg"
            />
            {/* Online Status */}
            <div className={`absolute -bottom-1 -right-1 w-5 h-5 rounded-full border-2 border-white dark:border-stone-800 ${
              tutor.isOnline ? 'bg-emerald-500' : 'bg-stone-400'
            }`}></div>
          </div>
          
          <div className="flex-1 min-w-0">
            <div className="flex items-center space-x-2 mb-1">
              <h3 className="font-bold text-lg text-stone-900 dark:text-stone-100 truncate">
                {tutor.name}
              </h3>
              {getVerificationIcon(tutor.verificationLevel)}
            </div>
            <p className="text-sm text-stone-600 dark:text-stone-400 mb-2 line-clamp-2">
              {tutor.title}
            </p>
            
            {/* Rating and Stats */}
            <div className="flex items-center space-x-4 text-sm">
              <div className="flex items-center space-x-1">
                <Star className="w-4 h-4 fill-current text-amber-400" />
                <span className="font-medium text-stone-900 dark:text-stone-100">{tutor.rating}</span>
                <span className="text-stone-500 dark:text-stone-500">({tutor.reviewCount})</span>
              </div>
              <div className="flex items-center space-x-1 text-stone-500 dark:text-stone-500">
                <Clock className="w-4 h-4" />
                <span>{tutor.responseTime}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Badges */}
        {tutor.badges.length > 0 && (
          <div className="flex flex-wrap gap-2 mt-4">
            {tutor.badges.slice(0, 2).map((badge) => (
              <div 
                key={badge.id}
                className="flex items-center space-x-1 bg-gradient-to-r from-amber-100 to-orange-100 dark:from-amber-900/20 dark:to-orange-900/20 px-2 py-1 rounded-full border border-amber-200/50 dark:border-amber-800/50"
              >
                <span className="text-xs">{badge.icon}</span>
                <span className="text-xs font-medium text-amber-700 dark:text-amber-300">{badge.name}</span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Specializations */}
      <div className="px-6 pb-4">
        <div className="flex flex-wrap gap-2">
          {tutor.specializations.slice(0, 3).map((spec) => (
            <span 
              key={spec}
              className="text-xs font-medium bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 px-2 py-1 rounded-full"
            >
              {spec}
            </span>
          ))}
          {tutor.specializations.length > 3 && (
            <span className="text-xs font-medium text-stone-500 dark:text-stone-500 px-2 py-1">
              +{tutor.specializations.length - 3} altre
            </span>
          )}
        </div>
      </div>

      {/* Bio */}
      <div className="px-6 pb-4">
        <p className="text-sm text-stone-600 dark:text-stone-400 line-clamp-3">
          {tutor.bio}
        </p>
      </div>

      {/* Pricing and Availability */}
      <div className="px-6 pb-4">
        <div className="flex items-center justify-between mb-3">
          <div>
            <div className="text-lg font-bold text-stone-900 dark:text-stone-100">
              {tutor.pricing.baseRate} N/ora
            </div>
            <div className="text-xs text-stone-500 dark:text-stone-500">
              da {Math.min(...tutor.pricing.sessionTypes.map(s => s.price))} N
            </div>
          </div>
          <div className="text-right">
            <div className={`text-sm font-medium ${tutor.isOnline ? 'text-emerald-600 dark:text-emerald-400' : 'text-stone-500 dark:text-stone-500'}`}>
              {tutor.isOnline ? 'Online ora' : 'Offline'}
            </div>
            {tutor.availability.nextAvailable && (
              <div className="text-xs text-stone-500 dark:text-stone-500">
                Disponibile {new Date(tutor.availability.nextAvailable).toLocaleTimeString('it-IT', { 
                  hour: '2-digit', 
                  minute: '2-digit' 
                })}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="px-6 pb-6 space-y-3">
        <button
          onClick={() => setShowBookingModal(true)}
          className="w-full bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-4 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 transform hover:scale-105 shadow-lg flex items-center justify-center space-x-2"
        >
          <Calendar className="w-4 h-4" />
          <span>Prenota Sessione</span>
        </button>
        
        <div className="grid grid-cols-2 gap-2">
          <button className="flex items-center justify-center space-x-2 py-2 px-3 border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors text-sm font-medium">
            <MessageCircle className="w-4 h-4" />
            <span>Messaggio</span>
          </button>
          <button className="flex items-center justify-center space-x-2 py-2 px-3 border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors text-sm font-medium">
            <Video className="w-4 h-4" />
            <span>Profilo</span>
          </button>
        </div>
      </div>

      {/* Languages */}
      <div className="px-6 pb-6 border-t border-stone-200/50 dark:border-stone-800/50 pt-4">
        <div className="flex items-center space-x-2">
          <Globe className="w-4 h-4 text-stone-500 dark:text-stone-500" />
          <div className="flex space-x-2">
            {tutor.languages.map((lang) => (
              <span 
                key={lang}
                className="text-xs text-stone-600 dark:text-stone-400 bg-stone-100 dark:bg-stone-800 px-2 py-1 rounded"
              >
                {lang}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* Experience Footer */}
      <div className="bg-stone-50/50 dark:bg-stone-800/50 px-6 py-3 text-center">
        <div className="text-xs text-stone-500 dark:text-stone-500">
          {tutor.experience} anni di esperienza • {tutor.totalSessions} sessioni completate
        </div>
      </div>
    </div>
  );
};
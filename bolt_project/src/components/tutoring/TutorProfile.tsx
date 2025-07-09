import React, { useState } from 'react';
import { Edit, Star, Globe, Clock, Zap, Award, Users, TrendingUp, Save, X } from 'lucide-react';
import { SPECIALIZATIONS } from '../../types/tutoring';

export const TutorProfile: React.FC = () => {
  const [isEditing, setIsEditing] = useState(false);
  const [profileData, setProfileData] = useState({
    name: 'Dr. Elena Rossi',
    title: 'Esperta in Matematica e Fisica',
    bio: 'Dottorato in Fisica Teorica con 8 anni di esperienza nell\'insegnamento. Specializzata in matematica avanzata e fisica quantistica. Appassionata di rendere comprensibili anche i concetti più complessi.',
    specializations: ['Matematica', 'Fisica', 'Calcolo', 'Algebra Lineare'],
    languages: ['Italiano', 'Inglese'],
    baseRate: 80,
    sessionTypes: [
      { id: '1', name: 'Aiuto Rapido', duration: 30, price: 40, description: 'Risolvi un dubbio specifico' },
      { id: '2', name: 'Lezione Standard', duration: 60, price: 80, description: 'Approfondimento completo' },
      { id: '3', name: 'Sessione Intensiva', duration: 90, price: 110, description: 'Studio approfondito' }
    ]
  });

  const stats = {
    rating: 4.9,
    reviewCount: 127,
    totalSessions: 450,
    totalStudents: 89,
    responseTime: 'Entro 1 ora',
    completionRate: 98
  };

  const recentReviews = [
    {
      id: '1',
      studentName: 'Marco V.',
      rating: 5,
      comment: 'Spiegazione eccellente! Finalmente ho capito i limiti. Grazie Elena!',
      subject: 'Matematica',
      date: '2 giorni fa'
    },
    {
      id: '2',
      studentName: 'Laura R.',
      rating: 5,
      comment: 'Molto paziente e preparata. Mi ha aiutato tantissimo con la fisica quantistica.',
      subject: 'Fisica',
      date: '1 settimana fa'
    },
    {
      id: '3',
      studentName: 'Alessandro B.',
      rating: 4,
      comment: 'Brava insegnante, spiega con esempi pratici che rendono tutto più chiaro.',
      subject: 'Matematica',
      date: '2 settimane fa'
    }
  ];

  const handleSave = () => {
    // Save profile data
    setIsEditing(false);
  };

  const handleCancel = () => {
    // Reset changes
    setIsEditing(false);
  };

  const addSpecialization = (spec: string) => {
    if (!profileData.specializations.includes(spec)) {
      setProfileData(prev => ({
        ...prev,
        specializations: [...prev.specializations, spec]
      }));
    }
  };

  const removeSpecialization = (spec: string) => {
    setProfileData(prev => ({
      ...prev,
      specializations: prev.specializations.filter(s => s !== spec)
    }));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-50 via-emerald-50/20 to-teal-50/10 dark:from-stone-950 dark:via-stone-900 dark:to-stone-900">
      {/* Header */}
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 via-teal-500/5 to-cyan-500/5 dark:from-emerald-400/5 dark:via-teal-400/5 dark:to-cyan-400/5"></div>
        
        <div className="relative max-w-7xl mx-auto px-6 py-12">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-8">
            <div>
              <div className="inline-flex items-center space-x-2 bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm px-4 py-2 rounded-full border border-emerald-200/50 dark:border-emerald-800/50 mb-4">
                <div className="w-2 h-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full animate-pulse"></div>
                <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">Profilo Pubblico</span>
              </div>
              
              <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-stone-900 via-emerald-800 to-teal-800 dark:from-stone-100 dark:via-emerald-200 dark:to-teal-200 bg-clip-text text-transparent mb-4 leading-tight">
                Il Tuo Profilo Tutor
              </h1>
              <p className="text-xl text-stone-600 dark:text-stone-300 max-w-2xl leading-relaxed">
                Gestisci il tuo profilo pubblico, tariffe e specializzazioni per attrarre più studenti.
              </p>
            </div>

            <div className="flex space-x-4">
              {!isEditing ? (
                <button
                  onClick={() => setIsEditing(true)}
                  className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center space-x-2"
                >
                  <Edit className="w-5 h-5" />
                  <span>Modifica Profilo</span>
                </button>
              ) : (
                <>
                  <button
                    onClick={handleSave}
                    className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center space-x-2"
                  >
                    <Save className="w-5 h-5" />
                    <span>Salva</span>
                  </button>
                  <button
                    onClick={handleCancel}
                    className="border border-stone-300 dark:border-stone-600 text-stone-600 dark:text-stone-400 font-bold py-3 px-6 rounded-xl hover:bg-stone-50 dark:hover:bg-stone-800/50 transition-colors flex items-center space-x-2"
                  >
                    <X className="w-5 h-5" />
                    <span>Annulla</span>
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Profile */}
          <div className="lg:col-span-2 space-y-8">
            {/* Basic Info */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8">
              <div className="flex items-start space-x-6 mb-8">
                <div className="relative">
                  <img 
                    src="https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop"
                    alt={profileData.name}
                    className="w-24 h-24 rounded-full object-cover border-4 border-emerald-200 dark:border-emerald-700"
                  />
                  <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-emerald-500 rounded-full border-2 border-white dark:border-stone-900"></div>
                </div>
                
                <div className="flex-1">
                  {isEditing ? (
                    <div className="space-y-4">
                      <input
                        type="text"
                        value={profileData.name}
                        onChange={(e) => setProfileData(prev => ({ ...prev, name: e.target.value }))}
                        className="w-full text-2xl font-bold bg-transparent border-b-2 border-emerald-300 dark:border-emerald-600 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-500"
                      />
                      <input
                        type="text"
                        value={profileData.title}
                        onChange={(e) => setProfileData(prev => ({ ...prev, title: e.target.value }))}
                        className="w-full text-lg bg-transparent border-b-2 border-stone-300 dark:border-stone-600 text-stone-600 dark:text-stone-400 focus:outline-none focus:border-emerald-500"
                      />
                    </div>
                  ) : (
                    <>
                      <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-2">
                        {profileData.name}
                      </h2>
                      <p className="text-lg text-stone-600 dark:text-stone-400 mb-4">
                        {profileData.title}
                      </p>
                    </>
                  )}
                  
                  <div className="flex items-center space-x-6 text-sm">
                    <div className="flex items-center space-x-1">
                      <Star className="w-4 h-4 fill-current text-amber-400" />
                      <span className="font-bold text-stone-900 dark:text-stone-100">{stats.rating}</span>
                      <span className="text-stone-500 dark:text-stone-500">({stats.reviewCount} recensioni)</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <Users className="w-4 h-4 text-stone-500 dark:text-stone-500" />
                      <span className="text-stone-600 dark:text-stone-400">{stats.totalStudents} studenti</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <Clock className="w-4 h-4 text-stone-500 dark:text-stone-500" />
                      <span className="text-stone-600 dark:text-stone-400">{stats.responseTime}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bio */}
              <div className="mb-8">
                <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-4">
                  Biografia
                </h3>
                {isEditing ? (
                  <textarea
                    value={profileData.bio}
                    onChange={(e) => setProfileData(prev => ({ ...prev, bio: e.target.value }))}
                    rows={4}
                    className="w-full p-4 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200 resize-none"
                  />
                ) : (
                  <p className="text-stone-700 dark:text-stone-300 leading-relaxed">
                    {profileData.bio}
                  </p>
                )}
              </div>

              {/* Specializations */}
              <div className="mb-8">
                <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-4">
                  Specializzazioni
                </h3>
                <div className="flex flex-wrap gap-2 mb-4">
                  {profileData.specializations.map((spec) => (
                    <span 
                      key={spec}
                      className="flex items-center space-x-2 bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 px-3 py-2 rounded-full text-sm font-medium"
                    >
                      <span>{spec}</span>
                      {isEditing && (
                        <button
                          onClick={() => removeSpecialization(spec)}
                          className="text-emerald-600 dark:text-emerald-400 hover:text-emerald-800 dark:hover:text-emerald-200"
                        >
                          <X className="w-3 h-3" />
                        </button>
                      )}
                    </span>
                  ))}
                </div>
                
                {isEditing && (
                  <div className="space-y-2">
                    <p className="text-sm text-stone-600 dark:text-stone-400">Aggiungi specializzazioni:</p>
                    <div className="flex flex-wrap gap-2">
                      {SPECIALIZATIONS.filter(spec => !profileData.specializations.includes(spec)).slice(0, 10).map((spec) => (
                        <button
                          key={spec}
                          onClick={() => addSpecialization(spec)}
                          className="text-xs bg-stone-100 dark:bg-stone-800 text-stone-600 dark:text-stone-400 px-2 py-1 rounded-full hover:bg-emerald-100 dark:hover:bg-emerald-900/20 hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors"
                        >
                          + {spec}
                        </button>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Languages */}
              <div>
                <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-4">
                  Lingue
                </h3>
                <div className="flex items-center space-x-2">
                  <Globe className="w-5 h-5 text-stone-500 dark:text-stone-500" />
                  <div className="flex space-x-2">
                    {profileData.languages.map((lang) => (
                      <span 
                        key={lang}
                        className="text-sm text-stone-600 dark:text-stone-400 bg-stone-100 dark:bg-stone-800 px-2 py-1 rounded"
                      >
                        {lang}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Pricing */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8">
              <div className="flex items-center space-x-3 mb-6">
                <div className="p-2 bg-gradient-to-r from-purple-400 to-pink-500 rounded-lg">
                  <Zap className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100">
                    Tariffe e Pacchetti
                  </h3>
                  <p className="text-stone-600 dark:text-stone-400">
                    Gestisci i tuoi prezzi e tipi di sessione
                  </p>
                </div>
              </div>

              <div className="space-y-4">
                {profileData.sessionTypes.map((sessionType) => (
                  <div 
                    key={sessionType.id}
                    className="p-4 bg-stone-50/50 dark:bg-stone-800/50 rounded-xl"
                  >
                    <div className="flex items-center justify-between mb-2">
                      <h4 className="font-semibold text-stone-900 dark:text-stone-100">
                        {sessionType.name}
                      </h4>
                      <div className="text-right">
                        <div className="text-lg font-bold text-emerald-600 dark:text-emerald-400">
                          {sessionType.price}N
                        </div>
                        <div className="text-sm text-stone-500 dark:text-stone-500">
                          {sessionType.duration} min
                        </div>
                      </div>
                    </div>
                    <p className="text-sm text-stone-600 dark:text-stone-400">
                      {sessionType.description}
                    </p>
                  </div>
                ))}
              </div>

              {isEditing && (
                <button className="w-full mt-4 py-3 px-4 border-2 border-dashed border-purple-300 dark:border-purple-600 text-purple-600 dark:text-purple-400 rounded-xl hover:bg-purple-50 dark:hover:bg-purple-900/10 transition-colors font-medium">
                  + Aggiungi Nuovo Pacchetto
                </button>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Performance Stats */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
              <div className="flex items-center space-x-3 mb-6">
                <div className="p-2 bg-gradient-to-r from-blue-400 to-indigo-500 rounded-lg">
                  <TrendingUp className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
                  Statistiche
                </h3>
              </div>

              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-stone-600 dark:text-stone-400">Sessioni Totali</span>
                  <span className="font-bold text-stone-900 dark:text-stone-100">{stats.totalSessions}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-stone-600 dark:text-stone-400">Studenti Unici</span>
                  <span className="font-bold text-stone-900 dark:text-stone-100">{stats.totalStudents}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-stone-600 dark:text-stone-400">Tasso Completamento</span>
                  <span className="font-bold text-emerald-600 dark:text-emerald-400">{stats.completionRate}%</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-stone-600 dark:text-stone-400">Tempo Risposta</span>
                  <span className="font-bold text-stone-900 dark:text-stone-100">{stats.responseTime}</span>
                </div>
              </div>
            </div>

            {/* Recent Reviews */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
                  Recensioni Recenti
                </h3>
                <button className="text-emerald-600 dark:text-emerald-400 hover:text-emerald-700 dark:hover:text-emerald-300 font-medium text-sm">
                  Vedi tutte
                </button>
              </div>

              <div className="space-y-4">
                {recentReviews.map((review) => (
                  <div key={review.id} className="p-3 bg-stone-50/50 dark:bg-stone-800/50 rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center space-x-2">
                        <span className="font-medium text-stone-900 dark:text-stone-100 text-sm">
                          {review.studentName}
                        </span>
                        <span className="text-xs text-stone-500 dark:text-stone-500">
                          {review.subject}
                        </span>
                      </div>
                      <div className="flex items-center space-x-1">
                        {[...Array(5)].map((_, i) => (
                          <Star 
                            key={i}
                            className={`w-3 h-3 ${
                              i < review.rating 
                                ? 'fill-current text-amber-400' 
                                : 'text-stone-300 dark:text-stone-600'
                            }`}
                          />
                        ))}
                      </div>
                    </div>
                    <p className="text-xs text-stone-600 dark:text-stone-400 mb-1">
                      "{review.comment}"
                    </p>
                    <div className="text-xs text-stone-500 dark:text-stone-500">
                      {review.date}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Badges */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
              <div className="flex items-center space-x-3 mb-6">
                <div className="p-2 bg-gradient-to-r from-amber-400 to-orange-500 rounded-lg">
                  <Award className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
                  Badge Ottenuti
                </h3>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="text-center p-3 bg-gradient-to-r from-purple-50 to-pink-50 dark:from-purple-900/10 dark:to-pink-900/10 rounded-lg border border-purple-200/50 dark:border-purple-800/50">
                  <div className="text-2xl mb-1">👑</div>
                  <div className="text-xs font-medium text-purple-700 dark:text-purple-300">Top Tutor</div>
                </div>
                <div className="text-center p-3 bg-gradient-to-r from-blue-50 to-cyan-50 dark:from-blue-900/10 dark:to-cyan-900/10 rounded-lg border border-blue-200/50 dark:border-blue-800/50">
                  <div className="text-2xl mb-1">⚡</div>
                  <div className="text-xs font-medium text-blue-700 dark:text-blue-300">Risposta Rapida</div>
                </div>
                <div className="text-center p-3 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/10 dark:to-teal-900/10 rounded-lg border border-emerald-200/50 dark:border-emerald-800/50">
                  <div className="text-2xl mb-1">🎓</div>
                  <div className="text-xs font-medium text-emerald-700 dark:text-emerald-300">Esperto</div>
                </div>
                <div className="text-center p-3 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-lg border border-amber-200/50 dark:border-amber-800/50">
                  <div className="text-2xl mb-1">🤝</div>
                  <div className="text-xs font-medium text-amber-700 dark:text-amber-300">Paziente</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
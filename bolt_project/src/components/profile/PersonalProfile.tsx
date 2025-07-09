import React, { useState } from 'react';
import { 
  User, 
  Crown, 
  Zap, 
  Trophy, 
  Target, 
  Calendar,
  Settings,
  GraduationCap,
  Users,
  PenTool,
  Star,
  Clock,
  TrendingUp,
  Award,
  BookOpen,
  Brain,
  Heart,
  Shield,
  Flame,
  Activity
} from 'lucide-react';
import { useUserRoles } from '../../hooks/useUserRoles';

export const PersonalProfile: React.FC = () => {
  const { user, hasRole } = useUserRoles();
  const [activeCareerTab, setActiveCareerTab] = useState('student');

  if (!user) return null;

  // Mock data - in a real app this would come from API
  const profileStats = {
    health: 95,
    energy: 78,
    intelligence: 85,
    persistence: 90
  };

  const careerData = {
    student: {
      level: 12,
      xp: 2850,
      nextLevelXp: 3000,
      coursesCompleted: 8,
      studyHours: 156,
      averageGrade: 4.7,
      certificates: 3,
      currentStreak: 12,
      favoriteSubjects: ['React', 'TypeScript', 'Design'],
      monthlyGoal: { current: 15, target: 20 },
      neuronsInvested: 1240
    },
    tutor: {
      level: 8,
      xp: 1650,
      nextLevelXp: 2000,
      totalSessions: 45,
      studentsHelped: 23,
      averageRating: 4.8,
      neuronsEarned: 3240,
      responseTime: 'Entro 1 ora',
      completionRate: 98,
      studentRetention: 92,
      monthlyGoal: { current: 15, target: 20 },
      specializations: ['Matematica', 'Fisica', 'Programmazione']
    },
    creator: {
      level: 6,
      xp: 980,
      nextLevelXp: 1500,
      coursesPublished: 3,
      totalStudents: 1247,
      averageRating: 4.6,
      totalRevenue: 8950,
      topCourse: 'React Avanzato',
      videoHours: 24,
      completionRate: 78,
      monthlyEarnings: 1200,
      totalReviews: 89,
      activeProjects: 2
    }
  };

  const getCareerColor = (career: string) => {
    switch (career) {
      case 'student':
        return 'from-blue-500 to-cyan-500';
      case 'tutor':
        return 'from-emerald-500 to-teal-500';
      case 'creator':
        return 'from-purple-500 to-pink-500';
      default:
        return 'from-stone-500 to-stone-600';
    }
  };

  const getCareerIcon = (career: string) => {
    switch (career) {
      case 'student':
        return GraduationCap;
      case 'tutor':
        return Users;
      case 'creator':
        return PenTool;
      default:
        return User;
    }
  };

  const getCareerTitle = (career: string) => {
    switch (career) {
      case 'student':
        return 'Carriera Studente';
      case 'tutor':
        return 'Carriera Tutor';
      case 'creator':
        return 'Carriera Creator';
      default:
        return 'Carriera';
    }
  };

  const availableCareers = user.roles.filter(role => ['student', 'tutor', 'creator'].includes(role));

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900 relative overflow-hidden">
      {/* Animated Background */}
      <div className="absolute inset-0">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_80%,rgba(120,119,198,0.3),transparent_50%)]"></div>
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(255,119,198,0.3),transparent_50%)]"></div>
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_40%_40%,rgba(59,130,246,0.2),transparent_50%)]"></div>
      </div>

      <div className="relative max-w-7xl mx-auto px-6 py-8">
        {/* Character Card */}
        <div className="bg-gradient-to-br from-slate-800/90 to-slate-900/90 backdrop-blur-xl rounded-3xl border border-white/10 p-8 mb-8 shadow-2xl">
          <div className="flex items-start space-x-8">
            {/* Avatar Section */}
            <div className="relative">
              <div className="w-32 h-32 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 p-1 shadow-2xl">
                <img 
                  src={user.avatar || 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&fit=crop'}
                  alt={user.name}
                  className="w-full h-full rounded-xl object-cover"
                />
              </div>
              
              {/* Level Badge */}
              <div className="absolute -top-2 -right-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white font-bold px-3 py-1 rounded-full shadow-lg border-2 border-white/20">
                Lv. {user.level}
              </div>

              {/* Status Indicator */}
              <div className="absolute -bottom-2 -right-2 w-8 h-8 bg-emerald-500 rounded-full border-4 border-slate-800 flex items-center justify-center">
                <div className="w-3 h-3 bg-white rounded-full animate-pulse"></div>
              </div>
            </div>

            {/* Character Info */}
            <div className="flex-1">
              <div className="flex items-center space-x-4 mb-4">
                <h1 className="text-4xl font-bold text-white">{user.name}</h1>
                <div className="flex space-x-2">
                  {user.roles.map((role) => (
                    <div 
                      key={role}
                      className={`px-3 py-1 rounded-full text-xs font-bold text-white bg-gradient-to-r ${
                        role === 'student' ? 'from-blue-500 to-cyan-500' :
                        role === 'tutor' ? 'from-emerald-500 to-teal-500' :
                        role === 'creator' ? 'from-purple-500 to-pink-500' :
                        'from-stone-500 to-stone-600'
                      }`}
                    >
                      {role === 'student' && '🎓 Studente'}
                      {role === 'tutor' && '👨‍🏫 Tutor'}
                      {role === 'creator' && '🎨 Creator'}
                    </div>
                  ))}
                </div>
              </div>

              {/* XP Bar */}
              <div className="mb-6">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-white/80 font-medium">Esperienza Totale</span>
                  <span className="text-amber-400 font-bold">{user.xp} / 3000 XP</span>
                </div>
                <div className="w-full bg-slate-700/50 rounded-full h-3 overflow-hidden">
                  <div 
                    className="bg-gradient-to-r from-amber-400 to-orange-500 h-full rounded-full transition-all duration-1000 shadow-lg"
                    style={{ width: `${(user.xp / 3000) * 100}%` }}
                  >
                    <div className="h-full bg-white/20 rounded-full animate-pulse"></div>
                  </div>
                </div>
              </div>

              {/* Stats Grid */}
              <div className="grid grid-cols-4 gap-4">
                <div className="bg-gradient-to-br from-red-500/20 to-red-600/20 backdrop-blur-sm rounded-xl p-4 border border-red-400/20">
                  <div className="flex items-center space-x-2 mb-2">
                    <Heart className="w-5 h-5 text-red-400" />
                    <span className="text-red-300 text-sm font-medium">Salute</span>
                  </div>
                  <div className="text-2xl font-bold text-white">{profileStats.health}</div>
                </div>

                <div className="bg-gradient-to-br from-blue-500/20 to-blue-600/20 backdrop-blur-sm rounded-xl p-4 border border-blue-400/20">
                  <div className="flex items-center space-x-2 mb-2">
                    <Zap className="w-5 h-5 text-blue-400" />
                    <span className="text-blue-300 text-sm font-medium">Energia</span>
                  </div>
                  <div className="text-2xl font-bold text-white">{profileStats.energy}</div>
                </div>

                <div className="bg-gradient-to-br from-purple-500/20 to-purple-600/20 backdrop-blur-sm rounded-xl p-4 border border-purple-400/20">
                  <div className="flex items-center space-x-2 mb-2">
                    <Brain className="w-5 h-5 text-purple-400" />
                    <span className="text-purple-300 text-sm font-medium">Intelligenza</span>
                  </div>
                  <div className="text-2xl font-bold text-white">{profileStats.intelligence}</div>
                </div>

                <div className="bg-gradient-to-br from-emerald-500/20 to-emerald-600/20 backdrop-blur-sm rounded-xl p-4 border border-emerald-400/20">
                  <div className="flex items-center space-x-2 mb-2">
                    <Shield className="w-5 h-5 text-emerald-400" />
                    <span className="text-emerald-300 text-sm font-medium">Persistenza</span>
                  </div>
                  <div className="text-2xl font-bold text-white">{profileStats.persistence}</div>
                </div>
              </div>
            </div>

            {/* Resources */}
            <div className="text-right space-y-4">
              <div className="bg-gradient-to-br from-slate-700/50 to-slate-800/50 backdrop-blur-sm rounded-xl p-4 border border-white/10">
                <div className="text-slate-300 text-sm mb-1">Ore di Studio</div>
                <div className="text-2xl font-bold text-purple-400">156h</div>
              </div>
              <div className="bg-gradient-to-br from-slate-700/50 to-slate-800/50 backdrop-blur-sm rounded-xl p-4 border border-white/10">
                <div className="text-slate-300 text-sm mb-1">Neuroni</div>
                <div className="text-2xl font-bold text-amber-400">{user.neurons.toLocaleString()}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Careers Section - Dedicated UI */}
        <div className="bg-gradient-to-br from-slate-800/90 to-slate-900/90 backdrop-blur-xl rounded-3xl border border-white/10 p-8 mb-8 shadow-2xl">
          <div className="flex items-center space-x-3 mb-8">
            <div className="p-3 bg-gradient-to-r from-amber-400 to-orange-500 rounded-xl">
              <Crown className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-3xl font-bold text-white">Le Tue Carriere</h2>
              <p className="text-slate-300">Gestisci e monitora i tuoi progressi professionali</p>
            </div>
          </div>

          {/* Career Tabs */}
          <div className="flex space-x-2 mb-8 bg-slate-700/30 p-2 rounded-2xl">
            {availableCareers.map((career) => {
              const Icon = getCareerIcon(career);
              return (
                <button
                  key={career}
                  onClick={() => setActiveCareerTab(career)}
                  className={`flex items-center space-x-3 px-6 py-4 rounded-xl font-medium transition-all duration-300 ${
                    activeCareerTab === career
                      ? `bg-gradient-to-r ${getCareerColor(career)} text-white shadow-lg transform scale-105`
                      : 'text-slate-300 hover:text-white hover:bg-slate-600/50'
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  <span>{getCareerTitle(career)}</span>
                </button>
              );
            })}
          </div>

          {/* Active Career Content */}
          <div className={`bg-gradient-to-br ${getCareerColor(activeCareerTab)}/10 backdrop-blur-sm rounded-2xl border border-white/10 p-8`}>
            {activeCareerTab === 'student' && (
              <div>
                <div className="flex items-center space-x-3 mb-6">
                  <GraduationCap className="w-8 h-8 text-blue-400" />
                  <div>
                    <h3 className="text-2xl font-bold text-white">Carriera da Studente</h3>
                    <p className="text-slate-300">Continua il tuo percorso di apprendimento</p>
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-blue-400 mb-1">{careerData.student.coursesCompleted}</div>
                    <div className="text-slate-300 text-sm">Corsi Completati</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-cyan-400 mb-1">{careerData.student.studyHours}h</div>
                    <div className="text-slate-300 text-sm">Ore di Studio</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-emerald-400 mb-1">{careerData.student.averageGrade}</div>
                    <div className="text-slate-300 text-sm">Voto Medio</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-purple-400 mb-1">{careerData.student.certificates}</div>
                    <div className="text-slate-300 text-sm">Certificati</div>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="bg-slate-700/30 rounded-xl p-6">
                    <h4 className="text-white font-semibold mb-4 flex items-center space-x-2">
                      <Flame className="w-5 h-5 text-orange-400" />
                      <span>Streak di Studio</span>
                    </h4>
                    <div className="text-2xl font-bold text-orange-400 mb-2">{careerData.student.currentStreak} giorni</div>
                    <p className="text-slate-400 text-sm">Record personale! Continua così!</p>
                  </div>

                  <div className="bg-slate-700/30 rounded-xl p-6">
                    <h4 className="text-white font-semibold mb-4 flex items-center space-x-2">
                      <Target className="w-5 h-5 text-emerald-400" />
                      <span>Obiettivo Mensile</span>
                    </h4>
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-slate-300">Sessioni</span>
                      <span className="text-emerald-400 font-bold">{careerData.student.monthlyGoal.current}/{careerData.student.monthlyGoal.target}</span>
                    </div>
                    <div className="w-full bg-slate-600 rounded-full h-2">
                      <div 
                        className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full"
                        style={{ width: `${(careerData.student.monthlyGoal.current / careerData.student.monthlyGoal.target) * 100}%` }}
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeCareerTab === 'tutor' && (
              <div>
                <div className="flex items-center space-x-3 mb-6">
                  <Users className="w-8 h-8 text-emerald-400" />
                  <div>
                    <h3 className="text-2xl font-bold text-white">Carriera da Tutor</h3>
                    <p className="text-slate-300">Aiuta altri studenti e condividi la tua conoscenza</p>
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-emerald-400 mb-1">{careerData.tutor.totalSessions}</div>
                    <div className="text-slate-300 text-sm">Sessioni Totali</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-teal-400 mb-1">{careerData.tutor.studentsHelped}</div>
                    <div className="text-slate-300 text-sm">Studenti Aiutati</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-amber-400 mb-1">{careerData.tutor.averageRating}</div>
                    <div className="text-slate-300 text-sm">Rating Medio</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-purple-400 mb-1">{careerData.tutor.neuronsEarned}N</div>
                    <div className="text-slate-300 text-sm">Neuroni Guadagnati</div>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="bg-slate-700/30 rounded-xl p-6">
                    <h4 className="text-white font-semibold mb-4 flex items-center space-x-2">
                      <Star className="w-5 h-5 text-amber-400" />
                      <span>Performance Tutor</span>
                    </h4>
                    <div className="space-y-3">
                      <div className="flex justify-between">
                        <span className="text-slate-300">Tempo Risposta</span>
                        <span className="text-emerald-400 font-medium">{careerData.tutor.responseTime}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-300">Tasso Completamento</span>
                        <span className="text-emerald-400 font-medium">{careerData.tutor.completionRate}%</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-300">Ritenzione Studenti</span>
                        <span className="text-emerald-400 font-medium">{careerData.tutor.studentRetention}%</span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-slate-700/30 rounded-xl p-6">
                    <h4 className="text-white font-semibold mb-4 flex items-center space-x-2">
                      <Target className="w-5 h-5 text-emerald-400" />
                      <span>Obiettivi Mensili</span>
                    </h4>
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-slate-300">Sessioni</span>
                      <span className="text-emerald-400 font-bold">{careerData.tutor.monthlyGoal.current}/{careerData.tutor.monthlyGoal.target}</span>
                    </div>
                    <div className="w-full bg-slate-600 rounded-full h-2 mb-4">
                      <div 
                        className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full"
                        style={{ width: `${(careerData.tutor.monthlyGoal.current / careerData.tutor.monthlyGoal.target) * 100}%` }}
                      ></div>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {careerData.tutor.specializations.map((spec) => (
                        <span key={spec} className="text-xs bg-emerald-500/20 text-emerald-300 px-2 py-1 rounded-full">
                          {spec}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeCareerTab === 'creator' && (
              <div>
                <div className="flex items-center space-x-3 mb-6">
                  <PenTool className="w-8 h-8 text-purple-400" />
                  <div>
                    <h3 className="text-2xl font-bold text-white">Carriera da Creator</h3>
                    <p className="text-slate-300">Crea contenuti e condividi la tua expertise</p>
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-purple-400 mb-1">{careerData.creator.coursesPublished}</div>
                    <div className="text-slate-300 text-sm">Corsi Pubblicati</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-pink-400 mb-1">{careerData.creator.totalStudents}</div>
                    <div className="text-slate-300 text-sm">Studenti Totali</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-amber-400 mb-1">{careerData.creator.averageRating}</div>
                    <div className="text-slate-300 text-sm">Rating Medio</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-emerald-400 mb-1">{careerData.creator.totalRevenue}N</div>
                    <div className="text-slate-300 text-sm">Ricavi Totali</div>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="bg-slate-700/30 rounded-xl p-6">
                    <h4 className="text-white font-semibold mb-4 flex items-center space-x-2">
                      <TrendingUp className="w-5 h-5 text-purple-400" />
                      <span>Performance Contenuti</span>
                    </h4>
                    <div className="space-y-3">
                      <div className="flex justify-between">
                        <span className="text-slate-300">Corso Top</span>
                        <span className="text-purple-400 font-medium">{careerData.creator.topCourse}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-300">Ore Video</span>
                        <span className="text-purple-400 font-medium">{careerData.creator.videoHours}h</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-300">Tasso Completamento</span>
                        <span className="text-purple-400 font-medium">{careerData.creator.completionRate}%</span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-slate-700/30 rounded-xl p-6">
                    <h4 className="text-white font-semibold mb-4 flex items-center space-x-2">
                      <Zap className="w-5 h-5 text-amber-400" />
                      <span>Ricavi e Crescita</span>
                    </h4>
                    <div className="space-y-3">
                      <div className="flex justify-between">
                        <span className="text-slate-300">Entrate Mensili</span>
                        <span className="text-emerald-400 font-medium">{careerData.creator.monthlyEarnings}N</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-300">Recensioni Totali</span>
                        <span className="text-amber-400 font-medium">{careerData.creator.totalReviews}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-300">Progetti Attivi</span>
                        <span className="text-purple-400 font-medium">{careerData.creator.activeProjects}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Rest of Profile Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Achievements & Badges */}
          <div className="lg:col-span-2">
            <div className="bg-gradient-to-br from-slate-800/90 to-slate-900/90 backdrop-blur-xl rounded-3xl border border-white/10 p-8 shadow-2xl">
              <div className="flex items-center space-x-3 mb-6">
                <div className="p-3 bg-gradient-to-r from-amber-400 to-orange-500 rounded-xl">
                  <Trophy className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className="text-2xl font-bold text-white">Achievement & Badge</h3>
                  <p className="text-slate-300">I tuoi traguardi e riconoscimenti</p>
                </div>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                {user.badges.map((badge) => (
                  <div 
                    key={badge.id}
                    className="bg-gradient-to-br from-amber-500/20 to-orange-500/20 backdrop-blur-sm rounded-xl p-4 border border-amber-400/20 hover:scale-105 transition-transform duration-300"
                  >
                    <div className="text-3xl mb-2">{badge.icon}</div>
                    <h4 className="text-white font-semibold text-sm mb-1">{badge.name}</h4>
                    <p className="text-slate-300 text-xs mb-2">{badge.description}</p>
                    <div className="text-xs text-amber-400">
                      {badge.earnedAt.toLocaleDateString('it-IT')}
                    </div>
                  </div>
                ))}

                {/* Locked Badges */}
                <div className="bg-gradient-to-br from-slate-700/30 to-slate-800/30 backdrop-blur-sm rounded-xl p-4 border border-slate-600/20">
                  <div className="text-3xl mb-2 opacity-50">🔒</div>
                  <h4 className="text-slate-400 font-semibold text-sm mb-1">Maestro del Codice</h4>
                  <p className="text-slate-500 text-xs mb-2">Completa 50 corsi di programmazione</p>
                  <div className="text-xs text-slate-500">Bloccato</div>
                </div>

                <div className="bg-gradient-to-br from-slate-700/30 to-slate-800/30 backdrop-blur-sm rounded-xl p-4 border border-slate-600/20">
                  <div className="text-3xl mb-2 opacity-50">🔒</div>
                  <h4 className="text-slate-400 font-semibold text-sm mb-1">Mentore Leggendario</h4>
                  <p className="text-slate-500 text-xs mb-2">Aiuta 100 studenti come tutor</p>
                  <div className="text-xs text-slate-500">Bloccato</div>
                </div>
              </div>
            </div>
          </div>

          {/* Activity & Settings */}
          <div className="space-y-6">
            {/* Recent Activity */}
            <div className="bg-gradient-to-br from-slate-800/90 to-slate-900/90 backdrop-blur-xl rounded-3xl border border-white/10 p-6 shadow-2xl">
              <div className="flex items-center space-x-3 mb-6">
                <div className="p-2 bg-gradient-to-r from-blue-400 to-indigo-500 rounded-lg">
                  <Activity className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-lg font-bold text-white">Attività Recente</h3>
              </div>

              <div className="space-y-4">
                <div className="flex items-center space-x-3 p-3 bg-slate-700/30 rounded-lg">
                  <div className="w-2 h-2 bg-emerald-400 rounded-full"></div>
                  <div className="flex-1">
                    <p className="text-white text-sm">Corso completato</p>
                    <p className="text-slate-400 text-xs">React Avanzato • 2 ore fa</p>
                  </div>
                </div>

                <div className="flex items-center space-x-3 p-3 bg-slate-700/30 rounded-lg">
                  <div className="w-2 h-2 bg-purple-400 rounded-full"></div>
                  <div className="flex-1">
                    <p className="text-white text-sm">Badge ottenuto</p>
                    <p className="text-slate-400 text-xs">Creatore Emergente • 1 giorno fa</p>
                  </div>
                </div>

                <div className="flex items-center space-x-3 p-3 bg-slate-700/30 rounded-lg">
                  <div className="w-2 h-2 bg-amber-400 rounded-full"></div>
                  <div className="flex-1">
                    <p className="text-white text-sm">Sessione tutoraggio</p>
                    <p className="text-slate-400 text-xs">Matematica • 3 giorni fa</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Quick Settings */}
            <div className="bg-gradient-to-br from-slate-800/90 to-slate-900/90 backdrop-blur-xl rounded-3xl border border-white/10 p-6 shadow-2xl">
              <div className="flex items-center space-x-3 mb-6">
                <div className="p-2 bg-gradient-to-r from-stone-400 to-stone-500 rounded-lg">
                  <Settings className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-lg font-bold text-white">Impostazioni</h3>
              </div>

              <div className="space-y-3">
                <button className="w-full text-left p-3 bg-slate-700/30 rounded-lg hover:bg-slate-600/30 transition-colors">
                  <div className="text-white text-sm font-medium">Modifica Profilo</div>
                  <div className="text-slate-400 text-xs">Aggiorna le tue informazioni</div>
                </button>

                <button className="w-full text-left p-3 bg-slate-700/30 rounded-lg hover:bg-slate-600/30 transition-colors">
                  <div className="text-white text-sm font-medium">Privacy</div>
                  <div className="text-slate-400 text-xs">Gestisci la tua privacy</div>
                </button>

                <button className="w-full text-left p-3 bg-slate-700/30 rounded-lg hover:bg-slate-600/30 transition-colors">
                  <div className="text-white text-sm font-medium">Notifiche</div>
                  <div className="text-slate-400 text-xs">Configura le notifiche</div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
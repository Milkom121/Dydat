/**
 * @fileoverview Dashboard Creator
 * Dashboard dedicato ai creators con analitiche, corsi pubblicati e gestione contenuti
 */

import React from 'react';
import { 
  PenTool, 
  Users, 
  DollarSign, 
  TrendingUp, 
  PlayCircle,
  Eye,
  Star,
  BarChart3,
  Calendar,
  Plus,
  Video,
  FileText,
  Settings
} from 'lucide-react';

export const CreatorDashboard: React.FC = () => {
  // Mock data per creator
  const creatorData = {
    user: {
      name: 'Marco Rossi',
      level: 6,
      totalRevenue: 8950
    },
    stats: {
      corsiPubblicati: 8,
      studentiTotali: 1247,
      guadagnoMese: 1200,
      ratingMedio: 4.6
    },
    corsiAttivi: [
      {
        id: '1',
        title: 'React Avanzato per Developers',
        studenti: 342,
        rating: 4.8,
        revenue: 3420,
        status: 'pubblicato',
        thumbnail: '/placeholder-course.jpg',
        lastUpdate: '2 giorni fa'
      },
      {
        id: '2',
        title: 'TypeScript da Zero a Esperto',
        studenti: 198,
        rating: 4.7,
        revenue: 1980,
        status: 'pubblicato',
        thumbnail: '/placeholder-course.jpg',
        lastUpdate: '1 settimana fa'
      },
      {
        id: '3',
        title: 'Design System con Figma',
        studenti: 89,
        rating: 4.5,
        revenue: 890,
        status: 'bozza',
        thumbnail: '/placeholder-course.jpg',
        lastUpdate: 'Oggi'
      }
    ],
    analytics: {
      visualizzazioniMese: 15420,
      nuoviStudenti: 89,
      completamentoMedio: 78,
      recensioniMese: 45
    },
    prossimeScadenze: [
      {
        id: '1',
        tipo: 'Aggiornamento Corso',
        titolo: 'React Avanzato - Capitolo 8',
        data: '2024-01-25',
        priorita: 'alta'
      },
      {
        id: '2',
        tipo: 'Webinar',
        titolo: 'Q&A con la Community',
        data: '2024-01-27',
        priorita: 'media'
      }
    ]
  };

  const { stats, corsiAttivi, analytics, prossimeScadenze } = creatorData;

  return (
    <div className="p-6 space-y-6">
      {/* Header Dashboard Creator */}
      <div className="bg-gradient-to-r from-purple-500 to-pink-600 rounded-xl p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold mb-2">
              🎨 Benvenuto, Creator!
            </h1>
            <p className="text-purple-100">
              I tuoi {stats.corsiPubblicati} corsi hanno formato {stats.studentiTotali} studenti questo mese.
            </p>
          </div>
          <div className="text-center">
            <div className="text-3xl font-bold">€{stats.guadagnoMese}</div>
            <div className="text-sm text-purple-100">Questo mese</div>
          </div>
        </div>
      </div>

      {/* Statistiche Creator */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Corsi Pubblicati</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">{stats.corsiPubblicati}</p>
            </div>
            <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900/20 rounded-xl flex items-center justify-center">
              <PenTool className="w-6 h-6 text-purple-600 dark:text-purple-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">+2 questo mese</span>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Studenti Totali</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">{stats.studentiTotali}</p>
            </div>
            <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/20 rounded-xl flex items-center justify-center">
              <Users className="w-6 h-6 text-blue-600 dark:text-blue-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">+{analytics.nuoviStudenti} questo mese</span>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Guadagno Mese</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">€{stats.guadagnoMese}</p>
            </div>
            <div className="w-12 h-12 bg-green-100 dark:bg-green-900/20 rounded-xl flex items-center justify-center">
              <DollarSign className="w-6 h-6 text-green-600 dark:text-green-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">+18% vs mese scorso</span>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Rating Medio</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">{stats.ratingMedio}</p>
            </div>
            <div className="w-12 h-12 bg-yellow-100 dark:bg-yellow-900/20 rounded-xl flex items-center justify-center">
              <Star className="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">+0.2 questo mese</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* I Miei Corsi */}
        <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
              I Miei Corsi
            </h2>
            <button className="flex items-center space-x-2 bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors">
              <Plus className="w-4 h-4" />
              <span>Nuovo Corso</span>
            </button>
          </div>
          
          <div className="space-y-4">
            {corsiAttivi.map((corso) => (
              <div key={corso.id} className="border border-stone-200 dark:border-stone-700 rounded-lg p-4 hover:bg-stone-50 dark:hover:bg-stone-700/50 transition-colors">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-1">
                      <h3 className="font-semibold text-stone-900 dark:text-stone-100">{corso.title}</h3>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        corso.status === 'pubblicato'
                          ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                          : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400'
                      }`}>
                        {corso.status}
                      </span>
                    </div>
                    <p className="text-sm text-stone-600 dark:text-stone-400">
                      Aggiornato {corso.lastUpdate}
                    </p>
                  </div>
                </div>
                
                <div className="grid grid-cols-3 gap-4 mb-3">
                  <div className="text-center">
                    <div className="font-semibold text-stone-900 dark:text-stone-100">{corso.studenti}</div>
                    <div className="text-xs text-stone-600 dark:text-stone-400">Studenti</div>
                  </div>
                  <div className="text-center">
                    <div className="font-semibold text-stone-900 dark:text-stone-100 flex items-center justify-center">
                      {corso.rating} <Star className="w-3 h-3 text-yellow-500 ml-1" />
                    </div>
                    <div className="text-xs text-stone-600 dark:text-stone-400">Rating</div>
                  </div>
                  <div className="text-center">
                    <div className="font-semibold text-green-600 dark:text-green-400">€{corso.revenue}</div>
                    <div className="text-xs text-stone-600 dark:text-stone-400">Guadagno</div>
                  </div>
                </div>
                
                <div className="flex space-x-2">
                  <button className="flex-1 bg-blue-600 text-white px-3 py-2 rounded-lg text-sm hover:bg-blue-700 transition-colors flex items-center justify-center space-x-1">
                    <Eye className="w-4 h-4" />
                    <span>Visualizza</span>
                  </button>
                  <button className="flex-1 border border-stone-300 dark:border-stone-600 text-stone-700 dark:text-stone-300 px-3 py-2 rounded-lg text-sm hover:bg-stone-50 dark:hover:bg-stone-700 transition-colors flex items-center justify-center space-x-1">
                    <Settings className="w-4 h-4" />
                    <span>Modifica</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Analytics Rapide */}
        <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
              Analytics Mensili
            </h2>
            <BarChart3 className="w-5 h-5 text-stone-400" />
          </div>
          
          <div className="space-y-6">
            <div className="flex items-center justify-between p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
              <div>
                <div className="font-semibold text-blue-900 dark:text-blue-100">Visualizzazioni</div>
                <div className="text-sm text-blue-700 dark:text-blue-300">Tutti i corsi</div>
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-blue-900 dark:text-blue-100">
                  {analytics.visualizzazioniMese.toLocaleString()}
                </div>
                <div className="text-sm text-green-600 dark:text-green-400">+12%</div>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
              <div>
                <div className="font-semibold text-green-900 dark:text-green-100">Nuovi Studenti</div>
                <div className="text-sm text-green-700 dark:text-green-300">Iscrizioni mensili</div>
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-green-900 dark:text-green-100">
                  {analytics.nuoviStudenti}
                </div>
                <div className="text-sm text-green-600 dark:text-green-400">+8%</div>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
              <div>
                <div className="font-semibold text-purple-900 dark:text-purple-100">Completamento</div>
                <div className="text-sm text-purple-700 dark:text-purple-300">Tasso medio</div>
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-purple-900 dark:text-purple-100">
                  {analytics.completamentoMedio}%
                </div>
                <div className="text-sm text-green-600 dark:text-green-400">+5%</div>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-orange-50 dark:bg-orange-900/20 rounded-lg">
              <div>
                <div className="font-semibold text-orange-900 dark:text-orange-100">Recensioni</div>
                <div className="text-sm text-orange-700 dark:text-orange-300">Questo mese</div>
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-orange-900 dark:text-orange-100">
                  {analytics.recensioniMese}
                </div>
                <div className="text-sm text-green-600 dark:text-green-400">+15%</div>
              </div>
            </div>
          </div>

          <button className="w-full mt-6 bg-stone-100 dark:bg-stone-700 text-stone-900 dark:text-stone-100 py-2 rounded-lg hover:bg-stone-200 dark:hover:bg-stone-600 transition-colors">
            Visualizza Report Completo
          </button>
        </div>
      </div>

      {/* Prossime Scadenze */}
      <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
            Prossime Scadenze
          </h2>
          <Calendar className="w-5 h-5 text-stone-400" />
        </div>
        
        <div className="space-y-4">
          {prossimeScadenze.map((scadenza) => (
            <div key={scadenza.id} className="flex items-center justify-between p-4 border border-stone-200 dark:border-stone-700 rounded-lg">
              <div className="flex items-center space-x-4">
                <div className={`w-3 h-3 rounded-full ${
                  scadenza.priorita === 'alta' ? 'bg-red-500' :
                  scadenza.priorita === 'media' ? 'bg-yellow-500' : 'bg-green-500'
                }`}></div>
                <div>
                  <div className="font-medium text-stone-900 dark:text-stone-100">{scadenza.titolo}</div>
                  <div className="text-sm text-stone-600 dark:text-stone-400">{scadenza.tipo}</div>
                </div>
              </div>
              <div className="text-right">
                <div className="text-sm font-medium text-stone-900 dark:text-stone-100">{scadenza.data}</div>
                <div className={`text-xs ${
                  scadenza.priorita === 'alta' ? 'text-red-600' :
                  scadenza.priorita === 'media' ? 'text-yellow-600' : 'text-green-600'
                }`}>
                  {scadenza.priorita.charAt(0).toUpperCase() + scadenza.priorita.slice(1)} priorità
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Azioni Creator */}
      <div className="bg-gradient-to-r from-indigo-500 to-purple-600 rounded-xl p-6 text-white">
        <h2 className="text-xl font-bold mb-4">🚀 Strumenti Creator</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <Video className="w-6 h-6 mb-2" />
            <div className="font-medium">Nuovo Video</div>
            <div className="text-sm text-indigo-100">Registra lezione</div>
          </button>
          
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <FileText className="w-6 h-6 mb-2" />
            <div className="font-medium">Scrivi Articolo</div>
            <div className="text-sm text-indigo-100">Contenuto testuale</div>
          </button>
          
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <BarChart3 className="w-6 h-6 mb-2" />
            <div className="font-medium">Analytics</div>
            <div className="text-sm text-indigo-100">Dati dettagliati</div>
          </button>
          
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <Users className="w-6 h-6 mb-2" />
            <div className="font-medium">Community</div>
            <div className="text-sm text-indigo-100">Gestisci studenti</div>
          </button>
        </div>
      </div>
    </div>
  );
}; 
import React, { useState } from 'react';
import { Clock, User, Zap, MessageCircle, CheckCircle, XCircle, Filter, Search } from 'lucide-react';

export const TutorRequests: React.FC = () => {
  const [activeTab, setActiveTab] = useState('new');
  const [searchQuery, setSearchQuery] = useState('');
  const [filterBy, setFilterBy] = useState('all');

  const requests = [
    {
      id: '1',
      studentName: 'Marco Verdi',
      studentAvatar: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Matematica',
      topic: 'Calcolo Differenziale - Limiti e Derivate',
      description: 'Ho difficoltà a comprendere il concetto di limite e come applicarlo nel calcolo delle derivate. Vorrei una spiegazione chiara con esempi pratici.',
      urgency: 'high',
      budget: 100,
      duration: 90,
      preferredTime: 'Oggi pomeriggio',
      status: 'new',
      createdAt: '2 ore fa',
      studentLevel: 'Universitario - 2° anno',
      previousSessions: 0
    },
    {
      id: '2',
      studentName: 'Laura Rossi',
      studentAvatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Fisica',
      topic: 'Meccanica Quantistica - Equazione di Schrödinger',
      description: 'Sto preparando l\'esame di Fisica Quantistica e ho bisogno di aiuto per comprendere l\'equazione di Schrödinger e le sue applicazioni.',
      urgency: 'medium',
      budget: 120,
      duration: 120,
      preferredTime: 'Domani mattina',
      status: 'new',
      createdAt: '4 ore fa',
      studentLevel: 'Universitario - 3° anno',
      previousSessions: 3
    },
    {
      id: '3',
      studentName: 'Alessandro Blu',
      studentAvatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Matematica',
      topic: 'Algebra Lineare - Spazi Vettoriali',
      description: 'Non riesco a capire bene i concetti di base degli spazi vettoriali e le trasformazioni lineari. Serve una spiegazione step-by-step.',
      urgency: 'low',
      budget: 80,
      duration: 60,
      preferredTime: 'Flessibile',
      status: 'responded',
      createdAt: '1 giorno fa',
      studentLevel: 'Universitario - 1° anno',
      previousSessions: 1,
      myResponse: {
        message: 'Ciao Alessandro! Posso aiutarti con gli spazi vettoriali. Ho molta esperienza con l\'algebra lineare e posso spiegarti tutto step-by-step.',
        proposedPrice: 80,
        proposedTime: 'Domani alle 15:00'
      }
    },
    {
      id: '4',
      studentName: 'Sofia Gialli',
      studentAvatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Fisica',
      topic: 'Termodinamica - Cicli Termodinamici',
      description: 'Devo preparare una presentazione sui cicli termodinamici per l\'esame. Vorrei capire meglio il ciclo di Carnot e l\'efficienza.',
      urgency: 'medium',
      budget: 90,
      duration: 75,
      preferredTime: 'Weekend',
      status: 'accepted',
      createdAt: '2 giorni fa',
      studentLevel: 'Universitario - 2° anno',
      previousSessions: 5,
      sessionScheduled: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000)
    }
  ];

  const getUrgencyColor = (urgency: string) => {
    switch (urgency) {
      case 'high':
        return 'bg-red-100 dark:bg-red-900/20 text-red-700 dark:text-red-300 border-red-200 dark:border-red-800';
      case 'medium':
        return 'bg-amber-100 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300 border-amber-200 dark:border-amber-800';
      case 'low':
        return 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800';
      default:
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300 border-stone-200 dark:border-stone-700';
    }
  };

  const getUrgencyLabel = (urgency: string) => {
    switch (urgency) {
      case 'high':
        return 'URGENTE';
      case 'medium':
        return 'NORMALE';
      case 'low':
        return 'FLESSIBILE';
      default:
        return urgency.toUpperCase();
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'new':
        return 'bg-blue-100 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300';
      case 'responded':
        return 'bg-amber-100 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300';
      case 'accepted':
        return 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300';
      case 'declined':
        return 'bg-red-100 dark:bg-red-900/20 text-red-700 dark:text-red-300';
      default:
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300';
    }
  };

  const filteredRequests = requests.filter(request => {
    if (activeTab === 'new' && request.status !== 'new') return false;
    if (activeTab === 'responded' && request.status !== 'responded') return false;
    if (activeTab === 'accepted' && request.status !== 'accepted') return false;
    if (activeTab === 'declined' && request.status !== 'declined') return false;

    if (searchQuery && !request.studentName.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !request.subject.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !request.topic.toLowerCase().includes(searchQuery.toLowerCase())) {
      return false;
    }

    if (filterBy === 'urgent' && request.urgency !== 'high') return false;
    if (filterBy === 'high-budget' && request.budget < 100) return false;

    return true;
  });

  const tabs = [
    { id: 'new', label: 'Nuove Richieste', count: requests.filter(r => r.status === 'new').length },
    { id: 'responded', label: 'Risposte Inviate', count: requests.filter(r => r.status === 'responded').length },
    { id: 'accepted', label: 'Accettate', count: requests.filter(r => r.status === 'accepted').length },
    { id: 'declined', label: 'Rifiutate', count: requests.filter(r => r.status === 'declined').length }
  ];

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
                <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">Richieste di Tutoraggio</span>
              </div>
              
              <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-stone-900 via-emerald-800 to-teal-800 dark:from-stone-100 dark:via-emerald-200 dark:to-teal-200 bg-clip-text text-transparent mb-4 leading-tight">
                Gestisci le Richieste
              </h1>
              <p className="text-xl text-stone-600 dark:text-stone-300 max-w-2xl leading-relaxed">
                Rispondi alle richieste degli studenti e costruisci la tua rete di tutoraggio.
              </p>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-blue-600 dark:text-blue-400 mb-1">
                  {requests.filter(r => r.status === 'new').length}
                </div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Nuove</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-emerald-600 dark:text-emerald-400 mb-1">
                  {requests.filter(r => r.status === 'accepted').length}
                </div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Accettate</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Tabs */}
        <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-2 mb-8">
          <div className="flex flex-wrap gap-2">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center space-x-2 px-4 py-3 rounded-xl font-medium transition-all duration-200 ${
                  activeTab === tab.id
                    ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white shadow-lg'
                    : 'text-stone-600 dark:text-stone-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 hover:text-emerald-600 dark:hover:text-emerald-400'
                }`}
              >
                <span>{tab.label}</span>
                <span className={`text-xs px-2 py-1 rounded-full ${
                  activeTab === tab.id
                    ? 'bg-white/20 text-white'
                    : 'bg-stone-200 dark:bg-stone-700 text-stone-600 dark:text-stone-400'
                }`}>
                  {tab.count}
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 mb-8">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            {/* Search */}
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-emerald-500 dark:text-emerald-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Cerca richieste..."
                className="w-full pl-12 pr-4 py-3 bg-white/90 dark:bg-stone-800/90 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
              />
            </div>

            {/* Filter Dropdown */}
            <div className="relative">
              <select
                value={filterBy}
                onChange={(e) => setFilterBy(e.target.value)}
                className="appearance-none px-4 py-3 pr-10 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200 font-medium"
              >
                <option value="all">Tutte le richieste</option>
                <option value="urgent">Solo urgenti</option>
                <option value="high-budget">Budget alto (100N+)</option>
              </select>
              <div className="absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
                <svg className="w-4 h-4 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </div>
          </div>
        </div>

        {/* Requests List */}
        <div className="space-y-6">
          {filteredRequests.map((request) => (
            <div 
              key={request.id}
              className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8 hover:shadow-lg transition-all duration-300"
            >
              {/* Request Header */}
              <div className="flex items-start justify-between mb-6">
                <div className="flex items-start space-x-4">
                  <img 
                    src={request.studentAvatar}
                    alt={request.studentName}
                    className="w-16 h-16 rounded-full object-cover border-2 border-emerald-200 dark:border-emerald-700"
                  />
                  
                  <div>
                    <div className="flex items-center space-x-3 mb-2">
                      <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100">
                        {request.studentName}
                      </h3>
                      <span className={`text-xs font-bold px-3 py-1 rounded-full border ${getUrgencyColor(request.urgency)}`}>
                        {getUrgencyLabel(request.urgency)}
                      </span>
                      <span className={`text-xs font-bold px-3 py-1 rounded-full ${getStatusColor(request.status)}`}>
                        {request.status === 'new' && 'NUOVA'}
                        {request.status === 'responded' && 'RISPOSTA INVIATA'}
                        {request.status === 'accepted' && 'ACCETTATA'}
                        {request.status === 'declined' && 'RIFIUTATA'}
                      </span>
                    </div>
                    <p className="text-stone-600 dark:text-stone-400 mb-1">
                      {request.studentLevel} • {request.previousSessions} sessioni precedenti
                    </p>
                    <p className="text-sm text-stone-500 dark:text-stone-500">
                      Richiesta inviata {request.createdAt}
                    </p>
                  </div>
                </div>

                <div className="text-right">
                  <div className="text-2xl font-bold text-emerald-600 dark:text-emerald-400 mb-1">
                    {request.budget}N
                  </div>
                  <div className="text-sm text-stone-500 dark:text-stone-500">
                    {request.duration} minuti
                  </div>
                </div>
              </div>

              {/* Subject and Topic */}
              <div className="mb-6">
                <div className="flex items-center space-x-2 mb-2">
                  <span className="text-sm font-medium bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 px-3 py-1 rounded-full">
                    {request.subject}
                  </span>
                </div>
                <h4 className="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-3">
                  {request.topic}
                </h4>
                <p className="text-stone-700 dark:text-stone-300 leading-relaxed">
                  {request.description}
                </p>
              </div>

              {/* Request Details */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6 p-4 bg-stone-50/50 dark:bg-stone-800/50 rounded-xl">
                <div className="flex items-center space-x-2">
                  <Clock className="w-4 h-4 text-stone-500 dark:text-stone-500" />
                  <div>
                    <div className="text-xs text-stone-500 dark:text-stone-500">Orario Preferito</div>
                    <div className="font-medium text-stone-900 dark:text-stone-100">{request.preferredTime}</div>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <Zap className="w-4 h-4 text-stone-500 dark:text-stone-500" />
                  <div>
                    <div className="text-xs text-stone-500 dark:text-stone-500">Budget</div>
                    <div className="font-medium text-stone-900 dark:text-stone-100">{request.budget} Neuroni</div>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <User className="w-4 h-4 text-stone-500 dark:text-stone-500" />
                  <div>
                    <div className="text-xs text-stone-500 dark:text-stone-500">Durata</div>
                    <div className="font-medium text-stone-900 dark:text-stone-100">{request.duration} minuti</div>
                  </div>
                </div>
              </div>

              {/* My Response (if responded) */}
              {request.status === 'responded' && request.myResponse && (
                <div className="mb-6 p-4 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 border border-amber-200/50 dark:border-amber-800/50 rounded-xl">
                  <h5 className="font-semibold text-amber-700 dark:text-amber-300 mb-2">La Tua Risposta:</h5>
                  <p className="text-amber-800 dark:text-amber-200 mb-3">{request.myResponse.message}</p>
                  <div className="flex items-center space-x-4 text-sm">
                    <span className="text-amber-700 dark:text-amber-300">
                      Prezzo proposto: <strong>{request.myResponse.proposedPrice}N</strong>
                    </span>
                    <span className="text-amber-700 dark:text-amber-300">
                      Orario proposto: <strong>{request.myResponse.proposedTime}</strong>
                    </span>
                  </div>
                </div>
              )}

              {/* Scheduled Session (if accepted) */}
              {request.status === 'accepted' && request.sessionScheduled && (
                <div className="mb-6 p-4 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/10 dark:to-teal-900/10 border border-emerald-200/50 dark:border-emerald-800/50 rounded-xl">
                  <h5 className="font-semibold text-emerald-700 dark:text-emerald-300 mb-2">Sessione Programmata:</h5>
                  <p className="text-emerald-800 dark:text-emerald-200">
                    {request.sessionScheduled.toLocaleDateString('it-IT', { 
                      weekday: 'long', 
                      day: 'numeric', 
                      month: 'long', 
                      hour: '2-digit', 
                      minute: '2-digit' 
                    })}
                  </p>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex space-x-3">
                {request.status === 'new' && (
                  <>
                    <button className="flex-1 bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center justify-center space-x-2">
                      <MessageCircle className="w-4 h-4" />
                      <span>Rispondi alla Richiesta</span>
                    </button>
                    <button className="border border-stone-300 dark:border-stone-600 text-stone-600 dark:text-stone-400 font-bold py-3 px-6 rounded-xl hover:bg-stone-50 dark:hover:bg-stone-800/50 transition-colors flex items-center justify-center space-x-2">
                      <XCircle className="w-4 h-4" />
                      <span>Rifiuta</span>
                    </button>
                  </>
                )}

                {request.status === 'responded' && (
                  <button className="flex-1 border border-amber-300 dark:border-amber-600 text-amber-600 dark:text-amber-400 font-bold py-3 px-6 rounded-xl hover:bg-amber-50 dark:hover:bg-amber-900/10 transition-colors">
                    In Attesa di Risposta
                  </button>
                )}

                {request.status === 'accepted' && (
                  <button className="flex-1 bg-gradient-to-r from-blue-400 to-indigo-500 text-white font-bold py-3 px-6 rounded-xl hover:from-blue-500 hover:to-indigo-600 transition-all duration-200 flex items-center justify-center space-x-2">
                    <MessageCircle className="w-4 h-4" />
                    <span>Contatta Studente</span>
                  </button>
                )}
              </div>
            </div>
          ))}

          {/* Empty State */}
          {filteredRequests.length === 0 && (
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-12 text-center">
              <div className="text-6xl mb-4">📝</div>
              <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2">
                Nessuna richiesta trovata
              </h3>
              <p className="text-stone-600 dark:text-stone-400 mb-6">
                {searchQuery 
                  ? `Nessuna richiesta corrisponde alla ricerca "${searchQuery}"`
                  : `Non ci sono richieste ${activeTab === 'new' ? 'nuove' : activeTab} al momento.`
                }
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
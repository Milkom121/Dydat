import React, { useState } from 'react';
import { Send, Clock, DollarSign, AlertCircle } from 'lucide-react';
import { SPECIALIZATIONS } from '../../types/tutoring';

export const QuickRequestForm: React.FC = () => {
  const [formData, setFormData] = useState({
    subject: '',
    description: '',
    urgency: 'medium',
    budget: '',
    duration: '60',
    preferredTime: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission
    console.log('Quick request submitted:', formData);
  };

  const urgencyOptions = [
    { value: 'low', label: 'Flessibile', description: 'Entro qualche giorno', color: 'emerald' },
    { value: 'medium', label: 'Normale', description: 'Entro 24 ore', color: 'amber' },
    { value: 'high', label: 'Urgente', description: 'Entro poche ore', color: 'red' }
  ];

  const durationOptions = [
    { value: '30', label: '30 minuti' },
    { value: '60', label: '1 ora' },
    { value: '90', label: '1.5 ore' },
    { value: '120', label: '2 ore' }
  ];

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 overflow-hidden">
      {/* Header */}
      <div className="bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/20 dark:to-teal-900/20 p-8 border-b border-emerald-200/50 dark:border-emerald-800/50">
        <div className="text-center">
          <div className="text-4xl mb-4">⚡</div>
          <h2 className="text-3xl font-bold text-stone-900 dark:text-stone-100 mb-4">
            Richiesta Rapida di Tutoraggio
          </h2>
          <p className="text-lg text-stone-600 dark:text-stone-400 max-w-2xl mx-auto">
            Descrivi di cosa hai bisogno e ricevi proposte personalizzate dai nostri tutor esperti
          </p>
        </div>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="p-8 space-y-8">
        {/* Subject Selection */}
        <div className="space-y-4">
          <label className="block text-lg font-semibold text-stone-900 dark:text-stone-100">
            Materia di Studio
          </label>
          <select
            value={formData.subject}
            onChange={(e) => setFormData(prev => ({ ...prev, subject: e.target.value }))}
            className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            required
          >
            <option value="">Seleziona una materia</option>
            {SPECIALIZATIONS.map(spec => (
              <option key={spec} value={spec}>{spec}</option>
            ))}
          </select>
        </div>

        {/* Description */}
        <div className="space-y-4">
          <label className="block text-lg font-semibold text-stone-900 dark:text-stone-100">
            Descrizione del Problema
          </label>
          <textarea
            value={formData.description}
            onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
            placeholder="Descrivi in dettaglio di cosa hai bisogno. Più informazioni fornisci, migliori saranno le proposte che riceverai..."
            rows={6}
            className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200 resize-none"
            required
          />
          <div className="text-sm text-stone-500 dark:text-stone-500">
            Suggerimento: Includi il tuo livello attuale, argomenti specifici e obiettivi
          </div>
        </div>

        {/* Urgency and Duration */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Urgency */}
          <div className="space-y-4">
            <label className="block text-lg font-semibold text-stone-900 dark:text-stone-100">
              Urgenza
            </label>
            <div className="space-y-3">
              {urgencyOptions.map((option) => (
                <label
                  key={option.value}
                  className={`flex items-center space-x-4 p-4 rounded-xl border-2 cursor-pointer transition-all duration-200 ${
                    formData.urgency === option.value
                      ? `border-${option.color}-300 dark:border-${option.color}-600 bg-${option.color}-50 dark:bg-${option.color}-900/10`
                      : 'border-stone-200/50 dark:border-stone-700/50 hover:border-stone-300 dark:hover:border-stone-600'
                  }`}
                >
                  <input
                    type="radio"
                    name="urgency"
                    value={option.value}
                    checked={formData.urgency === option.value}
                    onChange={(e) => setFormData(prev => ({ ...prev, urgency: e.target.value }))}
                    className="sr-only"
                  />
                  <div className={`w-4 h-4 rounded-full border-2 ${
                    formData.urgency === option.value
                      ? `border-${option.color}-500 bg-${option.color}-500`
                      : 'border-stone-300 dark:border-stone-600'
                  }`}>
                    {formData.urgency === option.value && (
                      <div className="w-full h-full rounded-full bg-white scale-50"></div>
                    )}
                  </div>
                  <div className="flex-1">
                    <div className="font-medium text-stone-900 dark:text-stone-100">
                      {option.label}
                    </div>
                    <div className="text-sm text-stone-500 dark:text-stone-500">
                      {option.description}
                    </div>
                  </div>
                </label>
              ))}
            </div>
          </div>

          {/* Duration */}
          <div className="space-y-4">
            <label className="block text-lg font-semibold text-stone-900 dark:text-stone-100">
              Durata Stimata
            </label>
            <select
              value={formData.duration}
              onChange={(e) => setFormData(prev => ({ ...prev, duration: e.target.value }))}
              className="w-full px-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            >
              {durationOptions.map(option => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>

            {/* Budget */}
            <div className="space-y-2">
              <label className="block text-lg font-semibold text-stone-900 dark:text-stone-100">
                Budget Massimo (Neuroni)
              </label>
              <div className="relative">
                <DollarSign className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-emerald-500" />
                <input
                  type="number"
                  value={formData.budget}
                  onChange={(e) => setFormData(prev => ({ ...prev, budget: e.target.value }))}
                  placeholder="es. 100"
                  className="w-full pl-12 pr-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
                />
              </div>
              <div className="text-sm text-stone-500 dark:text-stone-500">
                Lascia vuoto per ricevere proposte di prezzo dai tutor
              </div>
            </div>
          </div>
        </div>

        {/* Preferred Time */}
        <div className="space-y-4">
          <label className="block text-lg font-semibold text-stone-900 dark:text-stone-100">
            Orario Preferito (Opzionale)
          </label>
          <div className="relative">
            <Clock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-emerald-500" />
            <input
              type="datetime-local"
              value={formData.preferredTime}
              onChange={(e) => setFormData(prev => ({ ...prev, preferredTime: e.target.value }))}
              className="w-full pl-12 pr-4 py-3 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
            />
          </div>
        </div>

        {/* Info Box */}
        <div className="bg-gradient-to-r from-blue-50 to-cyan-50 dark:from-blue-900/10 dark:to-cyan-900/10 border border-blue-200/50 dark:border-blue-800/50 rounded-xl p-6">
          <div className="flex items-start space-x-3">
            <AlertCircle className="w-5 h-5 text-blue-600 dark:text-blue-400 mt-0.5 flex-shrink-0" />
            <div>
              <h4 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">
                Come Funziona
              </h4>
              <ul className="text-sm text-blue-800 dark:text-blue-200 space-y-1">
                <li>• I tutor riceveranno la tua richiesta e potranno inviarti proposte personalizzate</li>
                <li>• Riceverai notifiche per ogni nuova proposta</li>
                <li>• Potrai confrontare i profili e scegliere il tutor più adatto</li>
                <li>• Il pagamento avviene solo dopo aver confermato la sessione</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Submit Button */}
        <button
          type="submit"
          className="w-full bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-4 px-8 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 transform hover:scale-105 shadow-lg flex items-center justify-center space-x-3 text-lg"
        >
          <Send className="w-5 h-5" />
          <span>Invia Richiesta di Tutoraggio</span>
        </button>
      </form>
    </div>
  );
};
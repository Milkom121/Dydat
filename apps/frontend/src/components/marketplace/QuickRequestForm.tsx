import React, { useState } from 'react';
import { Clock, Calendar, DollarSign, BookOpen, Send, Zap } from 'lucide-react';

export const QuickRequestForm: React.FC = () => {
  const [formData, setFormData] = useState({
    subject: '',
    topic: '',
    urgency: 'normale',
    duration: '60',
    preferredTime: '',
    budget: '',
    description: '',
    learningGoal: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Quick request submitted:', formData);
    // Handle form submission
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  const subjects = [
    'Programmazione', 'Matematica', 'Fisica', 'Chimica', 'Inglese',
    'Spagnolo', 'Francese', 'Storia', 'Geografia', 'Filosofia',
    'Design', 'Marketing', 'Business', 'Data Science'
  ];

  const urgencyOptions = [
    { value: 'normale', label: 'Normale (entro 24h)', color: 'green' },
    { value: 'urgente', label: 'Urgente (entro 6h)', color: 'yellow' },
    { value: 'molto_urgente', label: 'Molto urgente (entro 2h)', color: 'red' }
  ];

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-3xl border border-white/50 dark:border-stone-800/50 shadow-2xl overflow-hidden">
      {/* Header */}
      <div className="bg-gradient-to-r from-emerald-500 to-teal-600 p-8 text-white">
        <div className="flex items-center space-x-4 mb-4">
          <div className="w-12 h-12 bg-white/20 rounded-2xl flex items-center justify-center">
            <Zap className="w-6 h-6" />
          </div>
          <div>
            <h2 className="text-3xl font-bold">Richiesta Rapida</h2>
            <p className="text-emerald-100">Trova il tutor perfetto in pochi minuti</p>
          </div>
        </div>
        
        <div className="grid grid-cols-3 gap-4 text-center">
          <div className="bg-white/10 rounded-xl p-3">
            <div className="text-2xl font-bold">&lt; 2h</div>
            <div className="text-sm text-emerald-100">Risposta media</div>
          </div>
          <div className="bg-white/10 rounded-xl p-3">
            <div className="text-2xl font-bold">98%</div>
            <div className="text-sm text-emerald-100">Successo match</div>
          </div>
          <div className="bg-white/10 rounded-xl p-3">
            <div className="text-2xl font-bold">500+</div>
            <div className="text-sm text-emerald-100">Tutor disponibili</div>
          </div>
        </div>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="p-8 space-y-8">
        {/* Subject and Topic */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-3">
            <label className="block text-sm font-bold text-stone-700 dark:text-stone-300">
              <BookOpen className="w-4 h-4 inline mr-2" />
              Materia
            </label>
            <select
              name="subject"
              value={formData.subject}
              onChange={handleChange}
              required
              className="w-full px-4 py-4 border-2 border-stone-200 dark:border-stone-700 rounded-xl bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-500 transition-all duration-200"
            >
              <option value="">Seleziona una materia</option>
              {subjects.map(subject => (
                <option key={subject} value={subject}>{subject}</option>
              ))}
            </select>
          </div>

          <div className="space-y-3">
            <label className="block text-sm font-bold text-stone-700 dark:text-stone-300">
              Argomento Specifico
            </label>
            <input
              type="text"
              name="topic"
              value={formData.topic}
              onChange={handleChange}
              placeholder="es. React Hooks, Equazioni differenziali..."
              className="w-full px-4 py-4 border-2 border-stone-200 dark:border-stone-700 rounded-xl bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-500 transition-all duration-200"
            />
          </div>
        </div>

        {/* Urgency */}
        <div className="space-y-3">
          <label className="block text-sm font-bold text-stone-700 dark:text-stone-300">
            <Clock className="w-4 h-4 inline mr-2" />
            Urgenza
          </label>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {urgencyOptions.map(option => (
              <label
                key={option.value}
                className={`relative flex items-center p-4 border-2 rounded-xl cursor-pointer transition-all duration-200 ${
                  formData.urgency === option.value
                    ? 'border-emerald-400 bg-emerald-50 dark:bg-emerald-900/20'
                    : 'border-stone-200 dark:border-stone-700 hover:border-stone-300 dark:hover:border-stone-600'
                }`}
              >
                <input
                  type="radio"
                  name="urgency"
                  value={option.value}
                  checked={formData.urgency === option.value}
                  onChange={handleChange}
                  className="sr-only"
                />
                <div className="flex-1">
                  <div className="font-semibold text-stone-900 dark:text-stone-100">
                    {option.label}
                  </div>
                </div>
                {formData.urgency === option.value && (
                  <div className="w-4 h-4 bg-emerald-500 rounded-full"></div>
                )}
              </label>
            ))}
          </div>
        </div>

        {/* Duration and Budget */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-3">
            <label className="block text-sm font-bold text-stone-700 dark:text-stone-300">
              <Calendar className="w-4 h-4 inline mr-2" />
              Durata (minuti)
            </label>
            <select
              name="duration"
              value={formData.duration}
              onChange={handleChange}
              className="w-full px-4 py-4 border-2 border-stone-200 dark:border-stone-700 rounded-xl bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-500 transition-all duration-200"
            >
              <option value="30">30 minuti</option>
              <option value="60">1 ora</option>
              <option value="90">1.5 ore</option>
              <option value="120">2 ore</option>
            </select>
          </div>

          <div className="space-y-3">
            <label className="block text-sm font-bold text-stone-700 dark:text-stone-300">
              <DollarSign className="w-4 h-4 inline mr-2" />
              Budget (€/ora)
            </label>
            <select
              name="budget"
              value={formData.budget}
              onChange={handleChange}
              className="w-full px-4 py-4 border-2 border-stone-200 dark:border-stone-700 rounded-xl bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-500 transition-all duration-200"
            >
              <option value="">Seleziona budget</option>
              <option value="15-25">€15-25/ora</option>
              <option value="25-35">€25-35/ora</option>
              <option value="35-50">€35-50/ora</option>
              <option value="50+">€50+/ora</option>
            </select>
          </div>
        </div>

        {/* Learning Goal */}
        <div className="space-y-3">
          <label className="block text-sm font-bold text-stone-700 dark:text-stone-300">
            Obiettivo di Apprendimento
          </label>
          <input
            type="text"
            name="learningGoal"
            value={formData.learningGoal}
            onChange={handleChange}
            placeholder="Cosa vuoi ottenere da questa sessione?"
            className="w-full px-4 py-4 border-2 border-stone-200 dark:border-stone-700 rounded-xl bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-500 transition-all duration-200"
          />
        </div>

        {/* Description */}
        <div className="space-y-3">
          <label className="block text-sm font-bold text-stone-700 dark:text-stone-300">
            Descrizione Dettagliata
          </label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            rows={4}
            placeholder="Descrivi in dettaglio cosa ti serve, il tuo livello attuale e qualsiasi informazione utile per il tutor..."
            className="w-full px-4 py-4 border-2 border-stone-200 dark:border-stone-700 rounded-xl bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-500 transition-all duration-200 resize-none"
          />
        </div>

        {/* Submit Button */}
        <div className="flex items-center justify-center pt-6">
          <button
            type="submit"
            className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white font-bold py-4 px-12 rounded-2xl hover:from-emerald-600 hover:to-teal-700 transition-all duration-200 flex items-center space-x-3 shadow-xl hover:shadow-2xl transform hover:scale-105"
          >
            <Send className="w-5 h-5" />
            <span>Invia Richiesta</span>
          </button>
        </div>

        {/* Help Text */}
        <div className="text-center text-sm text-stone-600 dark:text-stone-400 bg-stone-50 dark:bg-stone-800/50 p-4 rounded-xl">
          <p>🚀 <strong>Come funziona:</strong> Invii la richiesta → I tutor disponibili ricevono una notifica → Ricevi proposte entro 2 ore → Scegli il tutor migliore!</p>
        </div>
      </form>
    </div>
  );
}; 
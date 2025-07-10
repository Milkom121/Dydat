export default function ProfiloPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          Profilo Tutor
        </h1>
        <p className="text-stone-600 dark:text-stone-400 mt-1">
          Gestisci il tuo profilo, competenze e tariffe
        </p>
      </div>
      
      <div className="bg-white dark:bg-stone-800 rounded-lg p-8 text-center">
        <div className="text-6xl mb-4">👤</div>
        <h2 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2">
          Profilo Tutor in Sviluppo
        </h2>
        <p className="text-stone-600 dark:text-stone-400">
          Questa sezione sarà disponibile nelle prossime release
        </p>
      </div>
    </div>
  );
} 
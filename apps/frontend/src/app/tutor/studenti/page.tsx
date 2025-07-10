export default function StudentiPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          I Miei Studenti
        </h1>
        <p className="text-stone-600 dark:text-stone-400 mt-1">
          Gestisci i tuoi studenti e monitora i loro progressi
        </p>
      </div>
      
      <div className="bg-white dark:bg-stone-800 rounded-lg p-8 text-center">
        <div className="text-6xl mb-4">👥</div>
        <h2 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2">
          Gestione Studenti in Sviluppo
        </h2>
        <p className="text-stone-600 dark:text-stone-400">
          Questa sezione sarà disponibile nelle prossime release
        </p>
      </div>
    </div>
  );
} 
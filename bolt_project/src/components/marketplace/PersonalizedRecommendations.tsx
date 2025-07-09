import React from 'react';
import { Brain, TrendingUp, Clock, Star } from 'lucide-react';

export const PersonalizedRecommendations: React.FC = () => {
  const recommendations = [
    {
      id: 1,
      title: 'Next.js 14: App Router e Server Components',
      instructor: 'Luca Verdi',
      rating: 4.9,
      students: 2341,
      duration: '9h 30min',
      price: 79.99,
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      reason: 'Basato sui tuoi progressi in React',
      matchPercentage: 95
    },
    {
      id: 2,
      title: 'Advanced CSS: Grid, Flexbox e Animazioni',
      instructor: 'Elena Rossi',
      rating: 4.7,
      students: 1876,
      duration: '7h 15min',
      price: 59.99,
      image: 'https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      reason: 'Perfetto per il tuo livello attuale',
      matchPercentage: 88
    },
    {
      id: 3,
      title: 'Node.js e MongoDB: API REST Complete',
      instructor: 'Marco Blu',
      rating: 4.8,
      students: 3421,
      duration: '12h 45min',
      price: 89.99,
      image: 'https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      reason: 'Completa il tuo stack full-stack',
      matchPercentage: 92
    }
  ];

  return (
    <div className="mb-16">
      <div className="flex items-center space-x-4 mb-8">
        <div className="p-3 bg-gradient-to-r from-amber-400 to-orange-500 rounded-xl shadow-lg">
          <Brain className="w-5 h-5 text-white" />
        </div>
        <div>
          <h2 className="text-3xl font-bold text-stone-900 dark:text-stone-100">
            Consigliati per Te
          </h2>
          <p className="text-lg text-stone-600 dark:text-stone-400">
            Selezionati dall'AI in base al tuo profilo e ai tuoi progressi
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {recommendations.map((course) => (
          <div 
            key={course.id}
            className="group bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border-2 border-white/50 dark:border-stone-800/50 overflow-hidden hover:shadow-2xl transition-all duration-500 hover:scale-105 hover:border-amber-300/50 dark:hover:border-amber-600/50"
          >
            {/* AI Match Badge */}
            <div className="relative">
              <img 
                src={course.image}
                alt={course.title}
                className="w-full h-52 object-cover transition-transform duration-500 group-hover:scale-110"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div className="absolute top-4 left-4 bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-bold px-4 py-2 rounded-full flex items-center space-x-2 shadow-lg">
                <Brain className="w-3 h-3" />
                <span>{course.matchPercentage}% match</span>
              </div>
            </div>

            <div className="p-6">
              {/* AI Reason */}
              <div className="flex items-center space-x-3 mb-4 p-3 bg-gradient-to-r from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20 rounded-xl border border-purple-200/50 dark:border-purple-700/50">
                <TrendingUp className="w-4 h-4 text-purple-600 dark:text-purple-400" />
                <span className="text-sm font-medium text-purple-700 dark:text-purple-300">
                  {course.reason}
                </span>
              </div>

              {/* Course Info */}
              <h3 className="font-bold text-lg text-stone-900 dark:text-stone-100 mb-3 line-clamp-2 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                {course.title}
              </h3>
              
              <p className="text-stone-600 dark:text-stone-400 mb-4 font-medium">
                {course.instructor}
              </p>

              <div className="flex items-center justify-between text-stone-500 dark:text-stone-500 mb-6">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 fill-current text-amber-400" />
                  <span className="font-medium">{course.rating}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="w-4 h-4" />
                  <span className="font-medium">{course.duration}</span>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <span className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                  €{course.price}
                </span>
                <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-bold py-3 px-6 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200 transform hover:scale-105 shadow-lg">
                  Scopri
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
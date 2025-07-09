import React from 'react';
import { Star, Clock, Users, Award, TrendingUp } from 'lucide-react';

export const FeaturedCourses: React.FC = () => {
  const featuredCourses = [
    {
      id: 1,
      title: 'AI & Machine Learning Masterclass',
      instructor: 'Dr. Marco Alberti',
      rating: 4.9,
      reviewCount: 2847,
      students: 18456,
      duration: '25h 30min',
      price: 159.99,
      originalPrice: 229.99,
      category: 'AI & Data Science',
      image: 'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
      description: 'Corso completo sull\'intelligenza artificiale e machine learning con progetti pratici e casi reali.',
      trending: true
    },
    {
      id: 2,
      title: 'React & Next.js Advanced Development',
      instructor: 'Laura Fontana',
      rating: 4.8,
      reviewCount: 1534,
      students: 12890,
      duration: '18h 45min',
      price: 129.99,
      originalPrice: 189.99,
      category: 'Programmazione',
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
      description: 'Sviluppo avanzato con React e Next.js: performance, SEO, e architetture scalabili.',
      trending: false
    },
    {
      id: 3,
      title: 'Digital Marketing Strategy 2024',
      instructor: 'Alessandro Bianchi',
      rating: 4.7,
      reviewCount: 987,
      students: 8743,
      duration: '12h 20min',
      price: 89.99,
      originalPrice: 139.99,
      category: 'Marketing',
      image: 'https://images.pexels.com/photos/265087/pexels-photo-265087.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
      description: 'Strategie di marketing digitale aggiornate per il 2024: social media, content marketing e analytics.',
      trending: true
    }
  ];

  return (
    <div className="mb-16">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h2 className="text-3xl font-bold text-stone-900 dark:text-stone-100 mb-2">
            Corsi in Evidenza
          </h2>
          <p className="text-stone-600 dark:text-stone-400">
            I corsi più apprezzati dalla nostra community
          </p>
        </div>
        <button className="text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 font-semibold transition-colors">
          Vedi tutti →
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {featuredCourses.map((course, index) => (
          <div 
            key={course.id}
            className={`group relative overflow-hidden rounded-2xl ${
              index === 0 
                ? 'lg:col-span-2 lg:row-span-1' 
                : 'lg:col-span-1'
            }`}
          >
            {/* Background Image */}
            <div className="relative h-80 lg:h-96 overflow-hidden">
              <img
                src={course.image}
                alt={course.title}
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
              />
              
              {/* Gradient Overlay */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>
              
              {/* Trending Badge */}
              {course.trending && (
                <div className="absolute top-6 left-6">
                  <div className="flex items-center space-x-2 bg-gradient-to-r from-red-500 to-pink-500 text-white px-4 py-2 rounded-full shadow-lg">
                    <TrendingUp className="w-4 h-4" />
                    <span className="text-sm font-bold">Trending</span>
                  </div>
                </div>
              )}

              {/* Discount Badge */}
              <div className="absolute top-6 right-6">
                <div className="bg-gradient-to-r from-amber-400 to-orange-500 text-white px-4 py-2 rounded-full shadow-lg">
                  <span className="text-sm font-bold">
                    -{Math.round((1 - course.price / course.originalPrice) * 100)}%
                  </span>
                </div>
              </div>
            </div>

            {/* Content Overlay */}
            <div className="absolute inset-0 flex flex-col justify-end p-8">
              {/* Category */}
              <div className="mb-4">
                <span className="inline-block bg-white/20 backdrop-blur-sm text-white text-sm font-medium px-4 py-2 rounded-full border border-white/30">
                  {course.category}
                </span>
              </div>

              {/* Title and Instructor */}
              <div className="mb-4">
                <h3 className={`font-bold text-white mb-2 group-hover:text-amber-300 transition-colors ${
                  index === 0 ? 'text-2xl lg:text-3xl' : 'text-xl'
                }`}>
                  {course.title}
                </h3>
                <p className="text-white/80 text-sm">
                  di {course.instructor}
                </p>
              </div>

              {/* Stats */}
              <div className="flex items-center space-x-6 mb-4 text-white/90 text-sm">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 fill-current text-amber-400" />
                  <span className="font-semibold">{course.rating}</span>
                  <span className="text-white/70">({course.reviewCount})</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Users className="w-4 h-4" />
                  <span>{course.students.toLocaleString()}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="w-4 h-4" />
                  <span>{course.duration}</span>
                </div>
              </div>

              {/* Description */}
              <p className="text-white/80 text-sm mb-6 line-clamp-2">
                {course.description}
              </p>

              {/* Price and CTA */}
              <div className="flex items-center justify-between">
                <div className="space-y-1">
                  <div className="flex items-center space-x-3">
                    <span className="text-2xl font-bold text-white">
                      €{course.price}
                    </span>
                    <span className="text-white/60 line-through text-lg">
                      €{course.originalPrice}
                    </span>
                  </div>
                </div>
                
                <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-bold py-3 px-8 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
                  Iscriviti Ora
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}; 
import React from 'react';
import { Crown, Star, Users, Clock } from 'lucide-react';

export const FeaturedCourses: React.FC = () => {
  const featuredCourses = [
    {
      id: 1,
      title: 'Masterclass: Full-Stack Development 2024',
      instructor: 'Team Dydat',
      rating: 4.9,
      students: 15678,
      duration: '45h 30min',
      price: 199.99,
      originalPrice: 299.99,
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
      description: 'Il corso più completo per diventare un full-stack developer moderno.',
      featured: true,
      lessons: 120
    },
    {
      id: 2,
      title: 'AI e Machine Learning con Python',
      instructor: 'Dr. Alessandro Neri',
      rating: 4.8,
      students: 8934,
      duration: '32h 15min',
      price: 149.99,
      originalPrice: 199.99,
      image: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
      description: 'Impara l\'intelligenza artificiale dalle basi ai modelli avanzati.',
      featured: true,
      lessons: 85
    }
  ];

  return (
    <div className="mb-16">
      <div className="flex items-center space-x-4 mb-8">
        <div className="p-3 bg-gradient-to-r from-purple-500 to-pink-500 rounded-xl shadow-lg">
          <Crown className="w-5 h-5 text-white" />
        </div>
        <div>
          <h2 className="text-3xl font-bold text-stone-900 dark:text-stone-100">
            Corsi in Evidenza
          </h2>
          <p className="text-lg text-stone-600 dark:text-stone-400">
            I migliori corsi selezionati dal nostro team
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {featuredCourses.map((course) => (
          <div 
            key={course.id}
            className="group bg-gradient-to-br from-white/95 to-stone-50/95 dark:from-stone-900/95 dark:to-stone-800/95 backdrop-blur-sm rounded-3xl border-2 border-amber-200/50 dark:border-amber-800/50 overflow-hidden hover:shadow-2xl transition-all duration-500 hover:scale-105 hover:border-amber-300 dark:hover:border-amber-600"
          >
            <div className="relative">
              <img 
                src={course.image}
                alt={course.title}
                className="w-full h-72 object-cover transition-transform duration-500 group-hover:scale-110"
              />
              
              {/* Gradient Overlay */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              
              {/* Featured Badge */}
              <div className="absolute top-6 left-6 bg-gradient-to-r from-purple-500 to-pink-500 text-white font-bold px-5 py-3 rounded-full flex items-center space-x-2 shadow-xl">
                <Crown className="w-4 h-4" />
                <span>FEATURED</span>
              </div>

              {/* Discount Badge */}
              <div className="absolute top-6 right-6 bg-gradient-to-r from-red-500 to-red-600 text-white font-bold px-4 py-2 rounded-full shadow-xl">
                -33%
              </div>
            </div>

            <div className="p-10">
              <h3 className="text-3xl font-bold text-stone-900 dark:text-stone-100 mb-4 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors leading-tight">
                {course.title}
              </h3>
              
              <p className="text-lg text-stone-600 dark:text-stone-400 mb-3 font-medium">
                di {course.instructor}
              </p>

              <p className="text-stone-600 dark:text-stone-400 mb-8 text-lg leading-relaxed">
                {course.description}
              </p>

              {/* Stats */}
              <div className="flex items-center space-x-8 text-stone-500 dark:text-stone-500 mb-8">
                <div className="flex items-center space-x-1">
                  <Star className="w-5 h-5 fill-current text-amber-400" />
                  <span className="font-bold text-lg">{course.rating}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Users className="w-5 h-5" />
                  <span className="font-medium">{course.students.toLocaleString()}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="w-5 h-5" />
                  <span className="font-medium">{course.duration}</span>
                </div>
              </div>

              {/* Price and CTA */}
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center space-x-4">
                    <span className="text-4xl font-bold text-stone-900 dark:text-stone-100">
                      €{course.price}
                    </span>
                    <span className="text-xl text-stone-500 dark:text-stone-500 line-through">
                      €{course.originalPrice}
                    </span>
                  </div>
                  <p className="text-stone-500 dark:text-stone-500 font-medium mt-1">
                    {course.lessons} lezioni incluse
                  </p>
                </div>
                
                <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-bold py-5 px-10 rounded-2xl hover:from-amber-500 hover:to-orange-600 transition-all duration-300 transform hover:scale-105 shadow-xl hover:shadow-2xl">
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
/**
 * Footer Component - Dydat Design System
 * Main footer with links, social media and company information
 */

'use client';

import * as React from 'react';
import Link from 'next/link';
import { cn } from '@/lib/utils';
import { 
  Github, 
  Twitter, 
  Linkedin, 
  Mail, 
  Heart,
  Sparkles,
  BookOpen,
  Users,
  Shield,
  HelpCircle
} from 'lucide-react';

interface FooterProps {
  className?: string;
  variant?: 'default' | 'minimal' | 'glass';
}

const Footer = React.forwardRef<HTMLElement, FooterProps>(
  ({ className, variant = 'default' }, ref) => {
    const currentYear = new Date().getFullYear();

    const footerVariants = {
      default: "bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800",
      minimal: "bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700",
      glass: "glass border-t border-white/10 dark:border-gray-800/50"
    };

    const footerLinks = {
      product: [
        { name: 'Funzionalità', href: '/features' },
        { name: 'Prezzi', href: '/pricing' },
        { name: 'API', href: '/api' },
        { name: 'Integrazioni', href: '/integrations' },
      ],
      company: [
        { name: 'Chi Siamo', href: '/about' },
        { name: 'Blog', href: '/blog' },
        { name: 'Carriere', href: '/careers' },
        { name: 'Contatti', href: '/contact' },
      ],
      support: [
        { name: 'Centro Assistenza', href: '/help' },
        { name: 'Documentazione', href: '/docs' },
        { name: 'Status', href: '/status' },
        { name: 'Feedback', href: '/feedback' },
      ],
      legal: [
        { name: 'Privacy Policy', href: '/privacy' },
        { name: 'Termini di Servizio', href: '/terms' },
        { name: 'Cookie Policy', href: '/cookies' },
        { name: 'GDPR', href: '/gdpr' },
      ],
    };

    const socialLinks = [
      { name: 'GitHub', href: 'https://github.com/dydat', icon: Github },
      { name: 'Twitter', href: 'https://twitter.com/dydat', icon: Twitter },
      { name: 'LinkedIn', href: 'https://linkedin.com/company/dydat', icon: Linkedin },
      { name: 'Email', href: 'mailto:info@dydat.com', icon: Mail },
    ];

    const quickStats = [
      { label: 'Studenti Attivi', value: '10K+', icon: Users },
      { label: 'Corsi Disponibili', value: '500+', icon: BookOpen },
      { label: 'Creators', value: '100+', icon: Sparkles },
      { label: 'Uptime', value: '99.9%', icon: Shield },
    ];

    if (variant === 'minimal') {
      return (
        <footer 
          ref={ref}
          className={cn(footerVariants[variant], className)}
        >
          <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
              <div className="flex items-center space-x-2">
                <div className="w-6 h-6 bg-gradient-primary rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-xs">D</span>
                </div>
                <span className="text-sm text-gray-600 dark:text-gray-300">
                  © {currentYear} Dydat. Tutti i diritti riservati.
                </span>
              </div>
              <div className="flex items-center space-x-4">
                {socialLinks.map((item) => {
                  const Icon = item.icon;
                  return (
                    <Link
                      key={item.name}
                      href={item.href}
                      className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                      aria-label={item.name}
                    >
                      <Icon className="w-4 h-4" />
                    </Link>
                  );
                })}
              </div>
            </div>
          </div>
        </footer>
      );
    }

    return (
      <footer 
        ref={ref}
        className={cn(footerVariants[variant], className)}
      >
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          {/* Main Footer Content */}
          <div className="py-12">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-8">
              {/* Brand Section */}
              <div className="lg:col-span-2">
                <Link href="/" className="flex items-center space-x-2 mb-4">
                  <div className="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center">
                    <span className="text-white font-bold text-sm">D</span>
                  </div>
                  <span className="text-xl font-bold text-gray-900 dark:text-white">
                    Dydat
                  </span>
                  <Sparkles className="w-4 h-4 text-primary-500" />
                </Link>
                <p className="text-gray-600 dark:text-gray-300 mb-6 max-w-sm">
                  L'ecosistema di apprendimento intelligente che trasforma l'educazione 
                  con AI e gamification.
                </p>
                
                {/* Quick Stats */}
                <div className="grid grid-cols-2 gap-4 mb-6">
                  {quickStats.map((stat) => {
                    const Icon = stat.icon;
                    return (
                      <div key={stat.label} className="text-center p-3 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700">
                        <Icon className="w-5 h-5 text-primary-500 mx-auto mb-1" />
                        <div className="text-lg font-bold text-gray-900 dark:text-white">
                          {stat.value}
                        </div>
                        <div className="text-xs text-gray-500 dark:text-gray-400">
                          {stat.label}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Product Links */}
              <div>
                <h3 className="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wider mb-4">
                  Prodotto
                </h3>
                <ul className="space-y-3">
                  {footerLinks.product.map((link) => (
                    <li key={link.name}>
                      <Link
                        href={link.href}
                        className="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
                      >
                        {link.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Company Links */}
              <div>
                <h3 className="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wider mb-4">
                  Azienda
                </h3>
                <ul className="space-y-3">
                  {footerLinks.company.map((link) => (
                    <li key={link.name}>
                      <Link
                        href={link.href}
                        className="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
                      >
                        {link.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Support Links */}
              <div>
                <h3 className="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wider mb-4">
                  Supporto
                </h3>
                <ul className="space-y-3">
                  {footerLinks.support.map((link) => (
                    <li key={link.name}>
                      <Link
                        href={link.href}
                        className="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
                      >
                        {link.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Legal Links */}
              <div>
                <h3 className="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wider mb-4">
                  Legale
                </h3>
                <ul className="space-y-3">
                  {footerLinks.legal.map((link) => (
                    <li key={link.name}>
                      <Link
                        href={link.href}
                        className="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
                      >
                        {link.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>

          {/* Bottom Section */}
          <div className="border-t border-gray-200 dark:border-gray-800 py-6">
            <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
              <div className="flex items-center space-x-2 text-sm text-gray-600 dark:text-gray-300">
                <span>© {currentYear} Dydat. Tutti i diritti riservati.</span>
                <span className="hidden md:inline">•</span>
                <span className="hidden md:inline flex items-center">
                  Fatto con <Heart className="w-4 h-4 text-red-500 mx-1" /> in Italia
                </span>
              </div>
              
              {/* Social Links */}
              <div className="flex items-center space-x-4">
                {socialLinks.map((item) => {
                  const Icon = item.icon;
                  return (
                    <Link
                      key={item.name}
                      href={item.href}
                      className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                      aria-label={item.name}
                    >
                      <Icon className="w-5 h-5" />
                    </Link>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      </footer>
    );
  }
);

Footer.displayName = 'Footer';

export { Footer };
export type { FooterProps }; 
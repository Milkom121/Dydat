import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: 'class', // Enable class-based dark mode
  theme: {
    extend: {
      colors: {
        // Dydat Brand Colors - Integrazione con bolt_project
        'dydat-amber': '#F59E0B',
        'dydat-orange': '#F97316',
        primary: {
          50: '#FFFEF7',   // Giallo pastello ultra-light
          100: '#FFF9C4',  // Giallo pastello base
          200: '#FEF3C7',  // Giallo pastello più intenso
          300: '#FDE68A',  // Giallo dorato chiaro
          400: '#FBBF24',  // Giallo dorato
          500: '#F59E0B',  // Accent giallo-ambra (main)
          600: '#D97706',  // Giallo ambra scuro
          700: '#B45309',  // Giallo terra
          800: '#92400E',  // Giallo terra scuro
          900: '#78350F',  // Giallo terra molto scuro
        },
        // Stone colors from bolt_project
        stone: {
          25: '#FEFDFB',
          50: '#FAFAF9',
          100: '#F5F5F4',
          200: '#E7E5E4',
          300: '#D6D3D1',
          400: '#A8A29E',
          500: '#78716C',
          600: '#57534E',
          700: '#44403C',
          800: '#292524',
          900: '#1C1917',
          950: '#0C0A09',
        },
        // Educational Blue - Trust, Knowledge
        blue: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#0066CC', // Educational Blue
          600: '#004499', // Deep Learning Blue
          700: '#003875',
          800: '#002c5f',
          900: '#001f42',
        },
        // Success Green - Achievement
        success: {
          50: '#ecfdf5',
          100: '#d1fae5',
          200: '#a7f3d0',
          300: '#6ee7b7',
          400: '#34d399',
          500: '#10B981', // Success Green
          600: '#059669',
          700: '#047857',
          800: '#065f46',
          900: '#064e3b',
        },
        // Warning - Attention (allineato con primary per coerenza)
        warning: {
          50: '#FFFEF7',
          100: '#FFF9C4',
          200: '#FEF3C7',
          300: '#FDE68A',
          400: '#FBBF24',
          500: '#F59E0B', // Warning Amber
          600: '#D97706',
          700: '#B45309',
          800: '#92400E',
          900: '#78350F',
        },
        // Error Red - Alerts
        error: {
          50: '#fef2f2',
          100: '#fee2e2',
          200: '#fecaca',
          300: '#fca5a5',
          400: '#f87171',
          500: '#EF4444', // Error Red
          600: '#dc2626',
          700: '#b91c1c',
          800: '#991b1b',
          900: '#7f1d1d',
        },
        // Neutral grays with dark mode support
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
          950: '#0f0f0f', // Ultra dark for dark mode
        },
        // Dark mode specific colors
        dark: {
          bg: '#0f0f0f',        // Background nero profondo
          surface: '#1a1a1a',   // Surface grigio scuro
          card: '#262626',      // Card background
          border: '#404040',    // Border color
          text: '#f5f5f5',      // Text color
          muted: '#a3a3a3',     // Muted text
          yellow: '#1f1b00',    // Giallo scuro per dark mode
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Monaco', 'monospace'],
      },
      fontSize: {
        'xs': ['12px', '16px'],
        'sm': ['14px', '20px'],
        'base': ['16px', '24px'],
        'lg': ['18px', '28px'],
        'xl': ['20px', '28px'],
        '2xl': ['24px', '32px'],
        '3xl': ['30px', '36px'],
        '4xl': ['36px', '40px'],
        '5xl': ['48px', '1'],
        '6xl': ['60px', '1'],
      },
      spacing: {
        '18': '4.5rem',
        '72': '18rem',
        '84': '21rem',
        '88': '22rem',
        '96': '24rem',
      },
      borderRadius: {
        'xl': '0.75rem',
        '2xl': '1rem',
        '3xl': '1.5rem',
      },
      boxShadow: {
        'soft': '0 2px 8px 0 rgba(0, 0, 0, 0.08)',
        'medium': '0 4px 16px 0 rgba(0, 0, 0, 0.12)',
        'strong': '0 8px 32px 0 rgba(0, 0, 0, 0.16)',
        'glow': '0 0 20px rgba(245, 158, 11, 0.3)', // Giallo glow
        'glow-blue': '0 0 20px rgba(0, 102, 204, 0.3)', // Blue glow
        // Dark mode shadows
        'dark-soft': '0 2px 8px 0 rgba(0, 0, 0, 0.3)',
        'dark-medium': '0 4px 16px 0 rgba(0, 0, 0, 0.4)',
        'dark-strong': '0 8px 32px 0 rgba(0, 0, 0, 0.5)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-in': 'slideIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'slide-down': 'slideDown 0.3s ease-out',
        'bounce-subtle': 'bounceSubtle 0.6s ease-in-out',
        'pulse-slow': 'pulse 3s ease-in-out infinite',
        'glow': 'glow 2s ease-in-out infinite alternate',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideIn: {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(0)' },
        },
        slideUp: {
          '0%': { transform: 'translateY(16px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideDown: {
          '0%': { transform: 'translateY(-16px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceSubtle: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-4px)' },
        },
        glow: {
          '0%': { boxShadow: '0 0 20px rgba(245, 158, 11, 0.3)' },
          '100%': { boxShadow: '0 0 30px rgba(245, 158, 11, 0.6)' },
        },
      },
      backgroundImage: {
        'gradient-primary': 'linear-gradient(135deg, #FFF9C4 0%, #F59E0B 100%)',
        'gradient-educational': 'linear-gradient(135deg, #FFF9C4 0%, #0066CC 100%)',
        'gradient-success': 'linear-gradient(135deg, #FFF9C4 0%, #10B981 100%)',
        'gradient-dark': 'linear-gradient(135deg, #1f1b00 0%, #0f0f0f 100%)',
        'gradient-dydat': 'linear-gradient(135deg, #F59E0B 0%, #F97316 100%)',
      },
    },
  },
  plugins: [],
};
export default config; 
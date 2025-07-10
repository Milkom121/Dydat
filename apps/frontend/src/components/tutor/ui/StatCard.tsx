/**
 * StatCard Component - Specific for Tutor Interface
 * Displays key metrics with icons and visual indicators
 */

import * as React from "react";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";

export interface StatCardProps {
  title: string;
  value: string | number;
  icon: LucideIcon;
  trend?: {
    value: number;
    label: string;
    direction: 'up' | 'down' | 'neutral';
  };
  color?: 'blue' | 'green' | 'yellow' | 'purple' | 'red';
  loading?: boolean;
  className?: string;
}

const colorClasses = {
  blue: {
    iconBg: "bg-blue-100 dark:bg-blue-900/20",
    iconColor: "text-blue-600 dark:text-blue-400",
    trendUp: "text-blue-600 dark:text-blue-400",
  },
  green: {
    iconBg: "bg-green-100 dark:bg-green-900/20",
    iconColor: "text-green-600 dark:text-green-400",
    trendUp: "text-green-600 dark:text-green-400",
  },
  yellow: {
    iconBg: "bg-yellow-100 dark:bg-yellow-900/20",
    iconColor: "text-yellow-600 dark:text-yellow-400",
    trendUp: "text-yellow-600 dark:text-yellow-400",
  },
  purple: {
    iconBg: "bg-purple-100 dark:bg-purple-900/20",
    iconColor: "text-purple-600 dark:text-purple-400",
    trendUp: "text-purple-600 dark:text-purple-400",
  },
  red: {
    iconBg: "bg-red-100 dark:bg-red-900/20",
    iconColor: "text-red-600 dark:text-red-400",
    trendUp: "text-red-600 dark:text-red-400",
  },
};

export function StatCard({ 
  title, 
  value, 
  icon: Icon, 
  trend, 
  color = 'blue', 
  loading = false,
  className 
}: StatCardProps) {
  const colorConfig = colorClasses[color];

  if (loading) {
    return (
      <Card className={cn("p-6", className)}>
        <div className="animate-pulse">
          <div className="flex items-center justify-between">
            <div className="space-y-2">
              <div className="h-4 bg-stone-300 dark:bg-stone-600 rounded w-20"></div>
              <div className="h-8 bg-stone-300 dark:bg-stone-600 rounded w-16"></div>
            </div>
            <div className="w-12 h-12 bg-stone-300 dark:bg-stone-600 rounded-full"></div>
          </div>
          {trend && (
            <div className="mt-4 h-3 bg-stone-300 dark:bg-stone-600 rounded w-24"></div>
          )}
        </div>
      </Card>
    );
  }

  return (
    <Card className={cn("p-6 hover:shadow-lg transition-all duration-200", className)}>
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          <p className="text-sm font-medium text-stone-600 dark:text-stone-400">
            {title}
          </p>
          <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">
            {value}
          </p>
        </div>
        <div className={cn("p-3 rounded-full", colorConfig.iconBg)}>
          <Icon className={cn("h-6 w-6", colorConfig.iconColor)} />
        </div>
      </div>
      
      {trend && (
        <div className="mt-4 flex items-center text-sm">
          <span 
            className={cn(
              "font-medium",
              trend.direction === 'up' ? colorConfig.trendUp : 
              trend.direction === 'down' ? "text-red-600 dark:text-red-400" : 
              "text-stone-600 dark:text-stone-400"
            )}
          >
            {trend.direction === 'up' && '+'}
            {trend.direction === 'down' && '-'}
            {Math.abs(trend.value)}%
          </span>
          <span className="ml-1 text-stone-600 dark:text-stone-400">
            {trend.label}
          </span>
        </div>
      )}
    </Card>
  );
} 
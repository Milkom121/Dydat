/**
 * RequestCard Component - For displaying tutoring requests
 * Shows pending requests with accept/decline actions
 */

import * as React from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { MessageSquare, Clock, Calendar, User, BookOpen } from "lucide-react";

export interface RequestCardProps {
  id: string;
  studentName: string;
  subject: string;
  proposedDate: string;
  proposedTime: string;
  message?: string;
  hourlyRate?: number;
  duration?: number;
  studentAvatar?: string;
  studentLevel?: string;
  urgency?: 'low' | 'medium' | 'high';
  createdAt: string;
  actions?: {
    onAccept?: () => void;
    onDecline?: () => void;
    onViewProfile?: () => void;
    onMessage?: () => void;
  };
  className?: string;
}

const urgencyColors = {
  low: "border-l-green-500",
  medium: "border-l-yellow-500",
  high: "border-l-red-500",
};

const urgencyLabels = {
  low: "Bassa",
  medium: "Media",
  high: "Alta",
};

export function RequestCard({
  id,
  studentName,
  subject,
  proposedDate,
  proposedTime,
  message,
  hourlyRate,
  duration = 60,
  studentAvatar,
  studentLevel,
  urgency = 'medium',
  createdAt,
  actions,
  className,
}: RequestCardProps) {
  return (
    <Card className={cn(
      "p-4 border-l-4 transition-all duration-200 hover:shadow-md",
      urgencyColors[urgency],
      className
    )}>
      <div className="space-y-4">
        {/* Header */}
        <div className="flex items-start justify-between">
          <div className="flex items-start space-x-3 flex-1">
            {/* Student Avatar */}
            <div className="flex-shrink-0">
              {studentAvatar ? (
                <img
                  src={studentAvatar}
                  alt={studentName}
                  className="w-10 h-10 rounded-full object-cover"
                />
              ) : (
                <div className="w-10 h-10 rounded-full bg-stone-200 dark:bg-stone-700 flex items-center justify-center">
                  <User className="h-5 w-5 text-stone-500 dark:text-stone-400" />
                </div>
              )}
            </div>

            {/* Request Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center space-x-2 mb-1">
                <h3 className="font-medium text-stone-900 dark:text-stone-100">
                  {studentName}
                </h3>
                {studentLevel && (
                  <span className="px-2 py-1 text-xs bg-blue-100 text-blue-700 dark:bg-blue-900/20 dark:text-blue-400 rounded-full">
                    {studentLevel}
                  </span>
                )}
                <span className={cn(
                  "px-2 py-1 text-xs rounded-full",
                  urgency === 'high' ? "bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400" :
                  urgency === 'medium' ? "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/20 dark:text-yellow-400" :
                  "bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-400"
                )}>
                  Urgenza {urgencyLabels[urgency]}
                </span>
              </div>

              <div className="flex items-center space-x-4 text-sm text-stone-600 dark:text-stone-400 mb-2">
                <div className="flex items-center space-x-1">
                  <BookOpen className="h-4 w-4" />
                  <span className="font-medium">{subject}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Calendar className="h-4 w-4" />
                  <span>{proposedDate}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="h-4 w-4" />
                  <span>{proposedTime} ({duration}min)</span>
                </div>
              </div>

              {hourlyRate && (
                <div className="mb-2">
                  <span className="text-lg font-bold text-green-600 dark:text-green-400">
                    €{hourlyRate}/h
                  </span>
                </div>
              )}

              {message && (
                <div className="bg-stone-50 dark:bg-stone-800 p-3 rounded-lg">
                  <div className="flex items-start space-x-2">
                    <MessageSquare className="h-4 w-4 text-stone-500 dark:text-stone-400 mt-0.5 flex-shrink-0" />
                    <p className="text-sm text-stone-700 dark:text-stone-300 line-clamp-3">
                      {message}
                    </p>
                  </div>
                </div>
              )}

              <p className="text-xs text-stone-500 dark:text-stone-400 mt-2">
                Richiesta inviata {createdAt}
              </p>
            </div>
          </div>
        </div>

        {/* Actions */}
        {actions && (
          <div className="flex items-center justify-between pt-2 border-t border-stone-200 dark:border-stone-700">
            <div className="flex items-center space-x-2">
              {actions.onViewProfile && (
                <Button 
                  size="sm" 
                  variant="ghost" 
                  onClick={actions.onViewProfile}
                  className="text-xs"
                >
                  Vedi Profilo
                </Button>
              )}
              {actions.onMessage && (
                <Button 
                  size="sm" 
                  variant="ghost" 
                  onClick={actions.onMessage}
                  className="text-xs"
                >
                  Messaggio
                </Button>
              )}
            </div>

            <div className="flex items-center space-x-2">
              {actions.onDecline && (
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={actions.onDecline}
                  className="text-xs border-red-200 text-red-600 hover:bg-red-50 dark:border-red-800 dark:text-red-400 dark:hover:bg-red-900/20"
                >
                  Rifiuta
                </Button>
              )}
              {actions.onAccept && (
                <Button 
                  size="sm" 
                  variant="primary" 
                  onClick={actions.onAccept}
                  className="text-xs"
                >
                  Accetta
                </Button>
              )}
            </div>
          </div>
        )}
      </div>
    </Card>
  );
} 
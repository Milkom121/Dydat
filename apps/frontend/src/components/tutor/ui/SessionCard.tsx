/**
 * SessionCard Component - For displaying tutoring sessions
 * Supports different states and actions
 */

import * as React from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { Clock, MapPin, Video, User, Calendar } from "lucide-react";

export interface SessionCardProps {
  id: string;
  time: string;
  studentName: string;
  subject: string;
  type: 'online' | 'presence';
  status: 'scheduled' | 'in-progress' | 'completed' | 'cancelled';
  duration?: number;
  studentAvatar?: string;
  notes?: string;
  actions?: {
    onPrepare?: () => void;
    onStart?: () => void;
    onCancel?: () => void;
    onReschedule?: () => void;
  };
  className?: string;
}

const statusColors = {
  scheduled: "border-l-blue-500 bg-blue-50/50 dark:bg-blue-900/10",
  'in-progress': "border-l-green-500 bg-green-50/50 dark:bg-green-900/10",
  completed: "border-l-gray-500 bg-gray-50/50 dark:bg-gray-900/10",
  cancelled: "border-l-red-500 bg-red-50/50 dark:bg-red-900/10",
};

const statusLabels = {
  scheduled: "Programmata",
  'in-progress': "In Corso",
  completed: "Completata",
  cancelled: "Cancellata",
};

export function SessionCard({
  id,
  time,
  studentName,
  subject,
  type,
  status,
  duration = 60,
  studentAvatar,
  notes,
  actions,
  className,
}: SessionCardProps) {
  return (
    <Card className={cn(
      "p-4 border-l-4 transition-all duration-200 hover:shadow-md",
      statusColors[status],
      className
    )}>
      <div className="flex items-start justify-between">
        {/* Left side - Session info */}
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

          {/* Session Details */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center space-x-2 mb-1">
              <h3 className="font-medium text-stone-900 dark:text-stone-100 truncate">
                {studentName}
              </h3>
              <span className={cn(
                "px-2 py-1 text-xs rounded-full",
                status === 'scheduled' ? "bg-blue-100 text-blue-700 dark:bg-blue-900/20 dark:text-blue-400" :
                status === 'in-progress' ? "bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-400" :
                status === 'completed' ? "bg-gray-100 text-gray-700 dark:bg-gray-900/20 dark:text-gray-400" :
                "bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400"
              )}>
                {statusLabels[status]}
              </span>
            </div>

            <div className="space-y-1">
              <div className="flex items-center space-x-4 text-sm text-stone-600 dark:text-stone-400">
                <div className="flex items-center space-x-1">
                  <Clock className="h-4 w-4" />
                  <span>{time}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Calendar className="h-4 w-4" />
                  <span>{duration} min</span>
                </div>
                <div className="flex items-center space-x-1">
                  {type === 'online' ? (
                    <>
                      <Video className="h-4 w-4" />
                      <span>Online</span>
                    </>
                  ) : (
                    <>
                      <MapPin className="h-4 w-4" />
                      <span>Presenza</span>
                    </>
                  )}
                </div>
              </div>

              <p className="text-sm font-medium text-stone-800 dark:text-stone-200">
                {subject}
              </p>

              {notes && (
                <p className="text-sm text-stone-600 dark:text-stone-400 line-clamp-2">
                  {notes}
                </p>
              )}
            </div>
          </div>
        </div>

        {/* Right side - Actions */}
        {actions && status === 'scheduled' && (
          <div className="flex flex-col space-y-2 ml-4">
            {actions.onPrepare && (
              <Button 
                size="sm" 
                variant="outline" 
                onClick={actions.onPrepare}
                className="text-xs"
              >
                Prepara
              </Button>
            )}
            {actions.onStart && (
              <Button 
                size="sm" 
                variant="primary" 
                onClick={actions.onStart}
                className="text-xs"
              >
                Avvia
              </Button>
            )}
          </div>
        )}

        {actions && status === 'in-progress' && (
          <div className="ml-4">
            <Button 
              size="sm" 
              variant="success" 
              className="text-xs"
            >
              In Corso...
            </Button>
          </div>
        )}
      </div>
    </Card>
  );
} 
/**
 * API Client Configuration for Dydat Frontend
 * Axios-based client with authentication and error handling
 */

import axios, { AxiosInstance, AxiosResponse, AxiosError } from 'axios';
import { 
  API_BASE_URL, 
  HTTP_STATUS, 
  API_TIMEOUTS, 
  STORAGE_KEYS,
  API_ERROR_MESSAGES 
} from '@/constants/api';
import type { ApiResponse, ApiErrorResponse } from '@/types/auth';

// Create axios instance with base configuration
const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUTS.DEFAULT,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor - add auth token to requests
apiClient.interceptors.request.use(
  (config) => {
    // Add auth token if available
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }

    // Log request in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`🚀 API Request: ${config.method?.toUpperCase()} ${config.url}`, {
        headers: config.headers,
        data: config.data,
      });
    }

    return config;
  },
  (error) => {
    console.error('❌ Request Error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor - handle responses and errors
apiClient.interceptors.response.use(
  (response: AxiosResponse) => {
    // Log successful response in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`✅ API Response: ${response.status} ${response.config.url}`, response.data);
    }
    return response;
  },
  async (error: AxiosError<ApiErrorResponse>) => {
    const originalRequest = error.config;

    // Log error in development
    if (process.env.NODE_ENV === 'development') {
      console.error(`❌ API Error: ${error.response?.status} ${originalRequest?.url}`, {
        status: error.response?.status,
        data: error.response?.data,
        message: error.message,
      });
    }

    // Handle specific error cases
    if (error.response?.status === HTTP_STATUS.UNAUTHORIZED) {
      // Token expired or invalid - clear auth and redirect to login
      if (typeof window !== 'undefined') {
        localStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN);
        localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
        localStorage.removeItem(STORAGE_KEYS.USER_DATA);
        
        // Redirect to login if not already there
        if (window.location.pathname !== '/auth/login') {
          window.location.href = '/auth/login?expired=true';
        }
      }
    }

    // Transform error to consistent format
    const apiError: ApiErrorResponse = {
      statusCode: error.response?.status || 500,
      message: error.response?.data?.message || getErrorMessage(error),
      error: error.response?.data?.error || 'Unknown Error',
      timestamp: new Date().toISOString(),
      path: originalRequest?.url || '',
    };

    return Promise.reject(apiError);
  }
);

// Helper function to get user-friendly error messages
function getErrorMessage(error: AxiosError): string {
  if (error.code === 'ECONNABORTED') {
    return API_ERROR_MESSAGES.TIMEOUT_ERROR;
  }
  
  if (error.code === 'ERR_NETWORK') {
    return API_ERROR_MESSAGES.NETWORK_ERROR;
  }

  const status = error.response?.status;
  switch (status) {
    case HTTP_STATUS.BAD_REQUEST:
      return API_ERROR_MESSAGES.VALIDATION_ERROR;
    case HTTP_STATUS.UNAUTHORIZED:
      return API_ERROR_MESSAGES.UNAUTHORIZED;
    case HTTP_STATUS.FORBIDDEN:
      return API_ERROR_MESSAGES.FORBIDDEN;
    case HTTP_STATUS.NOT_FOUND:
      return API_ERROR_MESSAGES.NOT_FOUND;
    case HTTP_STATUS.CONFLICT:
      return API_ERROR_MESSAGES.CONFLICT;
    case HTTP_STATUS.TOO_MANY_REQUESTS:
      return API_ERROR_MESSAGES.RATE_LIMIT;
    case HTTP_STATUS.INTERNAL_SERVER_ERROR:
      return API_ERROR_MESSAGES.SERVER_ERROR;
    default:
      return API_ERROR_MESSAGES.UNKNOWN_ERROR;
  }
}

// Generic API methods
export const api = {
  // GET request
  get: async <T>(url: string, config?: any): Promise<T> => {
    const response = await apiClient.get<T>(url, config);
    return response.data;
  },

  // POST request
  post: async <T>(url: string, data?: any, config?: any): Promise<T> => {
    const response = await apiClient.post<T>(url, data, config);
    return response.data;
  },

  // PUT request
  put: async <T>(url: string, data?: any, config?: any): Promise<T> => {
    const response = await apiClient.put<T>(url, data, config);
    return response.data;
  },

  // PATCH request
  patch: async <T>(url: string, data?: any, config?: any): Promise<T> => {
    const response = await apiClient.patch<T>(url, data, config);
    return response.data;
  },

  // DELETE request
  delete: async <T>(url: string, config?: any): Promise<T> => {
    const response = await apiClient.delete<T>(url, config);
    return response.data;
  },
};

// Upload helper with progress tracking
export const uploadFile = async (
  url: string,
  file: File,
  onProgress?: (progress: number) => void
): Promise<any> => {
  const formData = new FormData();
  formData.append('file', file);

  return apiClient.post(url, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: API_TIMEOUTS.UPLOAD,
    onUploadProgress: (progressEvent) => {
      if (onProgress && progressEvent.total) {
        const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
        onProgress(progress);
      }
    },
  });
};

// Health check utility
export const healthCheck = async (): Promise<boolean> => {
  try {
    await api.get('/health');
    return true;
  } catch {
    return false;
  }
};

// Export the configured axios instance for direct use if needed
export { apiClient };
export default api; 
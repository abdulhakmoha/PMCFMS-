import axios from 'axios';

const api = axios.create({
  baseURL: `${import.meta.env.VITE_API_URL || 'http://localhost:5001'}/api`,
});

// Attach JWT token to every request
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Handle errors - DO NOT do window.location.reload or window.location.href
// Let React Router handle navigation to avoid full page reloads
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Just log the warning - DashboardLayout will handle redirect via React Router
      console.warn('401: Token may be expired or invalid.');
    }
    return Promise.reject(error);
  }
);

export default api;

import { createContext, useState, useEffect } from 'react';
import api from '../services/api';

// Create Context
export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem('token') || null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in
    const storedUser = localStorage.getItem('user');
    if (storedUser && token) {
      setUser(JSON.parse(storedUser));
    }
    setLoading(false);
  }, [token]);

  useEffect(() => {
    // Intercept 401 errors to logout user cleanly
    // but SKIP during login/register calls to avoid premature logout
    const interceptor = api.interceptors.response.use(
      (response) => response,
      (error) => {
        const url = error.config?.url || '';
        const isAuthRoute = url.includes('/auth/login') || url.includes('/auth/register');
        if (error.response && error.response.status === 401 && !isAuthRoute) {
          logout();
        }
        return Promise.reject(error);
      }
    );
    return () => {
      api.interceptors.response.eject(interceptor);
    };
  }, []);

  // Register User
  const registerUser = async (userData) => {
    try {
      const response = await api.post('/auth/register', userData);
      const { token: newToken, ...userInfo } = response.data;
      
      localStorage.setItem('token', newToken);
      localStorage.setItem('user', JSON.stringify(userInfo));
      
      setToken(newToken);
      setUser(userInfo);
      return { success: true };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.message || 'Registration failed. Please try again.' 
      };
    }
  };

  // Login User
  const loginUser = async (email, password) => {
    try {
      const response = await api.post('/auth/login', { email, password });
      const { token: newToken, ...userInfo } = response.data;
      
      localStorage.setItem('token', newToken);
      localStorage.setItem('user', JSON.stringify(userInfo));
      
      setToken(newToken);
      setUser(userInfo);
      return { success: true };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.message || 'Login failed. Please check your credentials.' 
      };
    }
  };

  // Logout User
  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setToken(null);
    setUser(null);
  };

  // Update User state
  const updateUser = (updatedUserInfo) => {
    setUser(updatedUserInfo);
    localStorage.setItem('user', JSON.stringify(updatedUserInfo));
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, registerUser, loginUser, logout, updateUser }}>
      {!loading && children}
    </AuthContext.Provider>
  );
};

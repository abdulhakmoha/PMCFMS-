import React, { createContext, useState, useContext, useEffect } from 'react';

const LanguageContext = createContext();

export const translations = {
  en: {
    dashboard: 'Dashboard',
    meetings: 'Meetings',
    forums: 'Forums',
    users: 'Users',
    settings: 'Settings',
    logout: 'Logout',
    welcome: 'Welcome back!',
    overview: 'Dashboard Overview',
    start_discussion: 'Start Discussion',
    schedule_meeting: 'Schedule Meeting',
    search: 'Search...',
    all_districts: 'All Districts',
    all_categories: 'All Categories',
    pending: 'Pending',
    approved: 'Approved',
    details: 'Details',
    responses: 'Responses',
    post: 'Post',
    save: 'Save Changes',
    update_profile: 'Update Profile',
    change_password: 'Change Password'
  },
  so: {
    dashboard: 'Kumbuyuutarka',
    meetings: 'Kulamada',
    forums: 'Doodaha',
    users: 'Isticmaalayaasha',
    settings: 'Settings',
    logout: 'Ka bax',
    welcome: 'Ku soo dhawaada!',
    overview: 'Guud ahaan nidaamka',
    start_discussion: 'Bilow Dood',
    schedule_meeting: 'Qorshee Kulan',
    search: 'Raadi...',
    all_districts: 'Dhammaan Degmooyinka',
    all_categories: 'Dhammaan Qaybaha',
    pending: 'Sugaya',
    approved: 'La ogolaaday',
    details: 'Faahfaahin',
    responses: 'Jawaabaha',
    post: 'Dir',
    save: 'Keydi Isbedelka',
    update_profile: 'Cusboonaysii Profile-ka',
    change_password: 'Bedel Password-ka'
  }
};

export const LanguageProvider = ({ children }) => {
  const [lang, setLang] = useState(localStorage.getItem('lang') || 'so');

  useEffect(() => {
    localStorage.setItem('lang', lang);
  }, [lang]);

  const t = (key) => {
    return translations[lang][key] || key;
  };

  const toggleLanguage = () => {
    setLang(prev => prev === 'en' ? 'so' : 'en');
  };

  return (
    <LanguageContext.Provider value={{ lang, t, toggleLanguage }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => useContext(LanguageContext);

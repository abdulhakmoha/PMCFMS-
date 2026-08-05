// Central helper for building media/image URLs pointing to the backend.
// Uses the VITE_API_URL env variable so mobile devices can reach the server.
const BASE = import.meta.env.VITE_API_URL || 'http://localhost:5001';
export const mediaUrl = (path) => (path ? `${BASE}${path}` : '');

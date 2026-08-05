export const keepAlive = () => {
  setInterval(() => {
    fetch('http://192.168.18.203:5001/api/dashboard/stats')
      .then(res => res.json())
      .catch(err => console.error('KeepAlive Error:', err));
  }, 1000 * 60 * 5); // ping every 5 minutes
};

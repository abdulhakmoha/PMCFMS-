/**
 * Somali SMS Gateway Utility
 * This utility is designed to work with local providers like Hormuud, Somnet, etc.
 */
const axios = require('axios');

const sendSMS = async (phoneNumber, message) => {
  // Check if Somali SMS API credentials exist in .env
  const apiURL = process.env.SOMALI_SMS_URL;
  const username = process.env.SOMALI_SMS_USER;
  const password = process.env.SOMALI_SMS_PASS;

  if (!apiURL || !username) {
    console.log('--- MOCK SOMALI SMS SENT ---');
    console.log(`To: ${phoneNumber}`);
    console.log(`Message: ${message}`);
    console.log('----------------------------');
    return { success: true, message: 'Mock SMS logged to console' };
  }

  try {
    // Most Somali SMS providers use a simple GET or POST request
    // Format: http://api-url.com/send?user=xxx&pass=xxx&to=252xxxx&text=hello
    const response = await axios.get(apiURL, {
      params: {
        user: username,
        pass: password,
        to: phoneNumber,
        text: message,
        // Some providers might need extra params like 'sender'
        sender: process.env.FROM_NAME || 'PMCFMS'
      }
    });

    console.log('SMS Provider Response:', response.data);
    return { success: true, data: response.data };
  } catch (error) {
    console.error('Somali SMS Error:', error.message);
    return { success: false, error: error.message };
  }
};

module.exports = sendSMS;

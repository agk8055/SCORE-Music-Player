const express = require('express');
const axios = require('axios');
const router = express.Router();

// Base URL for the official JioSaavnAPI
const JIOSAAVN_API_BASE = 'https://jiosaavnapi-bok7.onrender.com/';

// Helper function to make API request with retries
async function makeRequestWithRetry(url, maxRetries = 5, initialTimeout = 60000) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      console.log(`Attempt ${i + 1} of ${maxRetries} with timeout ${initialTimeout * (i + 1)}ms`);
      const response = await axios.get(url, {
        timeout: initialTimeout * (i + 1), // Increase timeout with each retry
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
      });
      return response;
    } catch (error) {
      lastError = error;
      console.log(`Attempt ${i + 1} failed:`, error.message);
      
      // If it's not a timeout error, don't retry
      if (error.code !== 'ECONNABORTED') {
        throw error;
      }
      
      // Longer delay for cold start (up to 30 seconds)
      const delay = Math.min(30000, 5000 * Math.pow(2, i));
      console.log(`Waiting ${delay}ms before retry...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  
  throw lastError;
}

// GET /api/search?query={search_term}
router.get('/', async (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: 'Missing search query parameter' });
  }

  const searchUrl = `${JIOSAAVN_API_BASE}/result/?query=${encodeURIComponent(query)}`;

  try {
    console.log('Starting search request...');
    const response = await makeRequestWithRetry(searchUrl);
    console.log('Search request successful');
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching from JioSaavn API:', error);
    
    if (error.code === 'ECONNABORTED') {
      res.status(504).json({ 
        error: 'The server is waking up from inactivity. Please try again in a few moments.',
        details: 'This is normal behavior for the first request after 15 minutes of inactivity.'
      });
    } else {
      res.status(500).json({ 
        error: 'Failed to fetch data from JioSaavn API',
        details: error.message 
      });
    }
  }
});

// GET /api/song?query={song_url_or_id}
router.get('/song', async (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: 'Missing song query parameter' });
  }

  const songUrl = `${JIOSAAVN_API_BASE}/song/?query=${encodeURIComponent(query)}&lyrics=true`;

  try {
    console.log('Starting song request...');
    const response = await makeRequestWithRetry(songUrl);
    console.log('Song request successful');
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching song from JioSaavn API:', error);
    
    if (error.code === 'ECONNABORTED') {
      res.status(504).json({ 
        error: 'The server is waking up from inactivity. Please try again in a few moments.',
        details: 'This is normal behavior for the first request after 15 minutes of inactivity.'
      });
    } else {
      res.status(500).json({ 
        error: 'Failed to fetch song data from JioSaavn API',
        details: error.message 
      });
    }
  }
});

// GET /api/playlist?query={playlist_url}
router.get('/playlist', async (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: 'Missing playlist query parameter' });
  }

  const playlistUrl = `${JIOSAAVN_API_BASE}/playlist/?query=${encodeURIComponent(query)}&lyrics=true`;

  try {
    const response = await axios.get(playlistUrl, {
      timeout: 10000
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error fetching playlist from JioSaavn API:', error);
    res.status(500).json({ error: 'Failed to fetch playlist data from JioSaavn API' });
  }
});

// GET /api/album?query={album_url}
router.get('/album', async (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: 'Missing album query parameter' });
  }

  const albumUrl = `${JIOSAAVN_API_BASE}/album/?query=${encodeURIComponent(query)}&lyrics=true`;

  try {
    const response = await axios.get(albumUrl, {
      timeout: 10000
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error fetching album from JioSaavn API:', error);
    res.status(500).json({ error: 'Failed to fetch album data from JioSaavn API' });
  }
});

// GET /api/lyrics?query={song_url_or_id}
router.get('/lyrics', async (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: 'Missing lyrics query parameter' });
  }

  const lyricsUrl = `${JIOSAAVN_API_BASE}/lyrics/?query=${encodeURIComponent(query)}`;

  try {
    const response = await axios.get(lyricsUrl, {
      timeout: 10000
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error fetching lyrics from JioSaavn API:', error);
    res.status(500).json({ error: 'Failed to fetch lyrics from JioSaavn API' });
  }
});

module.exports = router; // Export the router
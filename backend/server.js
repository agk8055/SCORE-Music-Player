const express = require('express');
const cors = require('cors');
const compression = require('compression');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cron = require('node-cron');
const axios = require('axios');
const searchRoutes = require('./routes/search'); // Import the search router

const app = express();
const PORT = process.env.PORT || 5000; // Use environment variable or default to 5000

// --- Middleware ---

// Security headers
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Allow CORS from anywhere
app.use(cors());

// Compression
app.use(compression());

// Body Parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// --- Routes ---

// Root route (optional: for testing if server is running)
app.get('/', (req, res) => {
  res.send('Score Backend API is running!');
});

// Mount the search API routes
// All routes defined in './routes/search.js' will be prefixed with /api/search
app.use('/api/search', searchRoutes);

// --- Basic Error Handling (Optional but Recommended) ---
// Catch 404 for routes not found
app.use((req, res, next) => {
  res.status(404).send("Sorry, can't find that!");
});

// Generic error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// --- Cold Start Prevention ---
const preventColdStart = async () => {
  try {
    console.log('Making request to prevent cold start...');
    const response = await axios.get('https://jiosaavnapi-bok7.onrender.com/');
    console.log('Cold start prevention successful:', response.status);
  } catch (error) {
    console.error('Cold start prevention failed:', error.message);
  }
};

// Schedule the cold start prevention task to run every 10 minutes
cron.schedule('*/10 * * * *', preventColdStart);

// Run immediately on startup
preventColdStart();

// --- Start Server ---
app.listen(PORT, () => {
  console.log(`Backend server listening on http://localhost:${PORT}`);
});
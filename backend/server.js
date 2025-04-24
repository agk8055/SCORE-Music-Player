const express = require('express');
const cors = require('cors');
const searchRoutes = require('./routes/search'); // Import the search router

const app = express();
const PORT = process.env.PORT || 5000; // Use environment variable or default to 5000

// --- Middleware ---

// 1. Enable CORS for all origins (adjust for production if needed)
app.use(cors());

// 2. Body Parser (for JSON requests, though not strictly needed for this GET endpoint)
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // For URL-encoded data

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

// --- Start Server ---
app.listen(PORT, () => {
  console.log(`Backend server listening on http://localhost:${PORT}`);
});
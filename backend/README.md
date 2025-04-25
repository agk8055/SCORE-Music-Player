# Score Backend API

Backend API for the Score music application, providing integration with JioSaavn API.

## Features

- Search for songs, albums, and playlists
- Get song details and lyrics
- Rate limiting and security features
- Production-ready configuration

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Copy `.env.example` to `.env` and configure your environment variables:
   ```bash
   cp .env.example .env
   ```

## Development

Run the development server:
```bash
npm run dev
```

## Production

Run the production server:
```bash
npm start
```

## Environment Variables

- `PORT`: Server port (default: 5000)
- `JIOSAAVN_API_BASE`: Base URL for JioSaavn API
- `RATE_LIMIT_WINDOW_MS`: Rate limiting window in milliseconds
- `RATE_LIMIT_MAX_REQUESTS`: Maximum requests per window

## Deployment to Render

1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Configure the following settings:
   - Build Command: `npm install`
   - Start Command: `npm start`
4. Add environment variables from your `.env` file
5. Deploy!

## API Endpoints

- `GET /api/search?query={search_term}` - Search for songs
- `GET /api/song?query={song_url_or_id}` - Get song details
- `GET /api/playlist?query={playlist_url}` - Get playlist details
- `GET /api/album?query={album_url}` - Get album details
- `GET /api/lyrics?query={song_url_or_id}` - Get song lyrics
- `GET /health` - Health check endpoint

## Security Features

- Rate limiting
- CORS protection
- Security headers (Helmet)
- Request size limits
- Response compression 
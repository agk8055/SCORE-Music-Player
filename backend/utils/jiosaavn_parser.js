/**
 * Parses the raw search results from the unofficial JioSaavn API.
 *
 * Updated based on observed API response structure around May 2024.
 * Note: The structure of the unofficial API can change without notice.
 *
 * @param {object} apiResponse The raw JSON response from the JioSaavn API.
 * @returns {Array<object>} An array of simplified song objects.
 */
function parseJioSaavnSearch(apiResponse) {
  const simplifiedSongs = [];

  // --- Updated Path ---
  // Based on the __call=search.getResults endpoint, results are often directly under 'results'
  const results = apiResponse?.results; // Changed from apiResponse?.search?.data?.results

  if (!results || !Array.isArray(results)) {
    console.warn('JioSaavn API structure might have changed. No results array found at expected path (`apiResponse.results`).');
    console.warn('Received data structure:', JSON.stringify(apiResponse, null, 2)); // Log structure if results not found
    return []; // Return empty array if structure is not as expected
  }
  // --- End of Update ---

  results.forEach(item => {
    // We are primarily interested in 'song' type results
    // Check for necessary fields directly on the item or within more_info
    if (item.type === 'song' && item.more_info) {
      try {
        // Extract data, providing defaults for safety
        const name = item.title || 'Unknown Title';

        // --- Updated Artist Extraction ---
        let artist = 'Unknown Artist';
        if (item.more_info?.artistMap?.primary_artists?.length > 0) {
          artist = item.more_info.artistMap.primary_artists[0].name || artist;
        }
        // --- End of Update ---

        const album = item.more_info?.album || 'Unknown Album';

        // Image URL often has placeholders for size, replace with a better resolution
        let image = item.image || '';
        if (image && typeof image === 'string') { // Ensure image is a string before replacing
          image = image.replace(/150x150/g, '500x500').replace(/50x50/g, '500x500'); // Handle 50x50 too
        } else {
          image = ''; // Ensure empty string if not valid
        }

        // --- Updated Song URL Extraction ---
        // Prioritize encrypted_media_url as observed in the new structure
        const songUrl = item.more_info?.encrypted_media_url || '';
        // Note: This URL might be base64 encoded or require other processing in some cases,
        // but often works directly or is the only option from the unofficial API.
        // --- End of Update ---

        // Only add if we have a song URL (and maybe a title)
        if (songUrl && name !== 'Unknown Title') {
          simplifiedSongs.push({
            name: decodeHtmlEntities(name), // Decode potential HTML entities
            artist: decodeHtmlEntities(artist),
            album: decodeHtmlEntities(album),
            image: image,
            songUrl: songUrl, // Needs verification if it's directly playable
          });
        } else if (!songUrl) {
            // console.log(`Skipping song "${name}" due to missing songUrl.`);
        }
      } catch (parseError) {
        console.error('Error parsing individual song item:', parseError, 'Item:', item);
        // Optionally skip this item or add with partial data
      }
    }
  });

  return simplifiedSongs;
}

/**
 * Decodes HTML entities (like &, ") from a string.
 * @param {string} text The text to decode.
 * @returns {string} The decoded text.
 */
function decodeHtmlEntities(text) {
  if (typeof text !== 'string') return text;
  // Basic decoding for common entities
  return text
    .replace(/&/g, '&')
    .replace(/</g, '<')
    .replace(/>/g, '>')
    .replace(/"/g, '"')
    .replace(/'/g, "'");
    // Add more replacements if needed
}


module.exports = { parseJioSaavnSearch };
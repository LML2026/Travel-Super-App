require('dotenv').config();

const https = require('https');
const dns = require('node:dns');

// Set IPv4 first BEFORE making any requests
dns.setDefaultResultOrder('ipv4first');

// Disable certificate verification temporarily for testing
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

async function testWeather() {
  try {
    console.log('🌍 Testing Open-Meteo Geocoding API...');
    console.log('🔧 IPv4 first enabled, cert verification disabled');
    
    const geocodeOptions = {
      hostname: 'geocoding-api.open-meteo.com',
      port: 443,
      path: `/v1/search?name=London&count=1&language=en&format=json`,
      method: 'GET',
      headers: { 
        'Accept': 'application/json',
        'User-Agent': 'Node.js Test',
      },
    };

    const geocodeResult = await new Promise((resolve, reject) => {
      const req = https.request(geocodeOptions, (r) => {
        console.log('✅ Connected! Status:', r.statusCode);
        let d = '';
        r.on('data', (c) => d += c);
        r.on('end', () => {
          try {
            resolve(JSON.parse(d));
          } catch (e) {
            reject(new Error('JSON parse error: ' + e.message));
          }
        });
      });
      
      req.on('error', (err) => {
        console.error('❌ Request error:', err.code);
        console.error('   Message:', err.message);
        reject(err);
      });
      
      req.setTimeout(10000, () => {
        req.destroy();
        reject(new Error('Request timeout'));
      });
      
      req.end();
    });

    console.log('✅ Geocoding successful');
    const loc = geocodeResult.results?.[0];
    if (loc) {
      console.log(`📍 Found: ${loc.name} at ${loc.latitude}, ${loc.longitude}`);
      console.log('\n✅ TEST PASSED - API is reachable!');
    }
  } catch (error) {
    console.error('\n❌ TEST FAILED');
    console.error('Error:', error.message);
  }
}

testWeather();

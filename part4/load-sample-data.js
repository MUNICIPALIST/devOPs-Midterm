#!/usr/bin/env node

/**
 * Script to load sample user data into PostgreSQL database
 * Usage: node load-sample-data.js
 */

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// Database configuration (same as in config.yml)
const pool = new Pool({
  host: '167.71.42.212',
  user: 'postgres',
  database: 'devops_lab',
  password: '1234',
  port: 5432,
});

async function loadSampleData() {
  try {
    console.log('Loading sample user data...');

    // Read sample data
    const sampleDataPath = path.join(__dirname, 'sample-users.json');
    const sampleData = JSON.parse(fs.readFileSync(sampleDataPath, 'utf8'));

    console.log(`Found ${sampleData.length} users to insert`);

    // Clear existing data (optional)
    console.log('Clearing existing data...');
    await pool.query('DELETE FROM users');

    // Insert sample data
    for (const user of sampleData) {
      const query = `
        INSERT INTO users (id, name, email)
        VALUES ($1, $2, $3)
        ON CONFLICT (id) DO UPDATE SET
          name = EXCLUDED.name,
          email = EXCLUDED.email
      `;

      await pool.query(query, [user.id, user.name, user.email]);
      console.log(`✓ Inserted user: ${user.name}`);
    }

    console.log('✅ Sample data loaded successfully!');

    // Verify data
    const result = await pool.query('SELECT COUNT(*) as count FROM users');
    console.log(`📊 Total users in database: ${result.rows[0].count}`);

  } catch (error) {
    console.error('❌ Error loading sample data:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the script
if (require.main === module) {
  loadSampleData();
}

module.exports = { loadSampleData };

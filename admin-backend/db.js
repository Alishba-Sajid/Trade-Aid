const { Pool } = require('pg');

// Create a connection pool
const pool = new Pool({
  user: 'postgres',        // your PostgreSQL username
  host: 'localhost',       // usually localhost
  database: 'community_app', // your database name
  password: '1234',  // your PostgreSQL password
  port: 5432,               // default PostgreSQL port
});

// Test connection
pool.connect()
  .then(() => console.log('✅ PostgreSQL connected successfully'))
  .catch(err => console.error('❌ Database connection error:', err));

module.exports = pool;

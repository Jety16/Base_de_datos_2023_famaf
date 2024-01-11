const express = require('express');
const app = express();
const db = require('./db');
const models = require('./models');

app.use(express.json());

// Connect to MongoDB
db.connect();

// Define your routes here
app.get('/', (req, res) => {
    res.send('Hello World!');
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server is running on port ${port}`));

module.exports = app;
const mongoose = require('mongoose');

async function connectDB() {
    try {
        await mongoose.connect('mongodb://localhost:27017/myDatabase', {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });
        console.log('Connected to the MongoDB database.');
    } catch (error) {
        console.error('Error connecting to the database: ', error);
    }
}

module.exports = connectDB;
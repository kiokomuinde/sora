/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

setGlobalOptions({maxInstances: 10});

// === START OF MPESA CALLBACK ENDPOINT ===

// Import the express module to handle HTTP requests
const express = require("express");
const app = express();

// Middleware to parse JSON request bodies
app.use(express.json());

// Define the endpoint that will receive M-Pesa callbacks
app.post("/callback", (req, res) => {
  const callbackData = req.body;
  logger.info("M-Pesa Callback Received:", {data: callbackData});

  // In a real application, you would process the callbackData here,
  // for example, to update the payment status in your Firestore database.

  // Respond to Safaricom to confirm receipt of the callback
  res.status(200).send({
    "ResultCode": 0,
    "ResultDesc": "C2B Recieved",
  });
});

// Expose the express app as a Firebase Cloud Function
exports.mpesaCallback = onRequest(app);

// === END OF MPESA CALLBACK ENDPOINT ===


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

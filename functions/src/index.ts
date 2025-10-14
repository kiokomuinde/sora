import { setGlobalOptions } from "firebase-functions";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

// Initialize the Firebase Admin SDK
// This is required to interact with Firestore, Auth, etc., on the server.
initializeApp();
const db = getFirestore();

// Set global options for function cost control (v2 API)
// This limits all functions to a maximum of 10 concurrent instances.
setGlobalOptions({ maxInstances: 10 });

// =========================================================================
// 1. FIREBASE AUTH & FIRESTORE TRIGGERS
//    - Inspired by the 'addProperty' logic in firestore_service.dart
// =========================================================================

/**
 * Triggered when a new document is written to the 'properties' collection.
 * Use Case: Server-side validation, enrichment, or setting an initial status.
 */
export const onNewPropertyAdded = onDocumentCreated(
  "properties/{propertyId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.error("No data associated with the new property event.");
      return;
    }

    const propertyData = snapshot.data();
    const propertyId = event.params.propertyId;

    logger.info(`New property added: ${propertyId}`, propertyData);

    // Example Server-Side Logic:
    // Ensure the initial status is 'PendingReview' if it's not already set.
    const isNewStatusRequired = (
      propertyData.status !== "Approved" && propertyData.status !== "PendingReview"
    );

    if (isNewStatusRequired) {
      logger.info(`Setting status for property ${propertyId} to "PendingReview".`);

      // Update the document to reflect the server-enforced status
      await db.collection("properties").doc(propertyId).update({
        status: "PendingReview",
        updatedByFunction: true,
      });
    }
  }
);


// =========================================================================
// 2. CALLABLE FUNCTIONS (HTTPS)
//    - Inspired by 'addContactMessage' in firestore_service.dart
// =========================================================================

/**
 * A Callable Function to handle contact form submissions securely.
 * This is the recommended way for your Flutter client to call a custom backend API.
 */
export const submitContactMessage = onCall(async (request) => {
  const { name, email, message } = request.data;

  // 1. Input Validation - essential security step on the server
  if (!name || !email || !message) {
    logger.warn("Contact message submission failed: Missing required fields.", request.data);
    throw new HttpsError("invalid-argument", "Missing required fields: name, email, and message are required.");
  }

  // Basic email format validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    logger.warn("Contact message submission failed: Invalid email format.", { email: email });
    throw new HttpsError("invalid-argument", "Invalid email format.");
  }

  try {
    // 2. Write data to Firestore (mimics the Dart code but is run securely on the server)
    await db.collection("contactMessages").add({
      name: name,
      email: email,
      message: message,
      timestamp: FieldValue.serverTimestamp(),
      ipAddress: request.rawRequest.ip || null,
    });

    logger.info("Successfully recorded contact message.", { email: email });

    return { success: true, message: "Your message has been received." };

  } catch (error) {
    logger.error("Failed to process contact message.", error);
    throw new HttpsError("internal", "An internal server error occurred while processing your request.");
  }
});
// app/javascript/channels/index.js
import { createConsumer } from "@rails/actioncable"
// Create and export the consumer directly in this file
const consumer = createConsumer()
export default consumer

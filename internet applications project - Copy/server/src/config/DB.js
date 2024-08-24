import mongoose from "mongoose";
const connectDB = async () => {
  try {
    const connectionString = process.env.MONGO_URL;
    await mongoose.connect(connectionString);
    console.log("MongoDB connected...");
  } catch (e) {
    console.error("Error connecting to MongoDB:", e.message);
    process.exit(1);
  }
};
export default connectDB;
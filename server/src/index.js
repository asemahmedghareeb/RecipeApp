import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import connectDB from "./config/DB.js";
import { ERROR, FAILED } from "./utils/httpStatus.js";
import { userRouter } from "./routes/users.js";
import { recipesRouter } from "./routes/recipes.js";
//i did this because in es6 modules i can not use __filename and __dirname
import { fileURLToPath } from "url";
import fs from "fs";

const app = express();
dotenv.config();
app.use(express.json());
app.use(cors());
import { dirname } from "node:path";
import path from "node:path";
import { asyncWrapper } from "./middlewares/asyncWrapper.js";
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const uploadsDir = path.join(__dirname, "/uploads");
app.use("/uploads", express.static(path.join(__dirname, "/uploads")));
app.use("/auth", userRouter);
app.use("/recipes", recipesRouter);

app.get("/images/:imageName", asyncWrapper(async(req, res,next) => {
  const imageName = req.params.imageName;
  if(imageName==="placeholder"){
    return res.status(404).send("Image not found");
  }
  const imagePath = path.join(uploadsDir, imageName);
  fs.readFile(imagePath, (err, data) => {
    if (err) {
      console.error("Error reading image:", err);
      return res.status(404).send("Image not found");
    }
    const contentType = getImageContentType(imageName); // Function to determine content type
    res.contentType(contentType);
    res.send(data);
  });
}));

function getImageContentType(imageName) {
  // Implement logic to determine content type based on image extension
  // For example:
  const ext = path.extname(imageName).toLowerCase();
  const mimeTypes = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".gif": "image/gif",
    ".webp": "image/webp",
    // Add more extensions as needed
  };
  return mimeTypes[ext] || "image/octet-stream";
}
app.all("*", (req, res, next) => {
  res
    .status(404)
    .json({ status: ERROR, data: { message: "this resource is not found" } });
});

app.use((error, req, res, next) => {
  res.status(error.statusCode || 500).json({
    status: error.statusText || ERROR,
    message: error.message,
    code: error.statusCode || 500,
    data: null,
  });
});


connectDB().then(() => {
  app.listen(3000, () => console.log("Server is running on port 3000"));
});

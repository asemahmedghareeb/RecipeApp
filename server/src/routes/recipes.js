import express from "express";
import appError from "../utils/appError.js";
import verifyToken from "../middlewares/verifyToken.js";
import multer from "multer";
import {
  getAll,
  createRecipe,
  saveRecipe,
  getSavedRecipesIds,
  getSavedRecipes,
  updateRecipe,
  getRecipe,
  deleteRecipe,
  unSaveRecipe,
  // uploadRecipeImage
} from "../controllers/recipes.js";
const router = express.Router();

const diskStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "src/uploads");
  },
  filename: function (req, file, cb) {
    const extension = file.mimetype.split("/")[1];
    const fileName = `user-${Date.now()}.${extension}`;
    cb(null, fileName);
  },
});
const upload = multer({
  storage: diskStorage,
  dest: "uploads/",
  fileFilter: (req, file, cb) => {
    const imageType = file.mimetype.split("/")[0];
    console.log(imageType);
    if (imageType === "image") {
      return cb(null, true);
    } else {
      return cb(appError.createError("Only images are allowed", 400), false);
    }
  },
});

router
  .route("/")
  .get(getAll)
  .post(verifyToken, upload.single("recipeImage"), createRecipe)
  .put(verifyToken, saveRecipe);

// router.post("/uploadRecipeImage", upload.single("recipeImage"),uploadRecipeImage);
router.get("/savedRecipes/ids/:userId", verifyToken, getSavedRecipesIds);
router.patch("/:recipeId/:userId", verifyToken,upload.single("recipeImage"), updateRecipe);
router.get("/savedRecipes/:userId", verifyToken, getSavedRecipes);
router.get("/:recipeId", verifyToken, getRecipe);
router.delete("/:recipeId/:userId", verifyToken, deleteRecipe);
router.put("/:recipeId/:userId", verifyToken, unSaveRecipe);
export { router as recipesRouter };

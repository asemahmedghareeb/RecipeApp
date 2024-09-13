import { asyncWrapper } from "../middlewares/asyncWrapper.js";
import RecipeModel from "../models/recipe.js";
import UserModel from "../models/user.js";
import { SUCCESS, FAILED } from "../utils/httpStatus.js";
import appError from "../utils/appError.js";
import fs from "fs";

const saveRecipe = asyncWrapper(async (req, res, next) => {
  const { recipeId, userId } = req.body;
  const user = await UserModel.findById(userId);
  
  user.savedRecipes.push(recipeId);
  await user.save();
  res
    .status(200)
    .json({ status: SUCCESS, data: { savedRecipes: user.savedRecipes } });
});

const unSaveRecipe = async (req, res, next) => {
  const { recipeId, userId } = req.params;

  const user = await UserModel.findById(userId);
  const index = user.savedRecipes.indexOf(recipeId);
  if (index === -1) {
    return next(appError.createError("Recipe is not saved", 404, FAILED));
  }
  user.savedRecipes.splice(index, 1);
  await user.save();

  res
    .status(200)
    .json({ status: SUCCESS, data: { savedRecipes: user.savedRecipes } });
};

const getSavedRecipesIds = asyncWrapper(async (req, res, next) => {
  const userId = req.params.userId;
  const user = await UserModel.findById(userId);
  res
    .status(200)
    .json({ status: SUCCESS, data: { savedRecipeIds: user.savedRecipes } });
});

const getSavedRecipes = asyncWrapper(async (req, res, next) => {
  const userId = req.params.userId;
  const user = await UserModel.findById(userId);
  const savedRecipeIds = user.savedRecipes;
  const savedRecipes = await RecipeModel.find({ _id: { $in: savedRecipeIds } });
  res.status(200).json({ status: SUCCESS, data: { savedRecipes } });
});

//crud

const createRecipe = asyncWrapper(async (req, res, next) => {
  const { name, instructions, cookingTime, userOwner ,recipeImage} = req.body;

  // if (!req.file) {
  //   return next(appError.createError("Image is required", 400, FAILED));
  // }
  const recipe = new RecipeModel({
    name,
    instructions,
    recipeImage: recipeImage ?? "placeholder",
    cookingTime,
    userOwner,
  });
  await recipe.save();
  res.status(201).json({ status: SUCCESS, data: { recipe } });
});

// export const uploadRecipeImage = asyncWrapper(async (req, res, next) => {

//   console.log(`uploading  recipe image)`);

//   if (!req.file) {
//     return next(appError.createError("Image is required", 400, FAILED));
//   }
//   const imgName= req.file.name;
//   console.log(imgName);
//   res.status(201).json({ status: SUCCESS,data:{imageName: req.file.name}});
// });

const getAll = asyncWrapper(async (req, res, next) => {
  const recipes = await RecipeModel.find();
  res.status(200).json({ status: SUCCESS, data: { recipes } });
});

const getRecipe = asyncWrapper(async (req, res, next) => {
  const recipeId = req.params.recipeId;
  if (!recipeId) {
    return next(appError.createError("Invalid recipe Id", 400, FAILED));
  }
  const recipe = await RecipeModel.findById(recipeId);
  if (!recipe) {
    return next(appError.createError("Recipe not found", 404, FAILED));
  }
  res.status(200).json({ status: SUCCESS, data: { recipe } });
});

const deleteRecipe = asyncWrapper(async (req, res, next) => {
  const { recipeId, userId } = req.params;
  console.log(recipeId, userId);
  const recipe = await RecipeModel.findById(recipeId);
  if (!recipe) {
    return next(appError.createError("Recipe not found", 404, FAILED));
  }
  if (recipe.userOwner.toString() !== userId) {
    return next(
      appError.createError("Your not allowed to delete the recipe", 400, FAILED)
    );
  }
  console.log(recipe.recipeImage);
  if (recipe.recipeImage !== "placeholder") {
    // remove the image file from the server
    await fs.unlink(`src/uploads/${recipe.recipeImage}`, () => {
      console.log("Image deleted successfully");
    });
  }

  await RecipeModel.deleteOne({ _id: recipeId });
  console.log("test");
  res.status(204).json({ status: SUCCESS, data: null });
});

const updateRecipe = asyncWrapper(async (req, res, next) => {
  const { recipeId, userId } = req.params;
  console.log(recipeId, "__________", userId);
  const { name, instructions, cookingTime } = req.body;
  const recipe = await RecipeModel.findById(recipeId);
  if (!recipe) {
    return next(appError.createError("Recipe not found", 404, FAILED));
  }
  if (recipe.userOwner.toString() !== userId) {
    return next(
      appError.createError("Your not allowed to Edit the recipe", 400, FAILED)
    );
  }
  if (req.file?.filename) {
    fs.unlinkSync(`src/uploads/${recipe.recipeImage}`, () => {
      console.log("Image deleted successfully");
    });
    recipe.recipeImage = req.file.filename;
  }
  recipe.name = name;
  recipe.instructions = instructions;
  recipe.cookingTime = cookingTime;
  const updatedRecipe = await recipe.save();
  res.status(200).json({ status: SUCCESS, data: { recipe: updatedRecipe } });
});
export {
  getAll,
  createRecipe,
  saveRecipe,
  getSavedRecipesIds,
  getSavedRecipes,
  updateRecipe,
  getRecipe,
  deleteRecipe,
  unSaveRecipe,
};

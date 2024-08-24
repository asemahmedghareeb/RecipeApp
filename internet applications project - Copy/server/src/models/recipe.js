import mongoose from "mongoose";
const RecipeSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  instructions: {
    type: String,
    required: true,
  },
  recipeImage: {
    type: String,
    required: false,
  },
  cookingTime: {
    type: Number,
    required: true,
  },
  userOwner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
});

const RecipeModel = mongoose.model("recipes", RecipeSchema);
export default RecipeModel;

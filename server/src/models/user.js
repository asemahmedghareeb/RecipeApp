import mongoose from "mongoose";
const userSchema = new mongoose.Schema({
    username: { type: String, required: true,unique: true},
    password: { type: String, required: true },
    savedRecipes:[{ type: mongoose.Schema.Types.ObjectId, ref:'recipes'}]
});

const User = mongoose.model("users", userSchema);
export default User;
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import User from "../models/user.js";
import { asyncWrapper } from "../middlewares/asyncWrapper.js";
import { FAILED,SUCCESS } from "../utils/httpStatus.js";
import appError from "../utils/appError.js";
const register = asyncWrapper(async (req, res, next) => {
  const { username, password } = req.body;

  const existingUser = await User.findOne({ username });
  if (existingUser) {
    return next( appError.createError("User already exists", 400, FAILED));
  }
  const hashedPassword = await bcrypt.hash(password, 10);
  const newUser = new User({ username, password: hashedPassword });
  await newUser.save();

  res.status(201).json({ status: SUCCESS, data: { user: newUser } });
});

const login = asyncWrapper(async (req, res, next) => {
  const { username, password } = req.body;
  const user = await User.findOne({ username });
  if (!user) {
    return next( appError.createError("User Doesn't exist", 400, FAILED));
  }
  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    return next( appError.createError("Invalid credentials", 400, FAILED));
  }
  const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });

  res.status(200).json({ status: SUCCESS, data: { userId:user._id }, token });
});
export { register, login };
import jwt from "jsonwebtoken";
import appError from "../utils/appError.js";
import { FAILED } from "../utils/httpStatus.js";
import { asyncWrapper } from "./asyncWrapper.js";
const verifyToken =async(req, res, next) => {
  const token = req.headers.authorization;
  if (!token) return next( appError.createError("There is no token ", 401, FAILED));
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return next(appError.createError("Invalid token", 403, FAILED));
    }
    next();
  });
};

export default verifyToken;

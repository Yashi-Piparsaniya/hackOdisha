import bcrypt from "bcryptjs";
import User from "../models/user.js";
import generateToken from "../utils/generateToken.js";

// Signup Controller
export const signupUser = async (req, res) => {
  try {
    const { email, username, password } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ success: false, message: "User already exists" });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const user = await User.create({ email, username, password: hashedPassword });

    // Send response with token
    res.status(201).json({
      success: true,
      message: "Registration successful",
      user: { email: user.email, username: user.username },
      token: generateToken(user._id),
    });
  } catch (err) {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export default { signupUser };
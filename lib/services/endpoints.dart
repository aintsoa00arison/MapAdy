class Endpoints {
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";
  static const String register = "/users/register";
  static const String profile = "/users"; 
  static const String leaderboard = "/leaderboard";
  static const String updateEmail = "/update-email"; 
  static const String updateAvatar = "/update-avatar";
  static const String ownedAvatars = "/owned-avatars"; 
  static const String sendCode = "/send-verification-code";
  static const String verifyCode = "/verify-code";
  
  // Boutique et Inventaire
  static const String shopGadgets = "/shop/gadgets";
  static const String shopAvatars = "/shop/avatars";
  static const String userGadgets = "/gadgets"; 

  // Quiz
  static const String nextQuiz = "/quiz/next"; // + /{user_id}
  static const String submitQuiz = "/quiz/submit";
}

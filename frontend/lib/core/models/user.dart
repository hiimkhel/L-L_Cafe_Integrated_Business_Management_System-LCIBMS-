// User Roles
enum UserRole { customer, admin, pos, rider }

// Hardcoded User model
class User {
  final String email;
  final String password;
  final UserRole role;

  User(this.email, this.password, this.role);
}
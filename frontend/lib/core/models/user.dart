enum UserRole { admin, cashier, rider, customer }

class User {
  final String email;
  final String password;
  final UserRole role;

  User(this.email, this.password, this.role);
}

UserRole stringToRole(String role) {
  switch (role) {
    case 'admin':
      return UserRole.admin;
    case 'cashier':
      return UserRole.cashier;
    case 'rider':
      return UserRole.rider;
    default:
      return UserRole.customer;
  }
}
enum UserRole { admin, cashier, rider, customer }

class User {
  final String id;
  final String email;
  UserRole role;
  final String? token;

  User( this.id,  this.email, this.role, this.token);

  // Helper for getting the current user's id
  int get mysqlId => int.parse(id);
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

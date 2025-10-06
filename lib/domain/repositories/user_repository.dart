import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> saveUser(UserModel user);
  Future<UserModel?> getCurrentUser();
}









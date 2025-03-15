import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharm/db/model/user.dart';
import 'package:pharm/db/repo/user_repo.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

final userProvider = StateNotifierProvider<UserNotifier, List<User>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserNotifier(userRepository);
});

class UserNotifier extends StateNotifier<List<User>> {
  final UserRepository userRepository;

  UserNotifier(this.userRepository) : super([]);

  Future<void> addUser(User user) async {
    await userRepository.addUser(user);
    state = [...state, user]; // Update state with the new user
  }

  Future<void> loadUsers() async {
    final users = await userRepository.getAllUsers();
    state = users;
  }

  Future<void> deleteUser(int id) async {
    await userRepository.deleteUser(id);
    // ignore: unrelated_type_equality_checks
    state = state.where((user) => user.id != id).toList();
  }
}

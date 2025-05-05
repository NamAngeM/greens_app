import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greens_app/services/auth_service.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('signIn - success', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
    });

    test('signIn - failure', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrongpassword',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
    });
  });
}
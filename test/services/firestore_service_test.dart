import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/services/firestore_service.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(),
])
import 'firestore_service_test.mocks.dart';

void main() {
  group('FirestoreService Tests', () {
    late FirestoreService firestoreService;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      firestoreService = FirestoreService(firestore: mockFirestore);
    });

    test('saveUserData - success', () async {
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('user123')).thenReturn(mockDoc);
      when(mockDoc.set(any)).thenAnswer((_) async => {});

      final result = await firestoreService.saveUserData(
        userId: 'user123',
        data: {'name': 'Test User'},
      );

      expect(result, isTrue);
      verify(mockDoc.set({'name': 'Test User'})).called(1);
    });

    test('getUserData - success', () async {
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('user123')).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.data()).thenReturn({
        'name': 'Test User',
        'email': 'test@example.com',
      });

      final result = await firestoreService.getUserData('user123');

      expect(result, isNotNull);
      expect(result?['name'], equals('Test User'));
      expect(result?['email'], equals('test@example.com'));
    });
  });
}
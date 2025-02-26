import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTransactions(String userId, {int limit = 20}) {
    try {
      debugPrint('Fetching transactions for userId: $userId'); // Debug print
      return _firestore
          .collection('Transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAtTimestamp', descending: true)
          .limit(limit)
          .snapshots();
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      rethrow;
    }
  }
}

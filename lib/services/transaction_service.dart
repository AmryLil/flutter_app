import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class TransactionService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaksis'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> transactionsJson = jsonData['data'];
        return transactionsJson
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Transaction> getTransaction(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaksis/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Transaction.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load transaction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaksis'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Transaction.fromJson(jsonData['data']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create transaction');
      }
    } catch (e) {
      debugPrint('Terjadi error saat create transaksi: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Transaction> updateTransaction(int id, Transaction transaction) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transaksis/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Transaction.fromJson(jsonData['data']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update transaction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transaksis/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete transaction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

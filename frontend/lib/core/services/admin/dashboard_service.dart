import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:frontend/core/models/dashboard_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {

 static const baseUrl = "http://localhost:3006/api/admin";
 
  Future<RevenueSummary> getRevenueSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/revenue'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load revenue summary');
    }

    return RevenueSummary.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<bool> updateDailyTarget(double target) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.put(
        Uri.parse('$baseUrl/dashboard/daily-target'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'target': target,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }

      debugPrint('Update target failed: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Update target error: $e');
      return false;
    }
  }

  Future<DashboardSummary> getDashboardSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/summary'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load dashboard summary');
    }

    final body = jsonDecode(response.body);

    return DashboardSummary.fromJson(
      body['data'],
    );
  }

  Future<List<TopMenuItem>> getTopMenus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/top-menus'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load top menus');
    }

    final body = jsonDecode(response.body);

    return (body['data'] as List)
        .map((item) => TopMenuItem.fromJson(item))
        .toList();
  }

  Future<List<DashboardOrderRow>> getRecentOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/recent-orders'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load recent orders');
    }

    final body = jsonDecode(response.body);

    return (body['data'] as List)
        .map((item) => DashboardOrderRow.fromJson(item))
        .toList();
  }

  Future<List<RevenueBarData>> getRevenueTrend() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/revenue-trend'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load revenue trend');
    }

    final body = jsonDecode(response.body);

    return (body['data'] as List)
        .map((item) => RevenueBarData.fromJson(item))
        .toList();
  }
}
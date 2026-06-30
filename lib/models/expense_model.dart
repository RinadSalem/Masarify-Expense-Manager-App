import 'package:flutter/material.dart';

class ExpenseModel {
  final int? id;
  final int userId;       // مفتاح خارجي يربط المصروف بالمستخدم
  final String title;
  final double amount;
  final String date;      
  final String category;

  ExpenseModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  static const List<String> categories = [
    'طعام وشراب',
    'مواصلات',
    'ترفيه',
    'تسوق',
    'فواتير',
    'صحة',
    'تعليم',
    'أخرى',
  ];

  
  static const Map<String, IconData> categoryIcons = {
    'طعام وشراب': Icons.fastfood,
    'مواصلات': Icons.directions_car,
    'ترفيه': Icons.sports_esports,
    'تسوق': Icons.shopping_bag,
    'فواتير': Icons.lightbulb,
    'صحة': Icons.medication,
    'تعليم': Icons.school,
    'أخرى': Icons.inventory_2,
  };

  static const Map<String, int> categoryColors = {
    'طعام وشراب': 0xFFFF6B6B,
    'مواصلات': 0xFF4ECDC4,
    'ترفيه': 0xFFFFE66D,
    'تسوق': 0xFFF7B731,
    'فواتير': 0xFF5F27CD,
    'صحة': 0xFF00D2D3,
    'تعليم': 0xFF54A0FF,
    'أخرى': 0xFF636E72,
  };

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      category: map['category'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
    };
  }

  ExpenseModel copyWith({
    int? id,
    int? userId,
    String? title,
    double? amount,
    String? date,
    String? category,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';

enum NotificationType { bell, email, notification }
enum Priority { cao, trung, thap }

class Task {
  final String id;
  String tenCongViec;
  DateTime? thoiGian;
  String diaDiem;
  bool nhacViec;
  NotificationType loaiNhac;
  Priority priority;
  bool hoanThanh;

  Task({
    required this.id,
    required this.tenCongViec,
    this.thoiGian,
    this.diaDiem = '',
    this.nhacViec = false,
    this.loaiNhac = NotificationType.bell,
    this.priority = Priority.trung,
    this.hoanThanh = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenCongViec': tenCongViec,
    'thoiGian': thoiGian?.toIso8601String(),
    'diaDiem': diaDiem,
    'nhacViec': nhacViec,
    'loaiNhac': loaiNhac.index,
    'priority': priority.index,
    'hoanThanh': hoanThanh,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    tenCongViec: json['tenCongViec'],
    thoiGian: json['thoiGian'] != null ? DateTime.parse(json['thoiGian']) : null,
    diaDiem: json['diaDiem'] ?? '',
    nhacViec: json['nhacViec'] ?? false,
    loaiNhac: NotificationType.values[json['loaiNhac'] ?? 0],
    priority: Priority.values[json['priority'] ?? 1],
    hoanThanh: json['hoanThanh'] ?? false,
  );

  static String encodeList(List<Task> tasks) =>
      json.encode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decodeList(String tasks) =>
      (json.decode(tasks) as List).map((t) => Task.fromJson(t)).toList();

  String get loaiNhacText {
    switch (loaiNhac) {
      case NotificationType.bell: return 'Nhắc bằng chuông';
      case NotificationType.email: return 'Nhắc bằng email';
      case NotificationType.notification: return 'Nhắc bằng thông báo';
    }
  }

  String get priorityText {
    switch (priority) {
      case Priority.cao: return 'Cao';
      case Priority.trung: return 'Trung bình';
      case Priority.thap: return 'Thấp';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case Priority.cao: return const Color(0xFFE53935);
      case Priority.trung: return const Color(0xFFFB8C00);
      case Priority.thap: return const Color(0xFF43A047);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum <ThemeMode> ได้มาจาก package:flutter/material.dart
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  // build() คือ constructor ของ Notifier, เป็นจุดเริ่มต้นของ State,คล้ายๆ initState ใน StatefulWidget
  ThemeMode build() => ThemeMode.light;
  void toggleTheme() {
    //เมื่อเปลี่ยนค่าให้ state, Riverpod จะรู้ทันทีว่าข้อมูลเปลี่ยนแล้ว และจะไปสั่งให้หน้าจอ (Widget) ที่ใช้งาน Provider นี้วาดใหม่ (Rebuild) โดยอัตโนมัติ
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// final themeNotifierProvider: คือ global var ที่เราจะไปเรียกใช้ที่ ui ที่ต้องการเปลี่ยน theme
// NotifierProvider<...>: เป็นคำสั่งสร้าง provider สำหรับ class ที่ extends Notifier
// <ThemeNotifier,..> : บอกว่าจะใช้ class ไหนจัดการ logic
// <.., ThemeMode> : บอกว่าค่าที่ได้ออกมาจาก provider นี้คือชนิดข้อมูลอะไร (Data Type)
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  //ฟังก์ชันสำหรับสร้าง Instance ของ class นั้นขึ้นมาใช้งาน
  () => ThemeNotifier(),
);

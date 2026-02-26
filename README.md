# 🔐 SecretPass — مدير كلمات السر

تطبيق Flutter احترافي لإدارة كلمات السر بتصميم داكن وذهبي، مع دعم بصمة الوجه (Face ID / Fingerprint).

---

## ✨ المميزات

- **قفل بكلمة السر الرئيسية** — يتم إنشاؤها أول مرة وتُحفظ بشكل مشفر
- **بصمة الوجه / البصمة** — Face ID على iOS، Fingerprint/Face على Android
- **تجميع الحسابات** — نفس الإيميل/المستخدم قد يملك أكثر من حساب، مجمعة بذكاء
- **نسخ كلمة السر** — بلمسة واحدة
- **بحث فوري** — ابحث باسم المستخدم أو الحساب أو الموقع
- **إضافة/تعديل/حذف** الحسابات
- **قفل تلقائي** عند العودة للتطبيق بعد الخروج منه
- **تصميم داكن وذهبي** احترافي بالكامل

---
Photos
![SecretPass](https://github.com/user-attachments/assets/2c806e9e-1ad0-4d68-a278-8e3b1c32962b)
<img width="1242" height="2688" alt="SecretPass1" src="https://github.com/user-attachments/assets/eb616d06-a739-444f-bb32-6a2973af5988" />
<img width="1242" height="2688" alt="SecretPass2" src="https://github.com/user-attachments/assets/6632a451-0770-4ca2-8779-caf8291e9e8e" />
<img width="1242" height="2688" alt="SecretPass3" src="https://github.com/user-attachments/assets/06fb3788-f44e-47fa-837c-81c51bcbd74b" />
<img width="1242" height="2688" alt="SecretPass4" src="https://github.com/user-attachments/assets/bc7e184a-f583-4f9d-ae01-10b7c4fff34b" />
<img width="1242" height="2688" alt="SecretPass5" src="https://github.com/user-attachments/assets/47f0ec1b-ca54-472f-b142-a4dbd3bac0d9" />
<img width="1242" height="2688" alt="SecretPass6" src="https://github.com/user-attachments/assets/a9e30e11-5fc7-4144-aca2-8bf6e448c5c7" />
<img width="1242" height="2688" alt="SecretPass7" src="https://github.com/user-attachments/assets/c6137f67-4053-4bf0-9114-7782147973ab" />


---
## 🛠 متطلبات التثبيت

```
Flutter SDK >= 3.0.0
Dart SDK >= 3.0.0
```

### iOS
- Xcode 14+
- iPhone مع Face ID أو Touch ID
- أو محاكي iOS (Face ID يعمل في المحاكي من قائمة Features)

### Android
- Android Studio مع emulator
- Android 6.0 (API 23)+

---

## 🚀 خطوات التثبيت

### 1. نسخ المشروع
```bash
cd secretpass_app
flutter pub get
```

### 2. تشغيل على iOS Simulator
```bash
# فتح المحاكي
open -a Simulator

# تشغيل التطبيق
flutter run
```

### 3. تشغيل على Android Emulator
```bash
# تشغيل المحاكي من Android Studio ثم:
flutter run
```

### 4. تشغيل على جهاز حقيقي
```bash
# iOS - يحتاج Apple Developer Account
flutter run --release

# Android
flutter run --release
```

---

## 📱 تفعيل Face ID في المحاكي (iOS Simulator)

1. افتح المحاكي
2. من القائمة: **Features → Face ID → Enrolled** ✓
3. عند طلب البصمة: **Features → Face ID → Matching Face** (نجاح) أو **Non-matching Face** (فشل)

---

## 🗂 هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية والثيم
├── models/
│   └── password_entry.dart      # نموذج البيانات
├── services/
│   ├── auth_service.dart        # المصادقة والبصمة
│   └── database_service.dart    # قاعدة البيانات SQLite
├── screens/
│   ├── auth_screen.dart         # شاشة الدخول
│   ├── home_screen.dart         # الشاشة الرئيسية
│   └── add_edit_screen.dart     # إضافة/تعديل
└── widgets/
    └── password_group_card.dart # بطاقة المجموعة
```

---

## 🔒 الأمان

- كلمة السر الرئيسية مخزنة كـ **SHA-256 hash** في `flutter_secure_storage`
- البيانات في **SQLite** محلية على الجهاز فقط
- لا يوجد أي اتصال بالإنترنت
- قفل تلقائي عند مغادرة التطبيق وطلب بصمة عند العودة

---

## 📦 المكتبات المستخدمة

| المكتبة | الاستخدام |
|---------|-----------|
| `local_auth` | Face ID / Fingerprint |
| `flutter_secure_storage` | تخزين كلمة السر المشفرة |
| `sqflite` | قاعدة بيانات SQLite |
| `flutter_animate` | تحريكات سلسة |
| `google_fonts` | خط Tajawal + Playfair Display |
| `crypto` | تشفير كلمة السر |
| `uuid` | معرفات فريدة للحسابات |

---

## 🎨 الألوان

| اللون | الكود |
|-------|-------|
| الخلفية الداكنة | `#0A0A0A` |
| سطح البطاقات | `#141414` |
| الذهبي (Amber) | `#FFB300` |
| الذهبي الفاتح | `#FFD54F` |

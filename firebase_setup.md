# دليل إعداد Firebase للبورتفوليو

هذا الدليل يوضح خطوات تهيئة قاعدة بيانات **Cloud Firestore** ومخزن الملفات **Firebase Storage** على حسابك لتشغيل البورتفوليو ديناميكياً.

---

## الخطوة 1: إنشاء مشروع Firebase جديد
1. اذهب إلى موقع [Firebase Console](https://console.firebase.google.com/).
2. اضغط على **Add Project** واكتب اسماً للمشروع (مثل: `martino-portfolio`).
3. اضغط على **Continue** (يمكنك تعطيل Google Analytics لأنه بورتفوليو شخصي) ثم اضغط على **Create Project**.

---

## الخطوة 2: تهيئة قاعدة البيانات Cloud Firestore
1. من القائمة الجانبية اليسرى، اضغط على **Build** ثم اختر **Firestore Database**.
2. اضغط على زر **Create Database**.
3. اختر موقع الخادم القريب منك (مثل `europe-west3`) واضغط على Next.
4. اختر **Start in production mode** ثم اضغط على Create.
5. بعد اكتمال التحميل، انتقل إلى تبويب **Rules** في الأعلى وقم باستبدال القواعد الافتراضية بالقواعد التالية (تسمح للزوار بالقراءة، وتسمح لك بالكتابة فقط عند تسجيل الدخول):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // يسمح لجميع الزوار بالقراءة، ويسمح بالكتابة فقط للمسجلين (لوحة التحكم)
    match /{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

6. اضغط على زر **Publish** في الأعلى لحفظ القواعد.

---

## الخطوة 3: تهيئة مخزن الملفات Firebase Storage (لرفع الصور والـ CV)
1. من القائمة اليسرى، اضغط على **Storage** تحت تبويب Build.
2. اضغط على **Get Started**.
3. اضغط على Next ثم Done للبدء بالخطة المجانية الافتراضية (تمنحك 5 جيجابايت مجاناً).
4. انتقل إلى تبويب **Rules** في الأعلى وقم باستبدالها بالقواعد التالية:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

5. اضغط على زر **Publish** لحفظ القواعد.

---

## الخطوة 4: تسجيل تطبيق الويب والحصول على المفاتيح (Credentials)
1. اذهب إلى الصفحة الرئيسية للمشروع **Project Overview** (أيقونة المنزل في أعلى اليسار).
2. اضغط على أيقونة الويب (`</>`) لتسجيل تطبيق ويب جديد.
3. اكتب اسماً للتطبيق (مثال: `portfolio-web`) ثم اضغط على **Register app**.
4. ستظهر لك أكواد تهيئة الـ Javascript. ابحث عن كائن `firebaseConfig` الذي يحتوي على المفاتيح:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "martino-portfolio.firebaseapp.com",
  projectId: "martino-portfolio",
  storageBucket: "martino-portfolio.appspot.com",
  messagingSenderId: "...",
  appId: "..."
};
```

5. **احفظ هذه المفاتيح**؛ لأننا سنحتاجها لملء ملف `lib/firebase_options.dart` لنربط كود الـ Flutter بحساب الـ Firebase الخاص بك مباشرة.

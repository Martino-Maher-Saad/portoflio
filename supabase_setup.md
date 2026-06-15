# دليل إعداد Supabase للبورتفوليو

يوضح هذا الدليل خطوات تهيئة مشروعك على **Supabase** مجاناً، وإنشاء الجداول المترابطة، وتهيئة مخزن الملفات (Storage) لرفع صورك والـ CV الخاص بك.

---

## الخطوة 1: إنشاء مشروع جديد في Supabase
1. اذهب إلى موقع [Supabase.com](https://supabase.com/) وسجل دخولك.
2. اضغط على **New Project** واكتب اسم المشروع (مثل: `martino-portfolio`).
3. اكتب كلمة مرور قوية لقاعدة البيانات (`Database Password`) واحفظها.
4. اختر المنطقة الجغرافية الأقرب لك واضغط على **Create New Project**.

---

## الخطوة 2: إنشاء الجداول باستخدام الـ SQL Editor
1. من القائمة الجانبية اليسرى في لوحة تحكم Supabase، اضغط على **SQL Editor** (أيقونة `>_`).
2. اضغط على **New Query** لفتح نافذة كتابة الأكواد.
3. انسخ كود الـ SQL التالي بالكامل والصقه في المحرر:

```sql
-- 1. جدول المعلومات الشخصية
CREATE TABLE personal_info (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    short_name TEXT NOT NULL,
    logo_text TEXT NOT NULL,
    titles TEXT[] NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    location TEXT NOT NULL,
    about_me TEXT NOT NULL,
    github TEXT NOT NULL,
    linkedin TEXT NOT NULL,
    cv_url TEXT NOT NULL,
    image_url TEXT NOT NULL
);

-- 2. جدول المهارات
CREATE TABLE skills (
    id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL,
    skills_list TEXT[] NOT NULL,
    display_order INT DEFAULT 0
);

-- 3. جدول الخبرات والتعليم
CREATE TABLE experiences (
    id SERIAL PRIMARY KEY,
    company TEXT NOT NULL,
    role TEXT NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP, -- Null يعني Present
    location TEXT NOT NULL,
    description TEXT NOT NULL,
    is_education BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0
);

-- 4. جدول المشاريع (مع هيكلة العلاقات داخله)
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    description TEXT NOT NULL,
    features TEXT[] NOT NULL, -- ميزات المشروع التفصيلية لصفحة العرض
    tech_stack TEXT[] NOT NULL,
    links JSONB NOT NULL DEFAULT '[]'::jsonb, -- روابط مرنة: [{"label": "GitHub", "url": "...", "type": "github"}]
    screenshots TEXT[] NOT NULL DEFAULT '{}'::text[], -- لقطات الشاشة
    display_order INT DEFAULT 0
);

-- تفعيل سياسات الحماية (Row Level Security - RLS)
ALTER TABLE personal_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- قواعد السماح بالقرءاة للجميع (Anonymous Read)
CREATE POLICY "Allow public read info" ON personal_info FOR SELECT USING (true);
CREATE POLICY "Allow public read skills" ON skills FOR SELECT USING (true);
CREATE POLICY "Allow public read experiences" ON experiences FOR SELECT USING (true);
CREATE POLICY "Allow public read projects" ON projects FOR SELECT USING (true);

-- قواعد السماح بالتعديل والإضافة فقط للمستخدمين المسجلين (Admin Write Access)
CREATE POLICY "Allow admin write info" ON personal_info FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow admin write skills" ON skills FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow admin write experiences" ON experiences FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow admin write projects" ON projects FOR ALL TO authenticated USING (true);
```

4. اضغط على زر **Run** في أسفل اليمين لتشغيل الكود. سيقوم بإنشاء الجداول الأربعة وتطبيق حمايتها الأمنية فوراً.

---

## الخطوة 3: إنشاء مخزن ملفات مجاني (Supabase Storage)
لرفع صورتك الشخصية وصور المشاريع وملف الـ CV مجاناً:
1. من القائمة الجانبية اليسرى، اضغط على **Storage** (أيقونة السلة/المخزن).
2. اضغط على **New Bucket**.
3. اكتب اسم المخزن: `portfolio_assets`.
4. قم بتفعيل الخيار **Public Bucket** (لكي يمكن لأي زائر للموقع استعراض صورك وملفاتك دون الحاجة لمصادقة أمنية).
5. اضغط على **Save**.
6. اذهب إلى تبويب **Policies** في Storage وتأكد من تفعيل صلاحيات الكتابة للمسجلين (`authenticated`) والقراءة للجميع (`public`). (يتم تهيئتها افتراضياً للـ Public Bucket).

---

## الخطوة 4: الحصول على مفاتيح الاتصال (API Credentials)
1. اضغط على أيقونة **Project Settings** (أيقونة الترس في أسفل القائمة اليسرى).
2. اختر قسم **API**.
3. ابحث عن:
   * **Project URL**: (رابط الاتصال بمشروعك).
   * **Project API keys**: انسخ المفتاح المكتوب تحته **`anon public`** (وهو مفتاح الاتصال العام).
4. سنقوم بنسخ هذين الحقلين ووضعهما في تطبيق الـ Flutter بداخل ملف `lib/main.dart` لربط الموقع بقاعدة بياناتك.

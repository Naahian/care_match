import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Lightweight app translations for the English and Bangla interfaces.
///
/// Keep user facing copy here so it can be expanded without coupling screens
/// to a translation package. Product/API content remains in its source language.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('bn')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizations(
        Localizations.maybeLocaleOf(context) ?? const Locale('en'),
      );

  bool get isBangla => locale.languageCode == 'bn';

  String text(String english) =>
      (isBangla ? _bangla[english] : null) ?? english;

  static const _bangla = <String, String>{
    'Home': 'হোম',
    'Settings': 'সেটিংস',
    'Doctors': 'চিকিৎসক',
    'Appointments': 'অ্যাপয়েন্টমেন্ট',
    'Notifications': 'বিজ্ঞপ্তি',
    'Profile': 'প্রোফাইল',
    'Preferences': 'সেটিংস',
    'App settings': 'অ্যাপ সেটিংস',
    'Language': 'ভাষা',
    'Choose Bangla or English': 'বাংলা অথবা ইংরেজি বেছে নিন',
    'Theme': 'থিম',
    'Choose app appearance': 'অ্যাপের চেহারা বেছে নিন',
    'About': 'সম্পর্কে',
    'About CareMatch': 'CareMatch সম্পর্কে',
    'Privacy and terms': 'গোপনীয়তা ও শর্তাবলি',
    'Read privacy and terms information': 'গোপনীয়তা ও শর্তাবলি পড়ুন',
    'Feedback': 'মতামত',
    'Send feedback by email': 'ইমেইলে মতামত পাঠান',
    'Delete prescription and appointment data':
        'প্রেসক্রিপশন ও অ্যাপয়েন্টমেন্টের তথ্য মুছুন',
    'Request removal of your medical records':
        'আপনার চিকিৎসার তথ্য মুছে ফেলার অনুরোধ',
    'Share anonymized AI checkup data':
        'পরিচয়বিহীন AI স্বাস্থ্য পরীক্ষার তথ্য শেয়ার করুন',
    'Help improve AI checkups without sharing your identity':
        'পরিচয় প্রকাশ না করে AI স্বাস্থ্য পরীক্ষা উন্নত করতে সহায়তা করুন',
    'Account': 'অ্যাকাউন্ট',
    'Change password': 'পাসওয়ার্ড পরিবর্তন',
    'Update your password': 'আপনার পাসওয়ার্ড আপডেট করুন',
    'Account deletion': 'অ্যাকাউন্ট মুছে ফেলুন',
    'Permanently delete your account':
        'আপনার অ্যাকাউন্ট স্থায়ীভাবে মুছে ফেলুন',
    'Accessibility': 'অ্যাক্সেসিবিলিটি',
    'Larger text': 'বড় লেখা',
    'Increase text size throughout the app': 'অ্যাপের সব লেখার আকার বাড়ান',
    'Got it': 'বুঝেছি',
    'Logout': 'লগ আউট',
    'Log out': 'লগ আউট',
    'Sign out of your account': 'আপনার অ্যাকাউন্ট থেকে সাইন আউট করুন',
    'Light': 'হালকা',
    'Dark': 'গাঢ়',
    'System': 'সিস্টেম',
    'Care, connected.': 'যত্ন, এখন আরও কাছে।',
    'What you can do': 'আপনি যা করতে পারবেন',
    'Built with': 'প্রযুক্তি',
    'Find the right care': 'সঠিক চিকিৎসা খুঁজুন',
    'Discover healthcare professionals and connect with a doctor suited to your needs.':
        'স্বাস্থ্যসেবা পেশাজীবীদের খুঁজুন এবং আপনার প্রয়োজন অনুযায়ী চিকিৎসকের সঙ্গে যোগাযোগ করুন।',
    'AI health checkups': 'AI স্বাস্থ্য পরীক্ষা',
    'Describe symptoms and get an assessment to help guide your next steps.':
        'আপনার উপসর্গ লিখুন এবং পরবর্তী পদক্ষেপের জন্য মূল্যায়ন পান।',
    'Manage appointments': 'অ্যাপয়েন্টমেন্ট পরিচালনা',
    'Book consultations, keep track of appointments, and access your care records.':
        'পরামর্শের সময় নিন, অ্যাপয়েন্টমেন্ট দেখুন এবং চিকিৎসার রেকর্ডে প্রবেশ করুন।',
    'Consult remotely': 'দূর থেকে পরামর্শ নিন',
    'Meet healthcare professionals through online consultations.':
        'অনলাইন পরামর্শের মাধ্যমে স্বাস্থ্যসেবা পেশাজীবীদের সঙ্গে কথা বলুন।',
    'My Profile': 'আমার প্রোফাইল',
    'My Reports': 'আমার রিপোর্ট',
    'My Appointments': 'আমার অ্যাপয়েন্টমেন্ট',
    'Book Appointment': 'অ্যাপয়েন্টমেন্ট নিন',
    'Select date & time': 'তারিখ ও সময় নির্বাচন করুন',
    'Retry': 'আবার চেষ্টা করুন',
    'Delete all': 'সব মুছুন',
    'No notifications yet': 'এখনও কোনো বিজ্ঞপ্তি নেই',
    'Cancel appointment': 'অ্যাপয়েন্টমেন্ট বাতিল করুন',
    'Keep appointment': 'অ্যাপয়েন্টমেন্ট রাখুন',
    'Payment': 'পেমেন্ট',
    'Download': 'ডাউনলোড',
    'Record saved.': 'রেকর্ড সংরক্ষিত হয়েছে।',
    'Find a doctor': 'চিকিৎসক খুঁজুন',
    'Search doctors': 'চিকিৎসক খুঁজুন',
    'How are you feeling?': 'আপনি কেমন অনুভব করছেন?',
    'Tell us your symptoms': 'আপনার উপসর্গ লিখুন',
    'Recommended doctors': 'প্রস্তাবিত চিকিৎসক',
    'Featured doctors': 'বিশেষজ্ঞ চিকিৎসক',
    'See all': 'সব দেখুন',
    'View all': 'সব দেখুন',
    'Find care that fits your needs.':
        'আপনার প্রয়োজন অনুযায়ী চিকিৎসা খুঁজুন।',
    'Good morning, Doctor': 'সুপ্রভাত, ডাক্তার',
    'Here’s your practice at a glance.': 'আপনার চেম্বারের সংক্ষিপ্ত চিত্র।',
    'Upcoming consultations': 'আসন্ন পরামর্শ',
    'Scheduled': 'নির্ধারিত',
    'Appointments today': 'আজকের অ্যাপয়েন্টমেন্ট',
    'Today’s schedule': 'আজকের সময়সূচি',
    'In-person appointments': 'সরাসরি অ্যাপয়েন্টমেন্ট',
    'Clinic visits today': 'আজকের ক্লিনিক ভিজিট',
    'Total earnings': 'মোট আয়',
    'All time': 'সর্বমোট',
    'Prescription': 'প্রেসক্রিপশন',
    'Write and manage': 'লিখুন ও পরিচালনা করুন',
    'All appointments': 'সব অ্যাপয়েন্টমেন্ট',
    'View your schedule': 'আপনার সময়সূচি দেখুন',
    'Today’s appointments': 'আজকের অ্যাপয়েন্টমেন্ট',
    'Video consultation': 'ভিডিও পরামর্শ',
    'In-person appointment': 'সরাসরি অ্যাপয়েন্টমেন্ট',
    'View': 'দেখুন',
    'Search': 'খুঁজুন',
    'Search doctors by name or specialty':
        'নাম বা বিশেষজ্ঞতা দিয়ে চিকিৎসক খুঁজুন',
    'No doctors found': 'কোনো চিকিৎসক পাওয়া যায়নি',
    'Try again': 'আবার চেষ্টা করুন',
    'No appointments yet': 'এখনও কোনো অ্যাপয়েন্টমেন্ট নেই',
    'Upcoming': 'আসন্ন',
    'Past': 'পূর্ববর্তী',
    'All': 'সব',
    'Completed': 'সম্পন্ন',
    'Cancelled': 'বাতিল',
    'Pending': 'অপেক্ষমাণ',
    'Loading…': 'লোড হচ্ছে…',
    'Something went wrong': 'কিছু সমস্যা হয়েছে',
    'Could not load your account.': 'আপনার অ্যাকাউন্ট লোড করা যায়নি।',
    'Could not load your profile.': 'আপনার প্রোফাইল লোড করা যায়নি।',
    'No reports yet': 'এখনও কোনো রিপোর্ট নেই',
    'Medical reports': 'মেডিকেল রিপোর্ট',
    'Prescriptions': 'প্রেসক্রিপশন',
    'Download…': 'ডাউনলোড হচ্ছে…',
    'Close': 'বন্ধ করুন',
    'Save': 'সংরক্ষণ',
    'Cancel': 'বাতিল',
    'Confirm': 'নিশ্চিত করুন',
    'Continue': 'চালিয়ে যান',
    'Next': 'পরবর্তী',
    'Back': 'ফিরে যান',
    'Back to home': 'হোমে ফিরুন',
    'Login': 'লগইন',
    'Sign in': 'সাইন ইন',
    'Create account': 'অ্যাকাউন্ট তৈরি করুন',
    'Email': 'ইমেইল',
    'Password': 'পাসওয়ার্ড',
    'Phone number': 'ফোন নম্বর',
    'Name': 'নাম',
    'Date of birth': 'জন্ম তারিখ',
    'Gender': 'লিঙ্গ',
    'Blood group': 'রক্তের গ্রুপ',
    'Male': 'পুরুষ',
    'Female': 'নারী',
    'Other': 'অন্যান্য',
    'Not specified': 'উল্লেখ করা হয়নি',
    'Retry loading profile': 'প্রোফাইল আবার লোড করুন',
    'Skip for now': 'এখন বাদ দিন',
    'Choose photo': 'ছবি বেছে নিন',
    'Remove photo': 'ছবি সরান',
    'Profile photo': 'প্রোফাইল ছবি',
    'Start assessment': 'মূল্যায়ন শুরু করুন',
    'Your assessment': 'আপনার মূল্যায়ন',
    'Recommended specialist': 'প্রস্তাবিত বিশেষজ্ঞ',
    'Reason for visit': 'ভিজিটের কারণ',
    'Price details': 'মূল্যের বিবরণ',
    'Secure payment': 'নিরাপদ পেমেন্ট',
    'Check status': 'অবস্থা যাচাই করুন',
    'Reload': 'আবার লোড করুন',
    'Join video consultation': 'ভিডিও পরামর্শে যোগ দিন',
    'Open chat consultation': 'চ্যাট পরামর্শ খুলুন',
    'Mark as completed': 'সম্পন্ন হিসেবে চিহ্নিত করুন',
    'Cancel appointment?': 'অ্যাপয়েন্টমেন্ট বাতিল করবেন?',
    'This will cancel the appointment.': 'এতে অ্যাপয়েন্টমেন্ট বাতিল হবে।',
    'Complete appointment?': 'অ্যাপয়েন্টমেন্ট সম্পন্ন করবেন?',
    'This will mark the appointment as completed.':
        'এতে অ্যাপয়েন্টমেন্ট সম্পন্ন হিসেবে চিহ্নিত হবে।',
    'All notifications cleared': 'সব বিজ্ঞপ্তি মুছে ফেলা হয়েছে',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

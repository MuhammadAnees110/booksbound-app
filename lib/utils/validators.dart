class Validators {
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an Email Address';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid Email Address';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a Password';
    }
    if (value.length < 6) {
      return 'Minimum 6 characters required';
    }
    return null;
  }
}

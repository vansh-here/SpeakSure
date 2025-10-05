class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < 16 || age > 100) {
      return 'Age must be between 16 and 100';
    }
    return null;
  }

  static String? validateGoal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Career goal is required';
    }
    if (value.length < 10) {
      return 'Please provide a more detailed career goal (at least 10 characters)';
    }
    return null;
  }

  static String? validateResume(String? value) {
    if (value == null || value.isEmpty) {
      return 'Resume is required';
    }
    return null;
  }
}



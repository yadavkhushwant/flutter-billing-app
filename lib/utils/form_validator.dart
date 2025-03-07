String? validateEmpty(String? value, String? filedName) {
  if (value == null || value.isEmpty) {
    return filedName != null ? 'Please enter $filedName' : 'Required';
  }
  return null;
}

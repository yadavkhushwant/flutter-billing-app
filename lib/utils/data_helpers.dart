// Helper method to extract customer details.
dynamic getCustomerDetails(dynamic customerId, List<dynamic> customerList) {
  if (customerId == null) return {};
  try {
    return customerList.firstWhere((element) => element['id'] == customerId);
  } catch (e) {
    return {};
  }
}

// Helper method to extract product details.
dynamic getProductDetails(dynamic productId, List<dynamic> productList) {
  if (productId == null) return {};
  try {
    return productList.firstWhere((element) => element['id'] == productId);
  } catch (e) {
    return {};
  }
}

// Helper method to extract uom details.
dynamic getUomDetails(dynamic uomId, List<dynamic> uomList) {
  if (uomId == null) return {};
  try {
    return uomList.firstWhere((element) => element['id'] == uomId);
  } catch (e) {
    return {};
  }
}
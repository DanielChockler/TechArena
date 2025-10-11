public func int64ToBase64(n: Int64): String {
    var base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    var result = String()
    var temp = n
    var is_negative = false
    
    // Handle negative numbers
    if (temp < 0) {
        is_negative = true
        temp = -temp
    }
    
    // Handle zero case separately
    if (temp == 0) {
        return "A"  // 'A' represents 0 in Base64
    }
    
    // Convert to Base64
    while (temp > 0) {
        var remainder = temp % 64
        result = base64_chars[remainder] + result
        temp = temp / 64
    }
    
    if (is_negative) {
        result = "N" + result  // 'N' prefix for negative
    }
    
    return result
}
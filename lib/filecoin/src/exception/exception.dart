/// Base exception for Filecoin operations
class FilecoinException implements Exception {
  final String message;
  final dynamic details;

  const FilecoinException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'FilecoinException: $message\nDetails: $details';
    }
    return 'FilecoinException: $message';
  }
}

/// Exception thrown when address validation or conversion fails
class FilecoinAddressException extends FilecoinException {
  const FilecoinAddressException(super.message, [super.details]);
  
  @override
  String toString() {
    if (details != null) {
      return 'FilecoinAddressException: $message\nDetails: $details';
    }
    return 'FilecoinAddressException: $message';
  }
}

/// Exception thrown when transaction signing fails
class FilecoinSignerException extends FilecoinException {
  const FilecoinSignerException(super.message, [super.details]);
  
  @override
  String toString() {
    if (details != null) {
      return 'FilecoinSignerException: $message\nDetails: $details';
    }
    return 'FilecoinSignerException: $message';
  }
}

/// Exception thrown when RPC request fails
class FilecoinRPCException extends FilecoinException {
  const FilecoinRPCException(super.message, [super.details]);
  
  @override
  String toString() {
    if (details != null) {
      return 'FilecoinRPCException: $message\nDetails: $details';
    }
    return 'FilecoinRPCException: $message';
  }
}

/// Exception thrown when CBOR serialization/deserialization fails
class FilecoinSerializationException extends FilecoinException {
  const FilecoinSerializationException(super.message, [super.details]);
  
  @override
  String toString() {
    if (details != null) {
      return 'FilecoinSerializationException: $message\nDetails: $details';
    }
    return 'FilecoinSerializationException: $message';
  }
}

/// Exception thrown when network operation fails
class FilecoinNetworkException extends FilecoinException {
  const FilecoinNetworkException(super.message, [super.details]);
  
  @override
  String toString() {
    if (details != null) {
      return 'FilecoinNetworkException: $message\nDetails: $details';
    }
    return 'FilecoinNetworkException: $message';
  }
}

/// Exception thrown when wallet operations fail
class FilecoinWalletException extends FilecoinException {
  const FilecoinWalletException(super.message, [super.details]);
  
  @override
  String toString() {
    if (details != null) {
      return 'FilecoinWalletException: $message\nDetails: $details';
    }
    return 'FilecoinWalletException: $message';
  }
}


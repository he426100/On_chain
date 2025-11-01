/// Exception class for Conflux-related errors.
class ConfluxPluginException implements Exception {
  /// Creates a [ConfluxPluginException] with the specified [message] and optional [details].
  const ConfluxPluginException(this.message, {this.details});

  /// The error message.
  final String message;

  /// Additional details about the error.
  final Map<String, dynamic>? details;

  @override
  String toString() {
    if (details == null) return 'ConfluxPluginException: $message';
    return 'ConfluxPluginException: $message\nDetails: $details';
  }
}

/// Exception for invalid Conflux addresses.
class InvalidConfluxAddressException extends ConfluxPluginException {
  const InvalidConfluxAddressException(super.message, {super.details});
}

/// Exception for invalid Base32 encoding/decoding.
class InvalidBase32Exception extends ConfluxPluginException {
  const InvalidBase32Exception(super.message, {super.details});
}

/// Exception for checksum validation errors.
class InvalidChecksumException extends ConfluxPluginException {
  const InvalidChecksumException(super.message, {super.details});
}

/// Exception for invalid network ID.
class InvalidNetworkIdException extends ConfluxPluginException {
  const InvalidNetworkIdException(super.message, {super.details});
}

/// Exception for invalid transaction errors.
class InvalidConfluxTransactionException extends ConfluxPluginException {
  const InvalidConfluxTransactionException(super.message, {super.details});
}

/// Exception for RPC-related errors.
class ConfluxRPCException extends ConfluxPluginException {
  const ConfluxRPCException(super.message, {super.details});
}

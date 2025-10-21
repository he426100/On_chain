/// Represents a Filecoin tipset
class FilecoinTipSet {
  final List<String> cids;
  final int height;

  const FilecoinTipSet({
    required this.cids,
    required this.height,
  });

  factory FilecoinTipSet.fromJson(Map<String, dynamic> json) {
    return FilecoinTipSet(
      cids: (json['Cids'] as List?)?.cast<String>() ?? [],
      height: json['Height'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Cids': cids,
      'Height': height,
    };
  }
}

/// Represents chain head information
class FilecoinChainHead {
  final List<String> cids;
  final List<FilecoinBlockHeader> blocks;
  final int height;

  const FilecoinChainHead({
    required this.cids,
    required this.blocks,
    required this.height,
  });

  factory FilecoinChainHead.fromJson(Map<String, dynamic> json) {
    return FilecoinChainHead(
      cids: (json['Cids'] as List?)?.cast<String>() ?? [],
      blocks: (json['Blocks'] as List?)?.map((e) => FilecoinBlockHeader.fromJson(e)).toList() ?? [],
      height: json['Height'] ?? 0,
    );
  }
}

/// Represents a Filecoin block header
class FilecoinBlockHeader {
  final String miner;
  final int timestamp;
  final List<String> parents;
  final int height;

  const FilecoinBlockHeader({
    required this.miner,
    required this.timestamp,
    required this.parents,
    required this.height,
  });

  factory FilecoinBlockHeader.fromJson(Map<String, dynamic> json) {
    return FilecoinBlockHeader(
      miner: json['Miner'] ?? '',
      timestamp: json['Timestamp'] ?? 0,
      parents: (json['Parents'] as List?)?.cast<String>() ?? [],
      height: json['Height'] ?? 0,
    );
  }
}

/// Represents version information from a Filecoin node
class FilecoinVersion {
  final String version;
  final String apiVersion;
  final int blockDelay;

  const FilecoinVersion({
    required this.version,
    required this.apiVersion,
    required this.blockDelay,
  });

  factory FilecoinVersion.fromJson(Map<String, dynamic> json) {
    return FilecoinVersion(
      version: json['Version'] ?? '',
      apiVersion: json['APIVersion'] ?? '',
      blockDelay: json['BlockDelay'] ?? 0,
    );
  }
}

/// Represents a Filecoin message CID
class FilecoinCID {
  final String cid;

  const FilecoinCID(this.cid);

  factory FilecoinCID.fromJson(Map<String, dynamic> json) {
    return FilecoinCID(json['/'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'/': cid};
  }
}

/// Represents a multisig message result with validity status
/// Note: Uses FilecoinMessage from fil_message.dart (no import needed due to export in filecoin.dart)
class FilecoinMsigMessageResult {
  final Map<String, dynamic> message;
  final bool validNonce;

  const FilecoinMsigMessageResult({
    required this.message,
    required this.validNonce,
  });

  factory FilecoinMsigMessageResult.fromJson(Map<String, dynamic> json) {
    return FilecoinMsigMessageResult(
      message: json['Message'] ?? {},
      validNonce: json['ValidNonce'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Message': message,
      'ValidNonce': validNonce,
    };
  }
}

/// Represents a pending multisig transaction
class FilecoinMsigTransaction {
  final int id;
  final String to;
  final String value;
  final int method;
  final String params;
  final List<String> approved;

  const FilecoinMsigTransaction({
    required this.id,
    required this.to,
    required this.value,
    required this.method,
    required this.params,
    required this.approved,
  });

  factory FilecoinMsigTransaction.fromJson(Map<String, dynamic> json) {
    return FilecoinMsigTransaction(
      id: json['ID'] ?? 0,
      to: json['To'] ?? '',
      value: json['Value'] ?? '0',
      method: json['Method'] ?? 0,
      params: json['Params'] ?? '',
      approved: (json['Approved'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'To': to,
      'Value': value,
      'Method': method,
      'Params': params,
      'Approved': approved,
    };
  }
}

/// Represents a multisig vesting schedule
class FilecoinMsigVestingSchedule {
  final String initialBalance;
  final int startEpoch;
  final int unlockDuration;

  const FilecoinMsigVestingSchedule({
    required this.initialBalance,
    required this.startEpoch,
    required this.unlockDuration,
  });

  factory FilecoinMsigVestingSchedule.fromJson(Map<String, dynamic> json) {
    return FilecoinMsigVestingSchedule(
      initialBalance: json['InitialBalance'] ?? '0',
      startEpoch: json['StartEpoch'] ?? 0,
      unlockDuration: json['UnlockDuration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InitialBalance': initialBalance,
      'StartEpoch': startEpoch,
      'UnlockDuration': unlockDuration,
    };
  }
}
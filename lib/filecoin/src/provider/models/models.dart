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
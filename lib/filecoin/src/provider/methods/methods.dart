/// Filecoin JSON-RPC method names
class FilecoinMethods {
  /// Chain methods
  static const String chainHead = 'Filecoin.ChainHead';
  static const String chainGetBlock = 'Filecoin.ChainGetBlock';
  static const String chainGetMessage = 'Filecoin.ChainGetMessage';
  static const String chainGetTipSetByHeight = 'Filecoin.ChainGetTipSetByHeight';

  /// Message pool methods
  static const String mpoolPush = 'Filecoin.MpoolPush';
  static const String mpoolGetNonce = 'Filecoin.MpoolGetNonce';
  static const String mpoolPending = 'Filecoin.MpoolPending';

  /// State methods
  static const String stateGetActor = 'Filecoin.StateGetActor';
  static const String stateAccountKey = 'Filecoin.StateAccountKey';
  static const String stateLookupID = 'Filecoin.StateLookupID';
  static const String stateCall = 'Filecoin.StateCall';

  /// Gas estimation
  static const String gasEstimateGasLimit = 'Filecoin.GasEstimateGasLimit';
  static const String gasEstimateGasPremium = 'Filecoin.GasEstimateGasPremium';
  static const String gasEstimateFeeCap = 'Filecoin.GasEstimateFeeCap';

  /// Wallet methods
  static const String walletBalance = 'Filecoin.WalletBalance';
  static const String walletSign = 'Filecoin.WalletSign';

  /// Version and network info
  static const String version = 'Filecoin.Version';
  static const String netAddrsListen = 'Filecoin.NetAddrsListen';
}
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
  static const String stateSearchMsg = 'Filecoin.StateSearchMsg';
  static const String stateWaitMsg = 'Filecoin.StateWaitMsg';
  static const String stateListMessages = 'Filecoin.StateListMessages';
  static const String stateReadState = 'Filecoin.StateReadState';

  /// Gas estimation
  static const String gasEstimateGasLimit = 'Filecoin.GasEstimateGasLimit';
  static const String gasEstimateGasPremium = 'Filecoin.GasEstimateGasPremium';
  static const String gasEstimateFeeCap = 'Filecoin.GasEstimateFeeCap';
  static const String gasEstimateMessageGas = 'Filecoin.GasEstimateMessageGas';

  /// Wallet methods
  static const String walletBalance = 'Filecoin.WalletBalance';
  static const String walletSign = 'Filecoin.WalletSign';

  /// Multisig methods
  static const String msigGetPending = 'Filecoin.MsigGetPending';
  static const String msigGetAvailableBalance = 'Filecoin.MsigGetAvailableBalance';
  static const String msigGetVested = 'Filecoin.MsigGetVested';
  static const String msigGetVestingSchedule = 'Filecoin.MsigGetVestingSchedule';
  static const String msigCreate = 'Filecoin.MsigCreate';
  static const String msigPropose = 'Filecoin.MsigPropose';
  static const String msigApprove = 'Filecoin.MsigApprove';
  static const String msigApproveTxnHash = 'Filecoin.MsigApproveTxnHash';
  static const String msigCancel = 'Filecoin.MsigCancel';
  static const String msigCancelTxnHash = 'Filecoin.MsigCancelTxnHash';
  static const String msigAddPropose = 'Filecoin.MsigAddPropose';
  static const String msigAddApprove = 'Filecoin.MsigAddApprove';
  static const String msigAddCancel = 'Filecoin.MsigAddCancel';
  static const String msigSwapPropose = 'Filecoin.MsigSwapPropose';
  static const String msigSwapApprove = 'Filecoin.MsigSwapApprove';
  static const String msigSwapCancel = 'Filecoin.MsigSwapCancel';
  static const String msigRemoveSigner = 'Filecoin.MsigRemoveSigner';

  /// Version and network info
  static const String version = 'Filecoin.Version';
  static const String netAddrsListen = 'Filecoin.NetAddrsListen';
}
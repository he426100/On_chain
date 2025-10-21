import 'package:test/test.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Multisig Methods Tests', () {
    group('Request Construction Tests', () {
      test('FilecoinRequestMsigCreate should construct correctly', () {
        final request = FilecoinRequestMsigCreate(
          required: 2,
          signers: ['f01234', 'f05678'],
          unlockDuration: 10101,
          value: '0',
          from: 'f01234',
          initialBalance: '1000000',
        );

        expect(request.method, FilecoinMethods.msigCreate);
        final json = request.toJson();
        expect(json[0], 2);
        expect(json[1], ['f01234', 'f05678']);
        expect(json[2], 10101);
        expect(json[3], '0');
        expect(json[4], 'f01234');
        expect(json[5], '1000000');
      });

      test('FilecoinRequestMsigPropose should construct correctly', () {
        final request = FilecoinRequestMsigPropose(
          multisig: 'f01234',
          to: 'f05678',
          value: '1000',
          from: 'f01234',
          methodNum: 1,
          params: 'Ynl0ZSBhcnJheQ==',
        );

        expect(request.method, FilecoinMethods.msigPropose);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f05678');
        expect(json[2], '1000');
        expect(json[3], 'f01234');
        expect(json[4], 1);
        expect(json[5], 'Ynl0ZSBhcnJheQ==');
      });

      test('FilecoinRequestMsigApprove should construct correctly', () {
        final request = FilecoinRequestMsigApprove(
          multisig: 'f01234',
          txnId: 42,
          proposer: 'f01234',
        );

        expect(request.method, FilecoinMethods.msigApprove);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 42);
        expect(json[2], 'f01234');
      });

      test('FilecoinRequestMsigApproveTxnHash should construct correctly', () {
        final request = FilecoinRequestMsigApproveTxnHash(
          multisig: 'f01234',
          txnId: 42,
          proposer: 'f01234',
          to: 'f05678',
          value: '0',
          from: 'f01234',
          methodNum: 42,
          params: 'Ynl0ZSBhcnJheQ==',
        );

        expect(request.method, FilecoinMethods.msigApproveTxnHash);
        final json = request.toJson();
        expect(json.length, 8);
        expect(json[0], 'f01234');
        expect(json[1], 42);
        expect(json[2], 'f01234');
        expect(json[3], 'f05678');
        expect(json[4], '0');
        expect(json[5], 'f01234');
        expect(json[6], 42);
        expect(json[7], 'Ynl0ZSBhcnJheQ==');
      });

      test('FilecoinRequestMsigCancel should construct correctly', () {
        final request = FilecoinRequestMsigCancel(
          multisig: 'f01234',
          txnId: 42,
          proposer: 'f01234',
        );

        expect(request.method, FilecoinMethods.msigCancel);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 42);
        expect(json[2], 'f01234');
      });

      test('FilecoinRequestMsigCancelTxnHash should construct correctly', () {
        final request = FilecoinRequestMsigCancelTxnHash(
          multisig: 'f01234',
          txnId: 42,
          to: 'f05678',
          value: '0',
          from: 'f01234',
          methodNum: 42,
          params: 'Ynl0ZSBhcnJheQ==',
        );

        expect(request.method, FilecoinMethods.msigCancelTxnHash);
        final json = request.toJson();
        expect(json.length, 7);
        expect(json[0], 'f01234');
        expect(json[1], 42);
        expect(json[2], 'f05678');
        expect(json[3], '0');
        expect(json[4], 'f01234');
        expect(json[5], 42);
        expect(json[6], 'Ynl0ZSBhcnJheQ==');
      });

      test('FilecoinRequestMsigAddPropose should construct correctly', () {
        final request = FilecoinRequestMsigAddPropose(
          multisig: 'f01234',
          from: 'f01234',
          newSigner: 'f09999',
          increase: true,
        );

        expect(request.method, FilecoinMethods.msigAddPropose);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f01234');
        expect(json[2], 'f09999');
        expect(json[3], true);
      });

      test('FilecoinRequestMsigAddApprove should construct correctly', () {
        final request = FilecoinRequestMsigAddApprove(
          multisig: 'f01234',
          from: 'f01234',
          txnId: 42,
          proposer: 'f01234',
          newSigner: 'f09999',
          increase: true,
        );

        expect(request.method, FilecoinMethods.msigAddApprove);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f01234');
        expect(json[2], 42);
        expect(json[3], 'f01234');
        expect(json[4], 'f09999');
        expect(json[5], true);
      });

      test('FilecoinRequestMsigAddCancel should construct correctly', () {
        final request = FilecoinRequestMsigAddCancel(
          multisig: 'f01234',
          from: 'f01234',
          txnId: 42,
          newSigner: 'f09999',
          increase: true,
        );

        expect(request.method, FilecoinMethods.msigAddCancel);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f01234');
        expect(json[2], 42);
        expect(json[3], 'f09999');
        expect(json[4], true);
      });

      test('FilecoinRequestMsigSwapPropose should construct correctly', () {
        final request = FilecoinRequestMsigSwapPropose(
          multisig: 'f01234',
          from: 'f01234',
          oldSigner: 'f05678',
          newSigner: 'f09999',
        );

        expect(request.method, FilecoinMethods.msigSwapPropose);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f01234');
        expect(json[2], 'f05678');
        expect(json[3], 'f09999');
      });

      test('FilecoinRequestMsigSwapApprove should construct correctly', () {
        final request = FilecoinRequestMsigSwapApprove(
          multisig: 'f01234',
          from: 'f01234',
          txnId: 42,
          proposer: 'f01234',
          oldSigner: 'f05678',
          newSigner: 'f09999',
        );

        expect(request.method, FilecoinMethods.msigSwapApprove);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f01234');
        expect(json[2], 42);
        expect(json[3], 'f01234');
        expect(json[4], 'f05678');
        expect(json[5], 'f09999');
      });

      test('FilecoinRequestMsigSwapCancel should construct correctly', () {
        final request = FilecoinRequestMsigSwapCancel(
          multisig: 'f01234',
          from: 'f01234',
          txnId: 42,
          oldSigner: 'f05678',
          newSigner: 'f09999',
        );

        expect(request.method, FilecoinMethods.msigSwapCancel);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f01234');
        expect(json[2], 42);
        expect(json[3], 'f05678');
        expect(json[4], 'f09999');
      });

      test('FilecoinRequestMsigRemoveSigner should construct correctly', () {
        final request = FilecoinRequestMsigRemoveSigner(
          multisig: 'f01234',
          from: 'f01234',
          toRemove: 'f05678',
          decrease: true,
        );

        expect(request.method, FilecoinMethods.msigRemoveSigner);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], 'f01234');
        expect(json[2], 'f05678');
        expect(json[3], true);
      });

      test('FilecoinRequestMsigGetPending should construct correctly', () {
        final request = FilecoinRequestMsigGetPending('f01234', null);

        expect(request.method, FilecoinMethods.msigGetPending);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], []);
      });

      test('FilecoinRequestMsigGetAvailableBalance should construct correctly',
          () {
        final request =
            FilecoinRequestMsigGetAvailableBalance('f01234', null);

        expect(request.method, FilecoinMethods.msigGetAvailableBalance);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], []);
      });

      test('FilecoinRequestMsigGetVested should construct correctly', () {
        final startTipSet = [
          {'/': 'bafy2bzacea3wsdh6y3a36tb3skempjoxqpuyompjbmfeyf34fi3uy6uue42v4'}
        ];
        final endTipSet = [
          {'/': 'bafy2bzacebp3shtrn43k7g3unredz7fxn4gj533d3o43tqn2p2ipxxhrvchve'}
        ];

        final request = FilecoinRequestMsigGetVested(
          'f01234',
          startTipSet,
          endTipSet,
        );

        expect(request.method, FilecoinMethods.msigGetVested);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], startTipSet);
        expect(json[2], endTipSet);
      });

      test('FilecoinRequestMsigGetVestingSchedule should construct correctly',
          () {
        final request =
            FilecoinRequestMsigGetVestingSchedule('f01234', null);

        expect(request.method, FilecoinMethods.msigGetVestingSchedule);
        final json = request.toJson();
        expect(json[0], 'f01234');
        expect(json[1], []);
      });
    });

    group('Response Model Tests', () {
      test('FilecoinCID should deserialize correctly', () {
        final json = {
          '/': 'bafy2bzacebbpdegvr3i4cosewthysg5xkxpqfn2wfcz6mv2hmoktwbdxkax4s'
        };

        final cid = FilecoinCID.fromJson(json);
        expect(cid.cid,
            'bafy2bzacebbpdegvr3i4cosewthysg5xkxpqfn2wfcz6mv2hmoktwbdxkax4s');

        final serialized = cid.toJson();
        expect(serialized['/'], cid.cid);
      });

      test('FilecoinMessage should deserialize correctly using fromLotus', () {
        final json = {
          'Version': 42,
          'To': 'f01234',
          'From': 'f05678',
          'Nonce': 100,
          'Value': '1000000',
          'GasLimit': 9,
          'GasFeeCap': '500',
          'GasPremium': '100',
          'Method': 1,
          'Params': 'Ynl0ZSBhcnJheQ==',
        };

        final message = FilecoinMessage.fromLotus(json);
        expect(message.version, 42);
        expect(message.to, 'f01234');
        expect(message.from, 'f05678');
        expect(message.nonce, 100);
        expect(message.value, '1000000');
        expect(message.gasLimit, 9);
        expect(message.gasFeeCap, '500');
        expect(message.gasPremium, '100');
        expect(message.method, 1);
        expect(message.params, 'Ynl0ZSBhcnJheQ==');

        final serialized = message.toLotus();
        expect(serialized['Version'], 42);
        expect(serialized['To'], 'f01234');
        expect(serialized['From'], 'f05678');
      });

      test('FilecoinMsigMessageResult should deserialize correctly', () {
        final json = {
          'Message': {
            'Version': 42,
            'To': 'f01234',
            'From': 'f05678',
            'Nonce': 100,
            'Value': '0',
            'GasLimit': 9,
            'GasFeeCap': '0',
            'GasPremium': '0',
            'Method': 1,
            'Params': 'Ynl0ZSBhcnJheQ==',
            'CID': {
              '/':
                  'bafy2bzacebbpdegvr3i4cosewthysg5xkxpqfn2wfcz6mv2hmoktwbdxkax4s'
            },
          },
          'ValidNonce': true,
        };

        final result = FilecoinMsigMessageResult.fromJson(json);
        expect(result.validNonce, true);
        expect(result.message['To'], 'f01234');
        expect(result.message['From'], 'f05678');
        expect(result.message['Method'], 1);

        final serialized = result.toJson();
        expect(serialized['ValidNonce'], true);
        expect(serialized['Message']['To'], 'f01234');
      });

      test('FilecoinMsigTransaction should deserialize correctly', () {
        final json = {
          'ID': 9,
          'To': 'f01234',
          'Value': '1000000',
          'Method': 1,
          'Params': 'Ynl0ZSBhcnJheQ==',
          'Approved': ['f01234', 'f05678'],
        };

        final transaction = FilecoinMsigTransaction.fromJson(json);
        expect(transaction.id, 9);
        expect(transaction.to, 'f01234');
        expect(transaction.value, '1000000');
        expect(transaction.method, 1);
        expect(transaction.params, 'Ynl0ZSBhcnJheQ==');
        expect(transaction.approved, ['f01234', 'f05678']);

        final serialized = transaction.toJson();
        expect(serialized['ID'], 9);
        expect(serialized['Approved'], ['f01234', 'f05678']);
      });

      test('FilecoinMsigVestingSchedule should deserialize correctly', () {
        final json = {
          'InitialBalance': '1000000000',
          'StartEpoch': 10101,
          'UnlockDuration': 50505,
        };

        final schedule = FilecoinMsigVestingSchedule.fromJson(json);
        expect(schedule.initialBalance, '1000000000');
        expect(schedule.startEpoch, 10101);
        expect(schedule.unlockDuration, 50505);

        final serialized = schedule.toJson();
        expect(serialized['InitialBalance'], '1000000000');
        expect(serialized['StartEpoch'], 10101);
        expect(serialized['UnlockDuration'], 50505);
      });

      test('FilecoinMsigTransaction should handle empty approved list', () {
        final json = {
          'ID': 1,
          'To': 'f01234',
          'Value': '0',
          'Method': 0,
          'Params': '',
        };

        final transaction = FilecoinMsigTransaction.fromJson(json);
        expect(transaction.approved, isEmpty);
      });
    });

    group('Method Constants Tests', () {
      test('All Msig method constants should be defined', () {
        expect(FilecoinMethods.msigGetPending, 'Filecoin.MsigGetPending');
        expect(FilecoinMethods.msigGetAvailableBalance,
            'Filecoin.MsigGetAvailableBalance');
        expect(FilecoinMethods.msigGetVested, 'Filecoin.MsigGetVested');
        expect(FilecoinMethods.msigGetVestingSchedule,
            'Filecoin.MsigGetVestingSchedule');
        expect(FilecoinMethods.msigCreate, 'Filecoin.MsigCreate');
        expect(FilecoinMethods.msigPropose, 'Filecoin.MsigPropose');
        expect(FilecoinMethods.msigApprove, 'Filecoin.MsigApprove');
        expect(FilecoinMethods.msigApproveTxnHash,
            'Filecoin.MsigApproveTxnHash');
        expect(FilecoinMethods.msigCancel, 'Filecoin.MsigCancel');
        expect(
            FilecoinMethods.msigCancelTxnHash, 'Filecoin.MsigCancelTxnHash');
        expect(FilecoinMethods.msigAddPropose, 'Filecoin.MsigAddPropose');
        expect(FilecoinMethods.msigAddApprove, 'Filecoin.MsigAddApprove');
        expect(FilecoinMethods.msigAddCancel, 'Filecoin.MsigAddCancel');
        expect(FilecoinMethods.msigSwapPropose, 'Filecoin.MsigSwapPropose');
        expect(FilecoinMethods.msigSwapApprove, 'Filecoin.MsigSwapApprove');
        expect(FilecoinMethods.msigSwapCancel, 'Filecoin.MsigSwapCancel');
        expect(
            FilecoinMethods.msigRemoveSigner, 'Filecoin.MsigRemoveSigner');
      });
    });
  });
}

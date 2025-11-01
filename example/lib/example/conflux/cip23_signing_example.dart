// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/conflux.dart';

/// Example demonstrating CIP-23 (Conflux's equivalent of EIP-712) structured data signing
///
/// CIP-23 Key Points:
/// - Uses "CIP23Domain" (not "EIP712Domain")
/// - chainId is mandatory in the domain
/// - Conflux addresses must be in Base32 format in the message, but are converted to hex for hashing
/// - Uses "\x19\x01" prefix (same as EIP-712)
///
/// This example shows:
/// - Creating typed data structures
/// - Signing with a private key
/// - Recovering the signer's address from a signature
void cip23SigningExample() {
  // Step 1: Create a private key for signing
  final privateKey = CFXPrivateKey.fromBytes(
    BytesUtils.fromHexString('0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'),
  );
  final publicKey = privateKey.publicKey();
  final signerAddress = publicKey.toAddress(1); // Mainnet

  // Conflux Core Space address
  // signerAddress: cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p

  // Step 2: Define the typed data structure
  // This follows the CIP-23 specification
  final typedData = CIP23TypedData(
    types: {
      'CIP23Domain': [
        CIP23TypeField(name: 'name', type: 'string'),
        CIP23TypeField(name: 'version', type: 'string'),
        CIP23TypeField(name: 'chainId', type: 'uint256'), // Mandatory in CIP-23
        CIP23TypeField(name: 'verifyingContract', type: 'address'),
      ],
      'Mail': [
        CIP23TypeField(name: 'from', type: 'Person'),
        CIP23TypeField(name: 'to', type: 'Person'),
        CIP23TypeField(name: 'contents', type: 'string'),
      ],
      'Person': [
        CIP23TypeField(name: 'name', type: 'string'),
        CIP23TypeField(name: 'wallet', type: 'address'),
      ],
    },
    primaryType: 'Mail',
    domain: {
      'name': 'Conflux Mail',
      'version': '1',
      'chainId': 1029, // Conflux mainnet
      'verifyingContract':
          'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p', // Base32 format
    },
    message: {
      'from': {
        'name': 'Alice',
        'wallet': 'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p', // Base32
      },
      'to': {
        'name': 'Bob',
        'wallet': 'cfx:aan02vpwvz8crpa1n10j17ufceefptdc2yzkr69p62', // Base32
      },
      'contents': 'Hello Bob!',
    },
  );

  // Step 3: Sign the typed data
  final signature = CIP23Signer.sign(privateKey, typedData);

  // Signature is a hex string (130 chars: 64 for r, 64 for s, 2 for v)
  // signature: 1234...abcd (example)

  // Step 4: Recover the signer's address from the signature
  final recoveredAddress = CIP23Signer.recover(
    signature,
    typedData,
    1, // networkId (mainnet)
  );

  // Verify that the recovered address matches the original signer
  // recoveredAddress should equal signerAddress

  // Step 5: Compute intermediate values (for debugging/verification)
  final domainSeparator = CIP23Signer.getDomainSeparator(typedData);
  // Domain separator (32 bytes)

  final messageHash = CIP23Signer.getMessageHash(typedData);
  // Final message hash that gets signed (32 bytes)

  // Step 6: Example with more complex types (arrays, nested structs)
  final complexTypedData = CIP23TypedData(
    types: {
      'CIP23Domain': [
        CIP23TypeField(name: 'name', type: 'string'),
        CIP23TypeField(name: 'chainId', type: 'uint256'),
      ],
      'Transaction': [
        CIP23TypeField(name: 'from', type: 'address'),
        CIP23TypeField(name: 'to', type: 'address'),
        CIP23TypeField(name: 'amount', type: 'uint256'),
        CIP23TypeField(name: 'nonce', type: 'uint256'),
        CIP23TypeField(name: 'data', type: 'bytes'),
      ],
    },
    primaryType: 'Transaction',
    domain: {
      'name': 'Conflux DApp',
      'chainId': 1029,
    },
    message: {
      'from': 'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p',
      'to': 'cfx:aan02vpwvz8crpa1n10j17ufceefptdc2yzkr69p62',
      'amount': '1000000000000000000', // 1 CFX (in Drip)
      'nonce': 0,
      'data': '0x', // Empty data
    },
  );

  final txSignature = CIP23Signer.sign(privateKey, complexTypedData);
  // Transaction signature

  // Important Notes:
  // 1. CIP-23 uses "CIP23Domain" as the domain type name (not "EIP712Domain")
  // 2. chainId is mandatory in CIP-23 domain
  // 3. Conflux addresses in the message should use Base32 format (cfx:...)
  // 4. When encoding, Base32 addresses are converted to hex for hashing
  // 5. The domain separator and message hashing follow EIP-712 structure
  // 6. Final hash: keccak256("\x19\x01" ‖ domainSeparator ‖ hashStruct(message))
}


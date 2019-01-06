pragma solidity ^0.5.0;

contract Multisig {

  mapping(address => bool) public is_owner;
  uint256 public number_of_owners;
  // Required signatures apart from the sender's.
  uint256 public required_extra_signatures;
  // Unique transaction ids. If the id is already used, the transaction is reverted.
  mapping(uint256 => bool) public is_used_tx_id;

  event CallSuccessful(bytes data, address destination, uint256 indexed tx_id);
  event CallUnsuccessful(bytes data, address destination, uint256 indexed tx_id);
  event AddedOwner(address new_owner);
  event RemovedOwner(address removed_owner);
  event ChangedRequiredExtraSignatures(uint256 new_extra_signatures_requirement);


  constructor(address[] owners, uint256 initial_required_extra_signatures) public {
    require(owners.length > 0, "At least one owner is necessary for the multisig to work.");
    require(initial_required_extra_signatures < owners.length, "Requiring more signatures than owners would deadlock the multisig.");

    for (uint256 i = 0; i < owners.length; i++) {
      addOwnerInternal(owners[i]);
    }

    required_extra_signatures = initial_required_extra_signatures;
  }

  function callAddress(bytes data, address destination, uint256 tx_id, uint8[] sig_v, bytes32[] sig_r, bytes32[] sig_s) public {
    require(!is_used_tx_id[tx_id]);
    is_used_tx_id[tx_id] = true;
    verifySignatures(data, destination, tx_id, sig_v, sig_r, sig_s);

    if (destination.call(data)) {
      emit CallSuccessful(data, destination, tx_id);
    }
    else {
      emit CallUnsuccessful(data, destination, tx_id);
    }
  }

  function addOwner(address new_owner) external onlyMultisig {
    addOwnerInternal(new_owner);
  }

  function addOwnerInternal(address new_owner) internal {
    require(new_owner != address(0));
    require(!is_owner[new_owner], "The address is already an owner of the multisig.");

    is_owner[new_owner] = true;
    number_of_owners += 1;
    emit AddedOwner(new_owner);
  }

  function removeOwner(address owner) external onlyMultisig {
    require(is_owner[owner], "The address should be an owner of the multisig.");
    require(number_of_owners > required_extra_signatures + 1);

    is_owner[owner] = false;
    number_of_owners -= 1;
    emit RemovedOwner(owner);
  }

  function changeRequiredExtraSignatures(uint256 new_requirement) external onlyMultisig {
    require(new_requirement < number_of_owners, "The new signature requirement should be satisfiable by the current owners.");

    required_extra_signatures = new_requirement;
    emit ChangedRequiredExtraSignatures(new_requirement);
  }

  function transferEther(uint256 value, address destination) external onlyMultisig {
    require(destination != address(0));

    destination.transfer(value);
  }

  function verifySignatures(bytes data, address destination, uint256 tx_id, uint8[] v, bytes32[] r, bytes32[] s) private view {
    require(is_owner[msg.sender], "The sender is not an owner of the multisig");
    require(v.length == r.length && r.length == s.length, "Inconsistent signature data.");
    require(v.length >= required_extra_signatures, "Amount of required signatures is not satisfied by received signatures.");

    address[] memory verified_signers = new address[](v.length + 1);
    verified_signers[0] = msg.sender;

    // Valid indices for verified_signers: [0, i]
    for (uint256 i = 0; i < v.length; i++) {
      bytes32 hash = keccak256(abi.encodePacked(msg.sender, data, destination, tx_id, address(this)));
      address signer = ecrecover(hash, v[i], r[i], s[i]);
      require(is_owner[signer], "One signer is not an owner.");

      for (uint256 j = 0; j <= i; j++) {
        require(verified_signers[j] != signer, "No repeated signatures are allowed.");
      }
      verified_signers[i + 1] = signer;
    }
  }

  modifier onlyMultisig() {
    require(msg.sender == address(this), "Only the multisig can call this function.");
    _;
  }

}
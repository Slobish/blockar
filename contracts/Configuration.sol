pragma solidity ^0.4.25;

import "./Ownable.sol";
import "./OwnedExchangeToken.sol";

contract Configuration is Ownable {
  address public exchangeContract;

  constructor(address exchange) public {
    exchangeContract = exchange;
  }

  /**
   * @dev Allows the owner to set the new exchange address.
   */
  function setExchangeContract(address new_exchange) public onlyOwner {
    require(new_exchange != address(0));
    exchangeContract = new_exchange;
  }

  /**
   * @dev Allows the owner to change the configuration contract of multiple tokens at once.
   * Changing the configuration contract of a token is an irreversible operation.
   */
  function updateTokensToUseNewConfiguration(OwnedExchangeToken[] tokens_to_update, address new_configuration) public onlyOwner {
    for (uint i = 0; i < tokens_to_update.length; i++) {
      tokens_to_update[i].updateConfigurationContract(new_configuration);
    }
  }

}

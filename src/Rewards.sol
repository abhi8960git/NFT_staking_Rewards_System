// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title N2DRewards
 * @dev ERC20 token with minting and burning capabilities. Only authorized controllers can mint new tokens, while
 *      both controllers and token holders can burn tokens. The owner can manage controllers that are authorized to mint/burn.
 */
contract N2DRewards is ERC20, ERC20Burnable, Ownable {

    /// @notice Mapping to keep track of addresses with controller privileges.
    mapping(address => bool) public controllers;

    /**
     * @dev Sets the name and symbol for the ERC20 token by passing them to the ERC20 base constructor.
     * The initial supply is zero, and tokens can be minted by authorized controllers.
     */
    constructor() ERC20("N2DRewards", "N2DR") Ownable(msg.sender) { }

    /**
     * @notice Mints new tokens to a specified address.
     * @dev Can only be called by addresses that are authorized as controllers.
     * @param to The address that will receive the minted tokens.
     * @param amount The number of tokens to be minted.
     */
    function mint(address to, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        _mint(to, amount);
    }

    /**
     * @notice Burns tokens from an account. If the caller is a controller, they can burn tokens from any account without allowance.
     * @dev Overrides the `burnFrom` function in ERC20Burnable to allow controllers to bypass the allowance requirement.
     * @param account The account from which tokens will be burned.
     * @param amount The number of tokens to burn.
     */
    function burnFrom(address account, uint256 amount) public override {
        if (controllers[msg.sender]) {
            // Controllers bypass allowance checks
            _burn(account, amount);
        } else {
            // Non-controllers must follow standard allowance rules
            super.burnFrom(account, amount);
        }
    }

    /**
     * @notice Adds a new controller.
     * @dev Only callable by the contract owner.
     * @param controller The address to be granted controller privileges.
     */
    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    /**
     * @notice Removes controller privileges from an address.
     * @dev Only callable by the contract owner.
     * @param controller The address to have its controller privileges revoked.
     */
    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }
}

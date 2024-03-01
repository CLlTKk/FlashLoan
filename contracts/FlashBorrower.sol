// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC3156FlashLender.sol";
import "./IERC3156FlashBorrower.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashBorrower is IERC3156FlashBorrower{
    IERC3156FlashLender lender;

    error ERC3156UntrustedLender(address lender);
    error ERC3156UntrustedInitiator(address initiator);

    event Action1(address borrower, address token, uint amount, uint fee);

    constructor(address _lender){
        lender = IERC3156FlashLender(_lender);
    }

    function onFlashLoan(address initiator, address token, uint256 amount,
        uint256 fee, bytes calldata data) external returns (bytes32){
            if (initiator != address(this)) {
                revert ERC3156UntrustedInitiator(initiator);
            }

            if (msg.sender != address(lender)) {
                revert ERC3156UntrustedLender(address(msg.sender));
            }

            (uint action) = abi.decode(data, (uint));

            if (action == 1) {
                emit Action1(address(this), token, amount, fee);
            } else {
                //...
        }

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function flashBorrow(address token, uint amount, bytes calldata data) public{
        uint _allowance = IERC20(token).allowance(address(this), address(lender));
        uint _fee = lender.flashFee(token, amount);

        uint _repayment = amount + _fee;

        IERC20(token).approve(address(lender), _allowance + _repayment);

        lender.flashLoan(this, token, amount, data);
    }

}
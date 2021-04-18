// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";


contract StepVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event ReceiverChanged(address oldWallet, address newWallet);

    uint256 public immutable startTimetamp;
    IERC20 public immutable token;
    uint256 public immutable cliffDuration;
    uint256 public immutable stepDuration;
    uint256 public immutable stepAmount;
    uint256 public immutable numOfSteps;

    address public receiver;
    uint256 public claimed;

    modifier onlyReceiver {
        require(msg.sender == receiver, "access denied");
        _;
    }

    constructor(
        IERC20 _token,
        uint256 _startTimestamp,
        uint256 _cliffDuration,
        uint256 _stepDuration,
        uint256 _stepAmount,
        uint256 _numOfSteps,
        address _receiver
    ) public {
        startTimetamp = _startTimestamp;
        token = _token;
        cliffDuration = _cliffDuration;
        stepDuration = _stepDuration;
        stepAmount = _stepAmount;
        numOfSteps = _numOfSteps;
        setReceiver(_receiver);
    }

    function available() public view returns(uint256) {
        return claimable().sub(claimed);
    }

    function claimable() public view returns(uint256) {
        uint256 firstClaim = startTimetamp.add(cliffDuration);
        if (block.timestamp < firstClaim) {
            return 0;
        }

        uint256 passedSinceCliff = block.timestamp.sub(firstClaim);
        uint256 stepsPassed = Math.min(numOfSteps, passedSinceCliff.div(stepDuration).add(1));
        return stepsPassed.mul(stepAmount);
    }

    function setReceiver(address _receiver) public onlyOwner {
        emit ReceiverChanged(receiver, _receiver);
        receiver = _receiver;
    }

    function kill(address target) external onlyOwner {
        uint256 amount = token.balanceOf(address(this));
        token.safeTransfer(target, amount);
    }

    function claim() external onlyReceiver {
        uint256 amount = available();
        claimed = claimed.add(amount);
        token.safeTransfer(msg.sender, amount);
    }
}

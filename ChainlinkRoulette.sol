pragma solidity 0.6.6;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/master/evm-contracts/src/v0.6/VRFConsumerBase.sol";

contract ChainlinkRoulette is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    address payable public casino;
    uint seed = 9284729378;
    uint256 public maxBet = 1 ether;
    uint256 internal maxBetRatio = 1000;
    
    struct Bet {
        address payable addr;
        uint bet_num;
        uint amount;
    }
    
    mapping(bytes32 => Bet) public book;
    
    uint256 internal randomResult;
    uint256 public spinResult;
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor() 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        casino = msg.sender;
    }
    
    modifier checkMaxBet{
        require(msg.value <= maxBet, "This bet exceed max possible bet");
        _;
    }
    
    function addBalance() external payable {
    }
    
    function withdrawWei(uint wei_amount) public {
        casino.transfer(wei_amount);
        maxBet = address(this).balance / maxBetRatio;
    }


    //spin wheel TODO: INCOrPERATE CHAINLINK
    function spinWheel(uint user_seed, uint bet_num ) payable public checkMaxBet{
        // Get address of sender
        address payable bettor;
        bettor = msg.sender;
        
        //Request randomness, get request id
        bytes32 current_request;
        current_request = _getRandomNumber(user_seed);
        
        //store request id and address
        Bet memory cur_bet = Bet(bettor, bet_num, msg.value);
        book[current_request] = cur_bet;
        
    }

    /** 
     * Requests randomness from a user-provided seed
     */
    function _getRandomNumber(uint256 userProvidedSeed) private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        
        
        randomResult = randomness;
        
        //load bet from memory
        Bet memory _curBet = book[requestId];
        uint _betNum = _curBet.bet_num;
        address payable _bettor = _curBet.addr;
        uint _amount = _curBet.amount;
        
        //calculate spin result
        uint _spinResult = randomResult % 33;
        
        //display spin result to public (only works if low volume)
        spinResult = _spinResult;
        
        //pay if they are a winner!
        if (_spinResult == _betNum) {
            (bool sent, bytes memory data) = _bettor.call.value(_amount*32)("");
            require (sent, "failed to send ether :(");
        }
        maxBet = address(this).balance / maxBetRatio;
        
        //delete bet from memory
        
        delete book[requestId];
        
    }
    
}

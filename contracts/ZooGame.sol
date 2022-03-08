// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


    import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    import "@openzeppelin/contracts/utils/math/SafeMath.sol";
    import "./Combiner.sol";
    import "./Zoogametoken.sol";


contract ZooGame is Ownable  {

    using SafeMath for uint256;

    /*
        Variables
    */

    uint256 public rewardPerBlockTier1 = 2;
    uint256 public rewardPerBlockTier2 = 4;
    uint256 public rewardPerBlockTier3 = 6;
    uint256 public rewardPerBlockTier4 = 8;
    uint256 public rewardPerBlockTier5 = 10;
    ZooToken public zoo;
    IERC721 zooKeeper;
    uint256 private limit = 999999999999999999;
    ZooCombinedExhibits public exhibit;
    bool public status = false;

    /*
        Mapping
    */

    mapping (uint256 => uint256 /*lastclaim*/) public tokenMap;
    mapping (address => uint256 []) public tokenStaked;

    /*
        Constructor
    */    

    constructor (ZooCombinedExhibits _exhibit, ZooToken _zoo, address _zooKeeper) {
        exhibit = _exhibit;
        zoo = _zoo;
        zooKeeper =  IERC721(_zooKeeper); 
    }

    /*
        Staking and Withdraw Functions
    */

    function singleStake (uint256 _tokenId) public {
        require(0 < zooKeeper.balanceOf(msg.sender), "You must own a zookeeper");
        require(status, "Staking not active");
        exhibit.transferFrom(msg.sender, address(this), _tokenId);
        tokenStaked[msg.sender].push(_tokenId);
        tokenMap[_tokenId] = block.number;
    }

    function multiStake (uint256[] calldata _tokenId) public {
        require(status, "Staking not active");
        require(0 < zooKeeper.balanceOf(msg.sender), "You must own a zookeeper");
        for (uint256 i = 0; i < _tokenId.length; i++) {
        exhibit.transferFrom(msg.sender, address(this), _tokenId[i]);
        tokenStaked[msg.sender].push(_tokenId[i]);
        tokenMap[_tokenId[i]] = block.number;
        }
    }

    function singleWithdraw (uint256 _tokenId) public {
        uint256 i = 0;
        while (i < tokenStaked[msg.sender].length) {
            if (tokenStaked[msg.sender][i] == _tokenId) {
                exhibit.transferFrom(address(this), msg.sender, _tokenId);
                delete tokenStaked[msg.sender][_tokenId];
                tokenMap[_tokenId] = limit;
                i = tokenStaked[msg.sender].length + 1;
            }
            i=i+i;
        }
    }

    function withdrawAll () public {
        uint256 i = 0;
        while (i < tokenStaked[msg.sender].length) {
                exhibit.transferFrom(address(this), msg.sender, tokenStaked[msg.sender][i]);
                delete tokenStaked[msg.sender][tokenStaked[msg.sender][i]];
                tokenMap[tokenStaked[msg.sender][i]] = limit;
            }
            i=i+i;
    }

    /*
        Claim Functions
    */

    function claim () public {
        require(status, "Staking not active");
        uint256 reward = calculateReward(msg.sender);
        uint256 i = 0;
        while (i < tokenStaked[msg.sender].length) {
            tokenMap[tokenStaked[msg.sender][i]] = block.number;
            i = i + 1;
        }
        zoo.mint(msg.sender, reward);
    }

    function calculateReward (address _staker) public view returns (uint256) {
        uint256 currentReward = 0;
        uint256 i = 0;
        while (i < tokenStaked[_staker].length) {
            uint256 tier = exhibit.tier(tokenStaked[_staker][i]);
            uint256 newTokenThing = 0;
                    if (tier < 5) {
                        newTokenThing = rewardPerBlockTier1.mul(block.number.sub(tokenMap[tokenStaked[_staker][i]]));
                    }
                    if (tier < 9 && tier > 4) {
                        newTokenThing = rewardPerBlockTier2.mul(block.number.sub(tokenMap[tokenStaked[_staker][i]]));
                    }
                    if (tier < 13 && tier > 8) {
                        newTokenThing = rewardPerBlockTier3.mul(block.number.sub(tokenMap[tokenStaked[_staker][i]]));
                    }
                    if (tier < 17 && tier > 12) {
                        newTokenThing = rewardPerBlockTier4.mul(block.number.sub(tokenMap[tokenStaked[_staker][i]]));
                    }
                    if (tier < 21 && tier > 16) {
                        newTokenThing = rewardPerBlockTier5.mul(block.number.sub(tokenMap[tokenStaked[_staker][i]]));
                    }
            currentReward = currentReward.add(newTokenThing);
            i = i + 1;
        }
        return currentReward;
    }

    /*
        Owner Functions
    */

    function setStatus (bool  _newStatus) public onlyOwner {
        status = _newStatus;
    }


}
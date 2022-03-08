// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Zoogametoken.sol";

contract ZooKeepers is ERC721, ERC721Enumerable, Ownable {

    using SafeERC20 for IERC20;

    bool public saleIsActive = false;
    string private _baseURIextended;

    bool public isAllowListActive = false;
    uint256 public constant MAX_SUPPLY = 5000;
    uint256 public constant MAX_PUBLIC_MINT = 20;
    uint256 public constant PRICE_PER_TOKEN_ALLOWLIST = 0.02 ether;
    uint256 public constant PRICE_PER_TOKEN = 0.03 ether;
    uint256 public tokenMintReward = 100 ether;
    IERC20 public weth;
    ZooToken public zoo;


    mapping(address => uint8) private _allowList;

    constructor(address _weth, ZooToken _zoo) ERC721("Zoo Keepers Genesis", "Zoo Keepers Genesis") {
        weth = IERC20(_weth);
        zoo = _zoo;
    }

    function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
        isAllowListActive = _isAllowListActive;
    }

    function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _allowList[addresses[i]] = numAllowedToMint;
        }
    }

    function numAvailableToMint(address addr) external view returns (uint8) {
        return _allowList[addr];
    }

    function mintAllowList(uint8 numberOfTokens) external payable {
        uint256 ts = totalSupply();
        require(isAllowListActive, "Allow list is not active");
        require(numberOfTokens <= _allowList[msg.sender], "Exceeded max available to purchase");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(weth.balanceOf(msg.sender) >= PRICE_PER_TOKEN_ALLOWLIST * numberOfTokens, "Weth balance insufficient");

        weth.safeTransferFrom(msg.sender, address(this), PRICE_PER_TOKEN_ALLOWLIST * numberOfTokens);
        zoo.mint(msg.sender, tokenMintReward * numberOfTokens);
        _allowList[msg.sender] -= numberOfTokens;
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function reserve(uint256 n) public onlyOwner {
      uint supply = totalSupply();
      uint i;
      for (i = 0; i < n; i++) {
          _safeMint(msg.sender, supply + i);
      }
    }

    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function mint(uint numberOfTokens) public payable {
        uint256 ts = totalSupply();
        require(saleIsActive, "Sale must be active to mint tokens");
        require(numberOfTokens <= MAX_PUBLIC_MINT, "Exceeded max token purchase");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(weth.balanceOf(msg.sender) >= PRICE_PER_TOKEN * numberOfTokens, "Weth balance insufficient");

        weth.safeTransferFrom(msg.sender, address(this), PRICE_PER_TOKEN * numberOfTokens);
        zoo.mint(msg.sender, tokenMintReward * numberOfTokens);
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    function withdraw() public onlyOwner {
        weth.transfer(owner(), weth.balanceOf(address(this)));
    }
}
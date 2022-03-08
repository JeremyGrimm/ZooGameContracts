// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
    import "@openzeppelin/contracts/utils/math/SafeMath.sol";
    import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
    import "@openzeppelin/contracts/utils/Strings.sol";

contract ZooExhibits is ERC1155, Ownable  {

    using Strings for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /*
        Variables
    */

    uint256 public tier1Price = 10 ether;
    uint256 public tier2Price = 20 ether;
    uint256 public tier3Price = 30 ether;
    uint256 public tier4Price = 40 ether;
    uint256 public tier5Price = 50 ether;
    bool public status = false;
    string public _baseURI;
    IERC20 public zoo;

    /*
        Constructor
    */    

        constructor (address _zoo) ERC1155 ("uri") {
        zoo = IERC20(_zoo); 
    }

    /*
        Name and Symbol
    */

    //name of nft
    function name() external pure returns (string memory) {
        return "Zoo Game : Exhibits";
    }
    //symbol of nft
    function symbol() external pure returns (string memory) {
        return "Zoo Game : Exhibits";
    }

    /*
        mint function
    */

    function mint (uint256 _amount, uint256 _id) public payable {
        require(status, "sale not started");
        require(_id > 0 && _id < 21, "Invalid ids");

        if (_id < 5) {
            require(zoo.balanceOf(msg.sender) >= _amount.mul(tier1Price * _amount), "Your balance is too little");
            zoo.safeTransferFrom(msg.sender, address(this), tier1Price * _amount);
            _mint(msg.sender, _id, _amount, "");
        }
        if (_id < 9 && _id > 4) {
            require(zoo.balanceOf(msg.sender) >= _amount.mul(tier2Price * _amount), "Your balance is too little");
            zoo.safeTransferFrom(msg.sender, address(this), tier2Price * _amount);
            _mint(msg.sender, _id, _amount, "");
        }
        if (_id < 13 && _id > 8) {
            require(zoo.balanceOf(msg.sender) >= _amount.mul(tier3Price * _amount), "Your balance is too little");
            zoo.safeTransferFrom(msg.sender, address(this), tier3Price * _amount);
            _mint(msg.sender, _id, _amount, "");
        }
        if (_id < 17 && _id > 12) {
            require(zoo.balanceOf(msg.sender) >= _amount.mul(tier4Price * _amount), "Your balance is too little");
            zoo.safeTransferFrom(msg.sender, address(this), tier4Price * _amount);
            _mint(msg.sender, _id, _amount, "");
        }
        if (_id < 21 && _id > 16) {
            require(zoo.balanceOf(msg.sender) >= _amount.mul(tier5Price * _amount), "Your balance is too little");
            zoo.safeTransferFrom(msg.sender, address(this), tier5Price * _amount);
            _mint(msg.sender, _id, _amount, "");
        }
    }

    /*
        Uri Functions
    */

    /*
        Uri Functions
    */

    function uri(uint256 _id)  public view virtual override returns (string memory) {
        require (_id < 21, "nonexistent token");
        string memory base = baseURI();
        return string(abi.encodePacked(base, Strings.toString(_id)));
    }

    function _setBaseURI(string memory baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }
    
    function baseURI() internal virtual view returns (string memory) {
        return _baseURI;
    }

    /*
        Main Owner Functions
    */

    function setStatus (bool  _newStatus) public onlyOwner {
        status = _newStatus;
    }

    
}
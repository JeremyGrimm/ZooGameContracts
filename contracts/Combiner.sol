// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    import "@openzeppelin/contracts/token/ERC721/ERC721.sol";  
    import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
    import "@openzeppelin/contracts/utils/math/SafeMath.sol";
    import "@openzeppelin/contracts/utils/Strings.sol";
    import "./Exhibit.sol";


contract ZooCombinedExhibits is ERC721, ERC1155Holder, Ownable  {

    using Strings for uint256;
    using SafeMath for uint256;
    event Combined (address nftAddress, uint256 animalId, uint256 exhibitId, uint256 newId);

    /*
        Overrides because both ERC721 and ERC1155 Receiver
    */

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC1155Receiver ) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /*
        Variables
    */

    ZooExhibits public exhibit;
    uint256 counter;
    string private URI;
    bool public status = true;

    /*
        Structs
    */

    struct pairs {
        address nft;
        uint256 animalId;
        uint256 exhibitId;
        uint256 tier;
    }

    struct tierSystem {
        address theAddress;
        uint256 theTier;
    }

    /*
        Mapping
    */

    mapping (uint256 => pairs) public pairing;
    mapping (uint256 => uint256) public tiers;
    mapping (uint256 => tierSystem) public nftAddressParing;

    /*
        Constructor
    */    

        constructor (ZooExhibits _exhibit) ERC721("Zoo Game : Combined Exhibits", "Zoo Game : Combined Exhibits") {
            exhibit = _exhibit;

    }

    /*
        Combine and Withdraw Functions
    */

    function combine (uint256 _nftAddressId, uint256 _animalId, uint256 _exhibitId) public {
        //require started
        require(status, "Not started");
        //require tier system lines up
        require(nftAddressParing[_nftAddressId].theTier ==  _tierOfExhibit(_exhibitId), "Tiers of animal and exhibit do not match");
        //transfers
        exhibit.safeTransferFrom(msg.sender, address(this), _exhibitId, 1, "");
        IERC721(nftAddressParing[_nftAddressId].theAddress).transferFrom(msg.sender, address(this), _animalId);
        //ending stuff

        pairing[counter] = pairs(nftAddressParing[_nftAddressId].theAddress, _animalId, _exhibitId, _tierOfExhibit(_exhibitId));
        _safeMint(msg.sender, counter);
        emit Combined(nftAddressParing[_nftAddressId].theAddress, _animalId, _exhibitId, counter);
        counter = counter + 1;
    }

    function withdraw (uint256 _tokenId) public {
        require(status, "Not started");
        require(msg.sender == ownerOf(_tokenId), "You do not own the token you are trying to withdraw");
        _transfer(msg.sender, address(this), _tokenId);
        exhibit.safeTransferFrom(address(this), msg.sender, pairing[_tokenId].exhibitId, 1, "");
        IERC721(pairing[_tokenId].nft).transferFrom(address(this), msg.sender, pairing[_tokenId].animalId);
    }

    /*
        Tier Functions
    */

    function tier(uint256 _tokenId)  external view returns (uint256) {
        return pairing[_tokenId].tier;
    }

    function _tierOfExhibit(uint256 _id)  internal pure returns (uint256) {
        if (_id < 5) {
            return 1;
        }
        if (_id < 9 && _id > 4) {
            return 2;
        }
        if (_id < 13 && _id > 8) {
            return 3;
        }
        if (_id < 17 && _id > 12) {
            return 4;
        }
        if (_id < 21 && _id > 16) {
            return 5;
        }
            return 0;
    }
    
    /*
        Uri Functions
    */

    function tokenURI(uint256 _tokenId)  public view virtual override returns (string memory) {
        require (_tokenId < 21, "nonexistent token");
        string memory base = baseURI();
        return string(abi.encodePacked(base, Strings.toString(_tokenId)));
    }

    function _setBaseURI(string memory baseURI_) public onlyOwner {
        URI = baseURI_;
    }
    
    function baseURI() internal virtual view returns (string memory) {
        return URI;
    }

    /*
        Owner Functions
    */

    function setStatus (bool  _newStatus) public onlyOwner {
        status = _newStatus;
    }

    function supportNewContract (uint256 _addressId, address _nftAddress, uint256 _tier) public onlyOwner {
        nftAddressParing[_addressId] = tierSystem(_nftAddress, _tier);
    }

}
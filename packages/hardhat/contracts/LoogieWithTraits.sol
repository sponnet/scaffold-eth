pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import 'base64-sol/base64.sol';
import "./ILoogieTrait.sol";
import './HexStrings.sol';
import './ToColor.sol';
import './YourCollectible.sol';

contract LoogieWithTraits is ERC721, IERC721Receiver, Ownable {
    using SafeMath for uint256;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor(address baseLoogiesContractAddress) public ERC721("Loogies With Traits", "LOOGWT") {
    baseLoogies = YourCollectible(baseLoogiesContractAddress);
  }
    YourCollectible public baseLoogies;

  // tokenId --> array of Traits
  mapping(uint256 => ILoogieTrait[]) LoogieTraits;

  using Strings for uint256;
  using HexStrings for uint160;
  using ToColor for bytes3;

  function registerTrait(uint256 tokenId, ILoogieTrait trait) public {
        require(ownerOf(tokenId) == msg.sender, "Not yours");
        LoogieTraits[tokenId].push(trait);
  }

  function unWrap(uint tokenId) public {
    require(ownerOf(tokenId) == msg.sender, "Not yours");
    baseLoogies.safeTransferFrom(address(this),msg.sender,tokenId);
    delete LoogieTraits[tokenId];
    _burn(tokenId);
  }


  function mintItem(uint256 tokenId)
      public
      returns (uint256)
  {
    require(baseLoogies.ownerOf(tokenId) == msg.sender, "Not yours");

    baseLoogies.safeTransferFrom(msg.sender, address(this),tokenId);
    _mint(msg.sender,tokenId);
   
  }

  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4){
    return this.onERC721Received.selector;
  }


function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    string memory ab = new string(_ba.length + _bb.length);
    bytes memory bab = bytes(ab);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
    return string(bab);
}

  function generateSVGofTokenById(address owner, uint256 tokenId, bytes3 color, uint256 chubbiness) internal view returns (string memory) {
    string memory traitsSVG = "";

    for (uint i=0;i<LoogieTraits[tokenId].length;i++){
        // traitsSVG = strConcat(traitsSVG,LoogieTraits[tokenId][i].generateSVG(baseLoogies.color(tokenId),baseLoogies.chubbiness(tokenId)));
        traitsSVG = strConcat(traitsSVG,LoogieTraits[tokenId][i].generateSVG(address(this),tokenId));
    }


    string memory svg = string(abi.encodePacked(
      '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
        '<g id="eye1">',
          '<ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_1" cy="154.5" cx="181.5" stroke="#000" fill="#fff"/>',
          '<ellipse ry="3.5" rx="2.5" id="svg_3" cy="154.5" cx="173.5" stroke-width="3" stroke="#000" fill="#000000"/>',
        '</g>',
        '<g id="head">',
          '<ellipse fill="#',
          color.toColor(),
          '" stroke-width="3" cx="204.5" cy="211.80065" id="svg_5" rx="',
          chubbiness.toString(),
          '" ry="51.80065" stroke="#000"/>',
        '</g>',
        '<g id="eye2">',
          '<ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_2" cy="168.5" cx="209.5" stroke="#000" fill="#fff"/>',
          '<ellipse ry="3.5" rx="3" id="svg_4" cy="169.5" cx="208" stroke-width="3" fill="#000000" stroke="#000"/>',
        '</g>',
        traitsSVG,
      '</svg>'
    ));

    return svg;
  }


  function tokenURI(uint256 id) public view override returns (string memory) {
      require(baseLoogies.ownerOf(id) != address(0x0), "not exist");
      return _tokenURI( baseLoogies.ownerOf(id), id, baseLoogies.color(id), baseLoogies.chubbiness(id) );
  }

  function _tokenURI(address owner, uint256 tokenId, bytes3 color, uint256 chubbiness) internal view returns (string memory) {

      string memory name = string(abi.encodePacked('Loogie #',tokenId.toString()));
      string memory description = string(abi.encodePacked('This Loogie is the color #',color.toColor(),' with a chubbiness of ',uint2str(chubbiness),'!!!'));
      string memory image = Base64.encode(bytes(generateSVGofTokenById(owner, tokenId, color, chubbiness)));

    string memory traitsAttributes = "";

    for (uint i=0;i<LoogieTraits[tokenId].length;i++){
        traitsAttributes = strConcat(traitsAttributes,'{"value":"');
        traitsAttributes = strConcat(traitsAttributes,LoogieTraits[tokenId][i].getDescription());
        traitsAttributes = strConcat(traitsAttributes,'"}');
    }

      return
          string(
              abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                          abi.encodePacked(
                              '{"name":"',
                              name,
                              '", "description":"',
                              description,
                              '", "external_url":"https://loogieslife.io/token/',
                              tokenId.toString(),
                              '", "attributes": [{"trait_type": "color", "value": "#',
                              color.toColor(),
                              '"},{"trait_type": "chubbiness", "value": ',
                              uint2str(chubbiness),
                              '}',
                              traitsAttributes,
                              '],',
                              '"image": "',
                              'data:image/svg+xml;base64,',
                              image,
                              '"}'
                          )
                        )
                    )
              )
          );
  }

  function uint2str(uint _i) public pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }


}

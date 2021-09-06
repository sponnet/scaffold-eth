//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILoogieTrait {
  function getDescription() external pure returns (string memory);
  function generateSVG(address loogieWithTraits,uint256 tokenId) external view returns (string memory);
}

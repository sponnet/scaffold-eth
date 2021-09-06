pragma solidity >=0.6.0 <0.7.0;

import "../ILoogieTrait.sol";
import "../LoogieWithTraits.sol";

contract Arms is ILoogieTrait {

  function getDescription() external pure override returns(string memory){
    return('Arms');
  }

  function generateSVG(address /*loogieWithTraits*/,uint256 /*tokenId*/) external view override returns (string memory) {
    string memory svg = string(abi.encodePacked(
'<g id="arms" transform="translate(0,-120)">',
'<path style="stroke: rgb(0, 0, 0); fill: none; stroke-width: 4px;" d="M 237.046 332.964 C 244.356 343.223 260.95 367.755 246.145 386.958"></path>',
'<path style="stroke: rgb(0, 0, 0); fill: none; stroke-width: 4px;" d="M 255.73 367.02"></path>',
'<path style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 254.488 376.749"></path>',
'<path style="stroke: rgb(0, 0, 0); fill: none; stroke-width: 4px;" d="M 248.117 385.982 C 250.464 390.075 248.387 391.623 246.944 396.11"></path>',
'<path style="stroke: rgb(0, 0, 0); fill: none; stroke-width: 4px;" d="M 247.121 383.943 C 246.516 386.072 243.179 384.001 240.749 392.7" transform="matrix(1, 0, 0, 1, -0.239464, 1.874669)"></path>',
'</g>'));

    return svg;
  }

}


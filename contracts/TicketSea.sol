// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./Base64.sol";

contract TicketSea is ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _idCounter;
    uint256 public maxSupply;
    address public eventOwner;
    string public eventName;
    string public refCod; 

    // constructor
    constructor(
        uint256 _maxSupply,
        string memory _eventName,
        string memory _refCod
    ) ERC721("TicketSea", "TSA") {
        eventOwner = msg.sender;
        maxSupply = _maxSupply;
        eventName = _eventName;
        refCod = _refCod;
    }

    // mint
    function mint() public {
        uint256 current = _idCounter.current();
        require(current < maxSupply, "There are no Tickets left :(");

        _idCounter.increment();
        _safeMint(msg.sender, current);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://api.ticketSea.io/";
    }

    function _paramsURI() internal view returns (string memory) {
        string memory params;

        // Params are intentionally scoped to avoid Too Deep Stack error
        {
            params = string(
                abi.encodePacked(
                    "eventOwner",
                    eventOwner,
                    "&eventName=",
                    eventName,
                    "&ticketRefCod=",
                    refCod
                )
            );
        }

        return params;
    }

    function image() public view returns (string memory) {
        string memory baseURI = _baseURI();
        string memory paramsURI = _paramsURI();

        return string(abi.encodePacked(baseURI, "?", paramsURI));
    }

    // tokenURI
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory image = image();

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"eventOwner": ',
                        eventOwner,
                        '", "eventName": ',
                        eventName,
                        '", "refCod": ',
                        refCod,
                        '", "maxSupply": ',
                        maxSupply.toString(),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Override required
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

}


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

    Counters.Counter private _idTicketCounter;
    Counters.Counter private _idEventCounter;
    uint256 public maxSupply;
    mapping(uint256 => TicketMetadata) public tokenMetadata;

    //TODO we cant set this properties like this. We must have a global data
    // so i need to create a mapping (tokenID, a struct tokenMetada)
    //TODO i need getters for my metadata

    // metadaStruct
    struct TicketMetadata {
        address eventOwner;
        string eventName;
        string refCod;
    }

    // constructor
    constructor(
        uint256 _maxSupply
    ) ERC721("TicketSea", "TSA") {
        maxSupply = _maxSupply;
    }

    // mint
    function mint(string memory eventName, string memory refCod) public {
        uint256 currentTicket = _idTicketCounter.current();
        require(currentTicket < maxSupply, "There are no Tickets left :(");

        TicketMetadata memory newTicketMetadata;
        newTicketMetadata.eventOwner = msg.sender;
        newTicketMetadata.eventName = eventName;
        newTicketMetadata.refCod = refCod;
        tokenMetadata[currentTicket] = newTicketMetadata;

        _idTicketCounter.increment();
        _safeMint(msg.sender, currentTicket);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://api.ticketSea.io/";
    }

    function _paramsURI(uint256 tokenId) internal view returns (string memory) {
        string memory params;

        // Params are intentionally scoped to avoid Too Deep Stack error
        {
            params = string(
                abi.encodePacked(
                    "eventOwner",
                    uint256(uint160(address(tokenMetadata[tokenId].eventOwner))).toString(),
                    //uint256(uint160(address(eventOwner))).toString(), // the owner address is in decimal format
                    "&eventName=",
                    tokenMetadata[tokenId].eventName,
                    //eventName,
                    "&ticketRefCod=",
                    tokenMetadata[tokenId].refCod
                    //refCod
                )
            );
        }

        return params;
    }
    function image(uint256 tokenId) public view returns (string memory) {
        string memory baseURI = _baseURI();
        string memory paramsURI = _paramsURI(tokenId);

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

        string memory image = image(tokenId);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"eventOwner": "',
                        uint256(uint160(address(tokenMetadata[tokenId].eventOwner))).toString(),
                        //uint256(uint160(address(eventOwner))).toString(), // the owner address is in decimal format
                        '", "eventName": "',
                        tokenMetadata[tokenId].eventName,
                        //eventName,
                        '", "refCod": "',
                        tokenMetadata[tokenId].refCod,
                        //refCod,
                        '", "maxSupply": "',
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


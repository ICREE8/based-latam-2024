// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract RVRental is ERC721 {
    // Struct to store information about each RV
    struct RV {
        uint256 rvId;
        string name;
        string description;
        uint256 rentalPricePerHour;
        bool isAvailable;
        address owner;
    }

    // Mapping to store RV information using their IDs
    mapping(uint256 => RV) public rvMap;

    // Counter to keep track of the total number of RVs
    uint256 public numberOfRVs = 0;

    // Constructor to initialize the ERC721 contract with a name and symbol
    constructor() ERC721("RVRentalNFT", "RVNFT") {}


    // Function to create a new RV
    function createRV(
        string memory _name,
        string memory _description,
        uint256 _rentalPricePerHour
    ) public {
        // Ensure rental price is greater than 0
        require(_rentalPricePerHour > 0, "Rental price must be greater than 0");

        // Increment the RV counter
        numberOfRVs++;

        // Create a new RV struct and store it in the mapping
        rvMap[numberOfRVs] = RV({
            rvId: numberOfRVs,
            name: _name,
            description: _description,
            rentalPricePerHour: _rentalPricePerHour,
            isAvailable: true,
            owner: msg.sender
        });

        // Mint an NFT representing the RV ownership
        _safeMint(msg.sender, numberOfRVs);
    }

    // Function to rent an RV
    function rentRV(uint256 _rvId, uint256 _rentalHours) public payable {
        // Get the RV details from the mapping
        RV storage rv = rvMap[_rvId];

        // Ensure the RV is available
        require(rv.isAvailable, "RV is not available for rent");

        // Calculate the total rental cost
        uint256 totalCost = rv.rentalPricePerHour * _rentalHours;

        // Ensure sufficient funds are provided
        require(msg.value >= totalCost, "Insufficient funds to rent RV");

        // Transfer the rental fee to the RV owner
        payable(rv.owner).transfer(totalCost);

        // Update the RV availability status
        rv.isAvailable = false;

        // Burn the NFT representing the RV ownership to signify rental
        _burn(_rvId);
    }

    // Function to return a rented RV
    function returnRV(uint256 _rvId) public {
        // Get the RV details from the mapping
        RV storage rv = rvMap[_rvId];

        // Ensure the RV is not currently rented
        require(!rv.isAvailable, "RV is not currently rented");

        // Update the RV availability status
        rv.isAvailable = true;

        // Mint a new NFT representing the RV ownership
        _safeMint(rv.owner, _rvId);
    }

    
// Function to get all the available RVs
    function getAvailableRVs() public view returns (RV[] memory) {
        // Create an array to store available RVs
        RV[] memory availableRVs = new RV[](numberOfRVs);
        uint256 availableCount = 0;

        // Iterate through the RVMap and populate the array with available RVs
        for (uint256 i = 1; i <= numberOfRVs; i++) {
            if (rvMap[i].isAvailable) {
                availableRVs[availableCount] = rvMap[i];
                availableCount++;
            }
        }

        // Resize the array to match the actual number of available RVs
        RV[] memory resizedAvailableRVs = new RV[](availableCount);
        for (uint256 i = 0; i < availableCount; i++) {
            resizedAvailableRVs[i] = availableRVs[i];
        }

        return resizedAvailableRVs;
    }
}

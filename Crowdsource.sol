pragma solidity 0.8.10;

contract Crowdsource {

    struct Campaign{
        string title;
        string description;
        string imgUrl;
        address user;
        uint256 deadline;
        uint256 balance;
        bool isLive;
    }

    event campignStarted(bytes32 campaignID,address user);
    event campignEnded(bytes32 campignID,address user);
    event fundsDonated(address user, uint256 amount, bytes32 campignID);
    event fundsWithdrawn(address user, uint256 amount, bytes32 campignID);

    mapping(bytes32=>Campign) _campings;
    mapping(uint256=>bytes32) _campingsList;
    mapping (address=>mapping(bytes32=>uint256)) userCampignDonation;

    uint256 private campaignCount;

    function startCampign(string title,
                        string calldata description,
                        uint256 calldata deadline,
                        string calldata imgUrl,
                        uint256 deadline) 
                        public {

            bytes32 campaignID=generateCampignId(msg.sender,title,description);

            Campign storage campign=_campaigns[campaignID];

            //require that campign is not live yet
            require(!campign.isLive,"campign exists");

            require(block.timestamp < deadline, "campign ended");

            campign.title=title;
            campaign.description=description;
            campign.imgUrl=imgUrl;
            campign.user=msg.sender;
            campign.deadline=deadline;
            campign.isLive=true;

            _campingsList[campingCount]=campignID;
            campignCount=campignCount + 1;

            emit campaignStarted(campignID,msg.sender);


    }

    function generateCampingnId(address user,
                                string calldata title, 
                                string calldata description) 
                            public pure returns(bytes32){

                            bytes32 CampignId=keccak256(abi.encodePacked(title,description,user););

                            return CampignId;



    }

    function endCampign(bytes32 campignID) public {

        Campign storage campign=_campigns[campignID]

        require(msg.sender == campign.user,"He doesn't start the campign");

        require(campign.isLive,"Not ended");
        campign.isLive=false;
        //saving the end time
        campign.deadline=block.timestamp;
        emit campignEnded(campignID,user);
    }

    function donateToCampign(bytes32 campignID) public {

        Campign storage campign= _campigns[campignID];

        require(block.timestamp < campign.deadline,"campign ended");

        require(msg.value > 0,"can't donate 0 ETH");

        campign.balance += msg.value;

        //Track record of user donations
        userCampignDonation[msg.sender][campingID]+= msg.value;

        emit fundsDonated(msg.sender,msg.value,campignID);

    }

    function withdrawCampignFunds(bytes32 campignID) public{

        Campign storage campign=_campigns[campignID];

        require(msg.sender == campign.user,"you are not a owner");

        require(campign.isLive == false,"campign is not ended");

        uint256 amountToWithdraw=campign.balance;

        campign.balance=0;

        payable(campign.user).send(amountToWithdraw);

        //address(msg.sender).send(msg.value);

        emit fundsWithdrawn(campign.user, amountToWithdraw, campignID);

    }

    
}
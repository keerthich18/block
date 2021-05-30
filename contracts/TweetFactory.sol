// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract TweetFactory {
    event TweetAdded(uint tweetId, string message, string author);
    event TweetUpdated(uint tweetId, string message, string author);
    event TweetDeleted(uint oldTweetId);

    struct Tweet {
        uint id;
        string message;
        string author;
    }

    mapping(uint => Tweet) public tweets;
    uint nextTweetId = 1;
    uint tweetCount = 0;

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function requireValidTweetId(uint id) public view {
        require(nextTweetId > id, "Tweeter Id invalid");
    }

    function createTweet(string memory _message, string memory _author) public {
        uint id = nextTweetId++;
        tweets[id] = Tweet(id, _message, _author);
        tweetCount++;
        emit TweetAdded(id, _message, _author);
    }

    function getTweet(uint id) public view returns (Tweet memory) {
        requireValidTweetId(id);
        Tweet memory retrievedTweet = tweets[id];
        require(retrievedTweet.id > 0, "Tweet Deleted");
        return retrievedTweet;
    }


    function getTweets() public view returns (Tweet[] memory) {
        Tweet[] memory timeline = new Tweet[](tweetCount);
        uint idx = 0;

        for(uint i = nextTweetId - 1; i > 0; i--) {
            Tweet memory curTweet = tweets[i];

            // Means it's not deleted
            if (curTweet.id != 0) {
                timeline[idx++] = curTweet;
            }
        }

        return timeline;
    }

    function deleteTweet(uint id, string memory _author) public {
       requireValidTweetId(id);
        Tweet memory retrievedTweet = tweets[id];
        require(compareStrings(retrievedTweet.author, _author), "Premission denied..! Please identify yourself before accessing this option");
        delete tweets[id];
        tweetCount--;
        emit TweetDeleted(id);
    }

    function updateTweet(uint id, string memory _message, string memory _author) public {
        requireValidTweetId(id);
        Tweet memory oldTweet = tweets[id];
        require(compareStrings(oldTweet.author, _author), "Tweet update premission dined because your not a owner");
        Tweet memory newTweet = Tweet(id, _message, _author);
        tweets[id] = newTweet;
        emit TweetUpdated(id, _message, _author);
    }
}
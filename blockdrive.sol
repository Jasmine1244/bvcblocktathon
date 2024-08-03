// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlockDrive {
    address public owner;

    struct Document {
        uint256 id;
        string name;
        string fileHash; // IPFS or other hash of the document
        address uploader;
        bool exists;
    }

    mapping(uint256 => Document) public documents;
    mapping(address => uint256[]) public userDocuments;
    uint256 public documentCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function uploadDocument(string memory _name, string memory _fileHash) public returns (uint256) {
        documentCount++;
        documents[documentCount] = Document({
            id: documentCount,
            name: _name,
            fileHash: _fileHash,
            uploader: msg.sender,
            exists: true
        });
        
        userDocuments[msg.sender].push(documentCount);

        return documentCount;
    }

    function getDocument(uint256 _id) public view returns (string memory name, string memory fileHash, address uploader) {
        require(documents[_id].exists, "Document does not exist");

        Document storage doc = documents[_id];
        return (doc.name, doc.fileHash, doc.uploader);
    }

    function transferDocument(uint256 _id, address _newOwner) public returns (bool) {
        require(documents[_id].exists, "Document does not exist");
        require(documents[_id].uploader == msg.sender, "Only the uploader can transfer the document");

        // Update document owner in the user's records
        removeDocumentFromUser(msg.sender, _id);
        userDocuments[_newOwner].push(_id);
        
        documents[_id].uploader = _newOwner;

        return true;
    }

    function removeDocumentFromUser(address _user, uint256 _id) internal {
        uint256[] storage userDocs = userDocuments[_user];
        for (uint i = 0; i < userDocs.length; i++) {
            if (userDocs[i] == _id) {
                userDocs[i] = userDocs[userDocs.length - 1];
                userDocs.pop();
                break;
            }
        }
    }

    function getUserDocuments(address _user) public view returns (uint256[] memory) {
        return userDocuments[_user];
    }
}

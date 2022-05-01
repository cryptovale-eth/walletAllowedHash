// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


/// @title A contract that provides functionalities to check values based on wallet addresses
/// @title with the purpose to be used for minting processes and avoid gas wars
/// @dev This can be used in conjunction with any function
/// @author cryptovale.eth
contract walletAllowedHash{
    struct Rule{
        uint16 maxValue;
        string salt;
    }

    mapping(string => Rule) rules;

    /// @dev Returns a modded sum value from 0 to the defined maxValue, that can be used to determine a day or a time
    /// @dev A salt can be added, to make values unique to a project
    function calculateHashvalue(address wallet, uint16 maxValue, string memory salt) public pure returns(uint16){
        bytes32 helper = bytes32(abi.encodePacked(wallet, salt));
        uint16 sum = 0;
        for (uint8 i=0; i<=31;i++){
            sum = uint8(bytes1(helper[i])) + sum;
        }
        return (sum % maxValue);
    }

    /// @dev Sets a rule that can be used to check in the modifier
    function setRule(string memory _ruleName, uint16 _maxValue, string memory _salt) public{
        rules[_ruleName] = Rule({
            maxValue:_maxValue,
            salt:_salt
        });
    }

    /// @dev Can be called to check if an address is allowed in the modifier, given the parameters
    function checkIfAllowed(address wallet, string memory ruleName, uint16 expectedValue) public view returns(bool){
        return calculateHashvalue(wallet, rules[ruleName].maxValue, rules[ruleName].salt)==expectedValue;
    }

    /// @dev Pass wallet and the index of the rule set to check the allowance
    modifier isAllowed(address wallet, string memory ruleName, uint16 expectedValue){
        require(checkIfAllowed(wallet,  ruleName, expectedValue), "Rule broken");
        _;
    }

}

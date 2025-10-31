// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract GenerateInput is Script {
    string constant FILE_PATH = "script/target/input.json";

    function run() public {
        string[] memory types = new string[](2);
        types[0] = "address";
        types[1] = "uint";

        uint256 amount = 2500 * 1e18;

        address[] memory whitelist = new address[](4);
        whitelist[0] = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;
        whitelist[1] = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B; // Example addresses
        whitelist[2] = 0x1Db3439a222C519ab44bb1144fC28167b4Fa6EE6;
        whitelist[3] = 0x0e466e7519A469f20168796a0807b758a2339791;

        string memory json = createJson(types, amount, whitelist);
        vm.writeFile(FILE_PATH, json);
    }

    function createJson(string[] memory _types, uint256 _amount, address[] memory _whitelist)
        internal
        pure
        returns (string memory)
    {
        string memory json = "{";

        // Types
        json = string.concat(json, "\"types\":[");
        for (uint256 i = 0; i < _types.length; i++) {
            json = string.concat(json, "\"", _types[i], "\"");
            if (i < _types.length - 1) {
                json = string.concat(json, ",");
            }
        }
        json = string.concat(json, "],");

        // Add count
        json = string.concat(json, "\"count\":", vm.toString(_whitelist.length), ",");

        // Add values

        json = string.concat(json, "\"values\": {");
        for (uint256 i = 0; i < _whitelist.length; i++) {
            json = string.concat(
                json,
                "\"",
                vm.toString(i),
                "\": {",
                "\"0\":\"",
                vm.toString(_whitelist[i]),
                "\",",
                "\"1\":\"",
                vm.toString(_amount),
                "\"}"
            );

            if (i < _whitelist.length - 1) {
                json = string.concat(json, ",");
            }
        }
        
        json = string.concat(json, "}}");

        return json;
    }
}

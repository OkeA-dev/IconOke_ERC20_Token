//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {IconToken} from "../src/IconToken.sol";
import {Script} from "forge-std/Script.sol";

contract DeployIconToken is Script {
    uint256 constant INITIAL_SUPPLY = 100 ether;

    function run() external returns (IconToken) {
        vm.startBroadcast();
        IconToken iconToken = new IconToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return iconToken;
    }
}
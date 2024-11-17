// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/script.sol";
import {VotingWithAttestations} from "../src/so.sol";

contract DeployerScript is Script {
    function setUp() public {
        // Initialization logic, if any, can go here
    }

    function run() public {
        vm.startBroadcast();

        // Deploy the VotingWithAttestations contract
        VotingWithAttestations voting = new VotingWithAttestations();
        console.log("Contract deployed at:", address(voting));

        vm.stopBroadcast();
    }
}

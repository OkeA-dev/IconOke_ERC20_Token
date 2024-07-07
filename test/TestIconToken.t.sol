//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {DeployIconToken} from "../script/DeployIconToken.s.sol";
import {IconToken} from "../src/IconToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";
import {Vm} from "forge-std/Vm.sol";

contract TestIconToken is Test {
    uint256 constant SEND_AMOUNT = 1 ether;
    uint256 constant ALLOWANCE_AMOUNT = 2 ether;

    DeployIconToken s_deployIconToken;
    IconToken s_iconToken;

    address Alice = makeAddr("alice");
    address Bob = makeAddr("bob");
    address zeroAddress = address(0);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() external {
        s_deployIconToken = new DeployIconToken();
        s_iconToken = s_deployIconToken.run();
    }

    /*//////////////////////////////////////////////////////////////
                           INITIALSUPPLY & BALANCEOF
    //////////////////////////////////////////////////////////////*/

    function testInitialSupply() public view {
        uint256 totalSupply = s_iconToken.totalSupply();
        assertEq(totalSupply, 100 ether);
        assertEq(s_iconToken.balanceOf(msg.sender), totalSupply);
    }

    /*//////////////////////////////////////////////////////////////
                           TRANSFER TESTS
    //////////////////////////////////////////////////////////////*/

    function testTransfer() public {
        // Transfer tokens between accounts
        vm.prank(msg.sender);
        s_iconToken.transfer(Alice, SEND_AMOUNT);

        // Transfer to the zero address (should fail)
        vm.expectRevert("Invalid Address");
        s_iconToken.transfer(zeroAddress, SEND_AMOUNT);

        // Transfer more tokens than balance (should fail)
        vm.expectRevert("Invalid Balance");
        s_iconToken.transfer(Alice, 1000 ether);

        // Transfer zero token
        s_iconToken.transfer(Alice, 0);

        assertEq(s_iconToken.balanceOf(Alice), SEND_AMOUNT);
    }

    /*//////////////////////////////////////////////////////////////
                           APPROVAL & TRANSFERFROM TESTS
    //////////////////////////////////////////////////////////////*/

    function testApprovalandTransfrom() public {
        //Approve spending
        vm.prank(msg.sender);
        s_iconToken.approve(Bob, ALLOWANCE_AMOUNT);

        // TransferFrom after approval
        vm.prank(Bob);
        s_iconToken.transferFrom(msg.sender, Bob, SEND_AMOUNT);

        //TransferFrom without approval (should fail);
        vm.prank(Alice);
        vm.expectRevert();
        s_iconToken.transferFrom(msg.sender, Alice, SEND_AMOUNT);

        // TransferFrom more than approved Amount (should fail)
        vm.prank(Bob);
        vm.expectRevert();
        s_iconToken.transferFrom(msg.sender, Bob, ALLOWANCE_AMOUNT);

        assertEq(s_iconToken.allowance(msg.sender, Bob), SEND_AMOUNT);
        assertEq(s_iconToken.balanceOf(Bob), SEND_AMOUNT);
    }

    /*//////////////////////////////////////////////////////////////
                           Event Emission
    //////////////////////////////////////////////////////////////*/

    function testEventEmission() public {
        vm.expectEmit(true, true, false, true, address(s_iconToken));
        emit Transfer(msg.sender, Alice, SEND_AMOUNT);
        vm.prank(msg.sender);
        s_iconToken.transfer(Alice, SEND_AMOUNT);
    }

    function testNoEventEmission() public {
        vm.recordLogs();

        s_iconToken.balanceOf(msg.sender);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 0, "No event should have been emitted");
    }

    function testTransferFromEmitsEvents() public {
        uint256 amount = 1 * 10**18;
        vm.prank(msg.sender);
        s_iconToken.approve(Bob, amount);
        

        vm.startPrank(Bob);
        vm.expectEmit(true, true, false, true);
        emit Transfer(msg.sender, Bob, amount);
        s_iconToken.transferFrom(msg.sender, Bob, amount);
        vm.stopPrank();
    }


}
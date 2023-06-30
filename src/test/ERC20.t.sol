pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../ERC20.sol";

// solhint-disable func-name-mixedcase

contract ERC20Harness is ERC20("", "") {

    function exposed_mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ERC20Test is Test {
    ERC20Harness _token;
    address _beef;
    address _feed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        _token = new ERC20Harness();
        _beef = address(0xbeef);
        _feed = address(0xfeed);
    }

    function test_totalSupply_initZero() public {
        assertEq(_token.totalSupply(), 0);
    }

    function test_totalSupply_increaseWithMint() public {
        assertEq(_token.totalSupply(), 0);
        _token.exposed_mint(_beef, 123);
        assertEq(_token.totalSupply(), 123);
    }

    function test_balanceOf_initZero() public {
        assertEq(_token.balanceOf(_beef), 0);
    }

    function test_balanceOf_increaseWithMint() public {
        assertEq(_token.balanceOf(_beef), 0);
        _token.exposed_mint(_beef, 123);
        assertEq(_token.balanceOf(_beef), 123);
    }

    function test_transfer_balancesChange() public {
        _token.exposed_mint(_beef, 123);
        assertEq(_token.balanceOf(_beef), 123);
        assertEq(_token.balanceOf(_feed), 0);
        
        vm.startPrank(_beef);
        _token.transfer(_feed, 23);
        assertEq(_token.balanceOf(_beef), 100);
        assertEq(_token.balanceOf(_feed), 23);
        
        _token.transfer(_feed, 100);
        assertEq(_token.balanceOf(_beef), 0);
        assertEq(_token.balanceOf(_feed), 123);
    }

    function test_transfer_zeroAllowed() public {
        _token.exposed_mint(_beef, 123);
        assertEq(_token.balanceOf(_beef), 123);
        assertEq(_token.balanceOf(_feed), 0);
        
        vm.prank(_beef);
        _token.transfer(_feed, 0);
        assertEq(_token.balanceOf(_beef), 123);
        assertEq(_token.balanceOf(_feed), 0);
    }

    function test_transfer_eventEmitted() public {
        _token.exposed_mint(_beef, 123);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_beef, _feed, 23);
        vm.startPrank(_beef);
        _token.transfer(_feed, 23);
    }

    function test_transfer_zeroAddressRevert() public {
        _token.exposed_mint(_beef, 123);
        vm.startPrank(_beef);
        vm.expectRevert("Transfer to zero address");
        _token.transfer(address(0), 23);
    }

    function test_transfer_insufficientFunds() public {
        _token.exposed_mint(_beef, 123);
        vm.expectRevert("Insufficient funds");
        _token.transfer(_feed, 124);
    }

    function test_transfer_successReturnsTrue() public {
        _token.exposed_mint(_beef, 123);
        vm.startPrank(_beef);
        bool success = _token.transfer(_feed, 123);
        assertTrue(success);
    }

    // Maybe not necessary
    function test_transfer_failDoesntReturn() public {
        _token.exposed_mint(_beef, 123);
        vm.expectRevert("Insufficient funds");
        bool success = _token.transfer(_feed, 124);
        assertTrue(success == false);
    }
}
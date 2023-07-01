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

    function test_constructor_initNameSymbolSupply() public {
        ERC20 otherToken = new ERC20("blah", "BLA");

        assertEq(otherToken.name(), "blah");
        assertEq(otherToken.symbol(), "BLA");
        assertEq(otherToken.totalSupply(), 0);
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

    function test_transfer_zeroAmountAllowed() public {
        _token.exposed_mint(_beef, 123);

        assertEq(_token.balanceOf(_beef), 123);
        assertEq(_token.balanceOf(_feed), 0);
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(_beef, _feed, 0);

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

    function test_transfer_toZeroAddress() public {
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

    function test_allowance_initZero() public {
        assertEq(_token.allowance(_feed, _beef), 0);
    }

    function test_allowance_increaseWithApprove() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 23);
        assertEq(_token.allowance(_feed, _beef), 23);
    }

    function test_approve_senderZeroAddress() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        vm.expectRevert("Approval of zero address");
        _token.approve(address(0), 23);
    }

    function test_approve_ownerNotSpender() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        vm.expectRevert("Approval of owner as spender");
        _token.approve(_feed, 23);
    }

    function test_approve_allowanceIncreases() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 23);
        assertEq(_token.allowance(_feed, _beef), 23);
    }

    function test_approve_allowanceMoreThanBalanceI() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 163);
        assertEq(_token.allowance(_feed, _beef), 163);

        vm.startPrank(_beef);
        _token.transferFrom(_feed, address(1967), 60);
        assertEq(_token.allowance(_feed, _beef), 103);
        assertEq(_token.balanceOf(address(1967)), 60);
        assertEq(_token.balanceOf(_feed), 63);
    }

    function test_approve_allowanceMoreThanBalanceII() public {
        vm.startPrank(_feed);
        _token.approve(_beef, 163);
        assertEq(_token.allowance(_feed, _beef), 163);

        _token.exposed_mint(_feed, 123);

        vm.startPrank(_beef);
        _token.transferFrom(_feed, address(1967), 60);
        assertEq(_token.allowance(_feed, _beef), 103);
        assertEq(_token.balanceOf(address(1967)), 60);
        assertEq(_token.balanceOf(_feed), 63);
    }

    function test_approve_allowanceOverride() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 163);
        assertEq(_token.allowance(_feed, _beef), 163);

        _token.approve(_beef, 23);
        assertEq(_token.allowance(_feed, _beef), 23);
    }

    function test_approve_eventEmitted() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        vm.expectEmit(true, true, false, true);
        emit Approval(_feed, _beef, 123);
        _token.approve(_beef, 123);
    }

    function test_transferFrom_noApproval() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_beef);
        vm.expectRevert("Insufficient allowance");
        _token.transferFrom(_feed, address(1967), 23);
    }

    function test_transferFrom_insufficientAllowance() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 23);
        assertEq(_token.allowance(_feed, _beef), 23);

        vm.startPrank(_beef);
        vm.expectRevert("Insufficient allowance");
        _token.transferFrom(_feed, address(1967), 24);
    }

    function test_transferFrom_insufficientFunds() public {
        _token.exposed_mint(_feed, 23);

        vm.startPrank(_feed);
        _token.approve(_beef, 123);
        assertEq(_token.allowance(_feed, _beef), 123);

        vm.startPrank(_beef);
        vm.expectRevert("Insufficient funds");
        _token.transferFrom(_feed, address(1967), 24);
    }

    function test_transferFrom_toZeroAddress() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 123);
        assertEq(_token.allowance(_feed, _beef), 123);

        vm.startPrank(_beef);
        vm.expectRevert("Transfer to zero address");
        _token.transferFrom(_feed, address(0), 23);
    }

    function test_transferFrom_balanceAllowanceChanges() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 143);
        assertEq(_token.allowance(_feed, _beef), 143);

        vm.startPrank(_beef);
        _token.transferFrom(_feed, address(1967), 23);
        assertEq(_token.allowance(_feed, _beef), 120);
        assertEq(_token.balanceOf(_feed), 100);
        assertEq(_token.balanceOf(address(1967)), 23);

        _token.transferFrom(_feed, address(1967), 20);
        assertEq(_token.allowance(_feed, _beef), 100);
        assertEq(_token.balanceOf(_feed), 80);
        assertEq(_token.balanceOf(address(1967)), 43);

        vm.startPrank(_feed);
        address _beef2 = address(0xbef0);
        _token.approve(_beef2, 20);
        assertEq(_token.allowance(_feed, _beef2), 20);

        vm.startPrank(_beef2);
        _token.transferFrom(_feed, address(1967), 20);
        assertEq(_token.allowance(_feed, _beef2), 0);
        assertEq(_token.balanceOf(_feed), 60);
        assertEq(_token.balanceOf(address(1967)), 63);
    }

    function test_transferFrom_allowanceSpent() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 123);
        assertEq(_token.allowance(_feed, _beef), 123);

        vm.startPrank(_beef);
        _token.transferFrom(_feed, address(1967), 123);
        assertEq(_token.allowance(_feed, _beef), 0);
        assertEq(_token.balanceOf(_feed), 0);
        assertEq(_token.balanceOf(address(1967)), 123);

        vm.expectRevert("Insufficient allowance");
        _token.transferFrom(_feed, address(1967), 20);
        assertEq(_token.allowance(_feed, _beef), 0);
        assertEq(_token.balanceOf(_feed), 0);
        assertEq(_token.balanceOf(address(1967)), 123);
    }

    function test_transferFrom_eventEmitted() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 123);
        assertEq(_token.allowance(_feed, _beef), 123);

        vm.startPrank(_beef);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_feed, address(1967), 123);
        _token.transferFrom(_feed, address(1967), 123);
    }

    function test_transferFrom_successReturnsTrue() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);
        _token.approve(_beef, 123);
        assertEq(_token.allowance(_feed, _beef), 123);

        vm.startPrank(_beef);
        bool success = _token.transferFrom(_feed, address(1967), 23);
        assertTrue(success);
    }

    function test_name_isName() public {
        assertEq(_token.name(), "");

        ERC20 otherToken = new ERC20("BasicToken", "BTX");
        assertEq(otherToken.name(), "BasicToken");
    }

    function test_symbol_isSymbol() public {
        assertEq(_token.symbol(), "");

        ERC20 otherToken = new ERC20("BasicToken", "BTX");
        assertEq(otherToken.symbol(), "BTX");
    }

    function test_mint_toZeroAddress() public {
        vm.expectRevert("Transfer to zero address");
        _token.exposed_mint(address(0), 123);
    }

    function test_mint_balanceSupplyChanges() public {
        _token.exposed_mint(_beef, 123);
        assertEq(_token.totalSupply(), 123);
        assertEq(_token.balanceOf(_beef), 123);
    }

    function test_mint_eventEmitted() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), _beef, 123);
        _token.exposed_mint(_beef, 123);
    }

    function testFuzz_constructor(string memory name, string memory symbol) public {
        ERC20 otherToken = new ERC20(name, symbol);

        assertEq(otherToken.name(), name);
        assertEq(otherToken.symbol(), symbol);
        assertEq(otherToken.totalSupply(), 0);
    }

    function testFuzz_totalSupply_increaseWithMint(uint256 amount) public {
        assertEq(_token.totalSupply(), 0);
        _token.exposed_mint(_beef, amount);
        assertEq(_token.totalSupply(), amount);
    }

    function testFuzz_balanceOf_increaseWithMint(uint256 amount) public {
        assertEq(_token.balanceOf(_beef), 0);
        _token.exposed_mint(_beef, amount);
        assertEq(_token.balanceOf(_beef), amount);
    }

    function testFuzz_transfer_wholistic(address beef, address feed, uint256 mintAmount, uint256 sendAmount) public {
        if (beef == address(0)) {
            vm.expectRevert("Transfer to zero address");
            _token.exposed_mint(beef, mintAmount);
            assertEq(_token.balanceOf(beef), 0);
            assertEq(_token.balanceOf(feed), 0);
        } else {
            _token.exposed_mint(beef, mintAmount);
            assertEq(_token.balanceOf(beef), mintAmount);
            assertEq(_token.balanceOf(feed), 0);
        }
        
        vm.startPrank(beef);
        
        if (sendAmount > _token.balanceOf(beef)) {
            vm.expectRevert("Insufficient funds");
            _token.transfer(feed, sendAmount);
        } else if (feed == address(0)) {
            vm.expectRevert("Transfer to zero address");
            _token.transfer(feed, sendAmount);
        } else {
            vm.expectEmit(true, true, false, true);
            emit Transfer(beef, feed, sendAmount);
            bool success = _token.transfer(feed, sendAmount);
            assertEq(_token.balanceOf(beef), mintAmount - sendAmount);
            assertEq(_token.balanceOf(feed), sendAmount);
            assertTrue(success);
        }
    }
}
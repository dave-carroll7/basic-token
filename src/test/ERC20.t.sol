pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
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
    }

    function test_totalSupply_initZero() public {
        assertEq(_token.totalSupply(), 0);
    }

    function test_totalSupply_increaseWithMint() public {
        _token.exposed_mint(_beef, 123);

        assertEq(_token.totalSupply(), 123);
    }

    function test_balanceOf_initZero() public {
        assertEq(_token.balanceOf(_beef), 0);
    }

    function test_balanceOf_increaseWithMint() public {
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

        vm.prank(_beef);

        _token.transfer(_feed, 0);
        assertEq(_token.balanceOf(_beef), 123);
        assertEq(_token.balanceOf(_feed), 0);
    }

    function test_transfer_eventEmitted() public {
        _token.exposed_mint(_beef, 123);
        
        vm.startPrank(_beef);

        vm.expectEmit(true, true, false, true);
        emit Transfer(_beef, _feed, 23);
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

        vm.startPrank(_beef);

        vm.expectRevert("Insufficient funds");
        _token.transfer(_feed, 124);
    }

    function test_transfer_successReturnsTrue() public {
        _token.exposed_mint(_beef, 123);

        vm.startPrank(_beef);

        bool success = _token.transfer(_feed, 123);
        assertTrue(success);
    }

    function test_transfer_failReturnsFalse() public {
        _token.exposed_mint(_beef, 123);

        vm.startPrank(_beef);

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

    function test_allowance_decreaseWithTransferFrom() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 23);

        vm.startPrank(_beef);

        _token.transferFrom(_feed, address(1967), 23);
        assertEq(_token.allowance(_feed, _beef), 0);
    }

    function test_allowance_updateWithApprove() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 163);
        assertEq(_token.allowance(_feed, _beef), 163);

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

    function test_approve_allowanceDecreasesWithTransferFrom() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 163);

        vm.startPrank(_beef);

        _token.transferFrom(_feed, address(1967), 60);
        assertEq(_token.allowance(_feed, _beef), 103);
    }

    function test_approve_aproveBeforeMint() public {
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

    function test_approve_eventEmitted() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        vm.expectEmit(true, true, false, true);
        emit Approval(_feed, _beef, 123);
        _token.approve(_beef, 123);
    }

    function test_approve_successReturnsTrue() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        bool success = _token.approve(_beef, 123);
        assertTrue(success);
    }

    function test_approve_failReturnsFalse() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        vm.expectRevert("Approval of zero address");
        bool success = _token.approve(address(0), 123);
        assertTrue(success == false);
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

        vm.startPrank(_beef);

        vm.expectRevert("Insufficient allowance");
        _token.transferFrom(_feed, address(1967), 24);
    }

    function test_transferFrom_insufficientFunds() public {
        _token.exposed_mint(_feed, 23);

        vm.startPrank(_feed);

        _token.approve(_beef, 123);

        vm.startPrank(_beef);

        vm.expectRevert("Insufficient funds");
        _token.transferFrom(_feed, address(1967), 24);
    }

    function test_transferFrom_toZeroAddress() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 123);

        vm.startPrank(_beef);

        vm.expectRevert("Transfer to zero address");
        _token.transferFrom(_feed, address(0), 23);
    }

    function test_transferFrom_balanceAllowanceChanges() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 143);

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

        vm.startPrank(_beef2);

        _token.transferFrom(_feed, address(1967), 20);
        assertEq(_token.allowance(_feed, _beef2), 0);
        assertEq(_token.balanceOf(_feed), 60);
        assertEq(_token.balanceOf(address(1967)), 63);
    }

    function test_transferFrom_allowanceSpent() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 100);

        vm.startPrank(_beef);

        _token.transferFrom(_feed, address(1967), 100);
        assertEq(_token.allowance(_feed, _beef), 0);
        assertEq(_token.balanceOf(_feed), 23);
        assertEq(_token.balanceOf(address(1967)), 100);

        vm.expectRevert("Insufficient allowance");
        _token.transferFrom(_feed, address(1967), 23);
        assertEq(_token.allowance(_feed, _beef), 0);
        assertEq(_token.balanceOf(_feed), 23);
        assertEq(_token.balanceOf(address(1967)), 100);
    }

    function test_transferFrom_allowanceUpdate() public {
        _token.exposed_mint(_feed, 123);
        
        vm.startPrank(_feed);

        _token.approve(_beef, 123);
        _token.approve(_beef, 100);
        assertEq(_token.allowance(_feed, _beef), 100);

        vm.startPrank(_beef);

        vm.expectRevert("Insufficient allowance");
        _token.transferFrom(_feed, address(1967), 123);
    }

    function test_transferFrom_eventEmitted() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 123);

        vm.startPrank(_beef);

        vm.expectEmit(true, true, false, true);
        emit Transfer(_feed, address(1967), 123);
        _token.transferFrom(_feed, address(1967), 123);
    }

    function test_transferFrom_successReturnsTrue() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 123);

        vm.startPrank(_beef);

        bool success = _token.transferFrom(_feed, address(1967), 23);
        assertTrue(success);
    }

    function test_transferFrom_failReturnsFalse() public {
        _token.exposed_mint(_feed, 123);

        vm.startPrank(_feed);

        _token.approve(_beef, 23);

        vm.startPrank(_beef);

        vm.expectRevert("Insufficient allowance");
        bool success = _token.transferFrom(_feed, address(1967), 24);
        assertTrue(success == false);
    }

    function test_name_isName() public {
        ERC20 otherToken = new ERC20("BasicToken", "BTX");
        assertEq(otherToken.name(), "BasicToken");
    }

    function test_symbol_isSymbol() public {
        ERC20 otherToken = new ERC20("BasicToken", "BTX");
        assertEq(otherToken.symbol(), "BTX");
    }

    function test_mint_toZeroAddress() public {
        vm.expectRevert("Transfer to zero address");
        _token.exposed_mint(address(0), 123);
    }

    function test_mint_supplyChanges() public {
        _token.exposed_mint(_beef, 123);
        assertEq(_token.totalSupply(), 123);
    }

    function test_mint_balanceChanges() public {
        _token.exposed_mint(_beef, 123);
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

    function testFuzz_totalSupply_increaseWithMint(address to, uint256 amount) public {
        vm.assume(to != address(0));

        _token.exposed_mint(to, amount);
        assertEq(_token.totalSupply(), amount);
    }

    function testFuzz_balanceOf_initZero(address to) public {
        assertEq(_token.balanceOf(to), 0);
    }

    function testFuzz_balanceOf_increaseWithMint(address to, uint256 amount) public {
        vm.assume(to != address(0));

        _token.exposed_mint(_beef, amount);
        assertEq(_token.balanceOf(_beef), amount);
    }

    function testFuzz_transfer_insufficientFunds(
        address owner, 
        address receiver, 
        uint256 mintAmount, 
        uint256 sendAmount
    ) 
        public 
    {
        vm.assume(owner != address(0));
        vm.assume(receiver != address(0));

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        if (sendAmount > mintAmount) {
            vm.expectRevert("Insufficient funds");
        }
        _token.transfer(receiver, sendAmount);
    }

    function testFuzz_transfer_toZeroAddress(
        address owner, 
        address receiver, 
        uint256 mintAmount, 
        uint256 sendAmount
    ) 
        public 
    {
        vm.assume(owner != address(0));
        vm.assume(mintAmount >= sendAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        if (receiver == address(0)) {
            vm.expectRevert("Transfer to zero address");
        }
        _token.transfer(receiver, sendAmount);
    }

    function testFuzz_transfer_balancesChange(
        address owner, 
        address receiver, 
        uint256 mintAmount, 
        uint256 sendAmount
    ) 
        public 
    {
        vm.assume(owner != address(0));
        vm.assume(receiver != address(0));
        vm.assume(mintAmount >= sendAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        _token.transfer(receiver, sendAmount);

        if (owner != receiver) {
            assertEq(_token.balanceOf(owner), mintAmount - sendAmount);
            assertEq(_token.balanceOf(receiver), sendAmount);

            if (mintAmount > sendAmount) {
                _token.transfer(receiver, mintAmount - sendAmount);
                assertEq(_token.balanceOf(owner), 0);
                assertEq(_token.balanceOf(receiver), mintAmount);
            }
        } else {
            assertEq(_token.balanceOf(owner), mintAmount);
            assertEq(_token.balanceOf(receiver), mintAmount);
        }
    }

    function testFuzz_transfer_eventEmitted(
        address owner, 
        address receiver, 
        uint256 mintAmount, 
        uint256 sendAmount
    ) 
        public 
    {
        vm.assume(owner != address(0));
        vm.assume(receiver != address(0));
        vm.assume(mintAmount >= sendAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, receiver, sendAmount);
        _token.transfer(receiver, sendAmount);
    }

    function testFuzz_transfer_entireFlow(
        address owner, 
        address receiver, 
        uint256 mintAmount, 
        uint256 sendAmount
    ) 
        public 
    {
        vm.assume(owner != address(0));

        _token.exposed_mint(owner, mintAmount);
        
        vm.startPrank(owner);
        
        if (sendAmount > mintAmount) {
            vm.expectRevert("Insufficient funds");
            bool success = _token.transfer(receiver, sendAmount);
            assertTrue(success == false);
        } else if (receiver == address(0)) {
            vm.expectRevert("Transfer to zero address");
            bool success = _token.transfer(receiver, sendAmount);
            assertTrue(success == false);
        } else {
            vm.expectEmit(true, true, true, true);
            emit Transfer(owner, receiver, sendAmount);
            bool success = _token.transfer(receiver, sendAmount);
            assertTrue(success);

            if (owner != receiver) {
                assertEq(_token.balanceOf(owner), mintAmount - sendAmount);
                assertEq(_token.balanceOf(receiver), sendAmount);
            } else {
                assertEq(_token.balanceOf(owner), mintAmount);
                assertEq(_token.balanceOf(receiver), mintAmount);
            }
        }
    }

    function testFuzz_allowance_initZero(address owner, address spender) public {
        assertEq(_token.allowance(owner, spender), 0);
    }

    function testFuzz_allowance_increaseWithApprove(address owner, address spender, uint256 amount) public {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(owner != spender);

        _token.exposed_mint(owner, amount);

        vm.startPrank(owner);

        _token.approve(spender, amount);
        assertEq(_token.allowance(owner, spender), amount);
    }

    function testFuzz_allowance_updateWithApprove(
        address owner, 
        address spender, 
        uint256 amount1, 
        uint256 amount2
    ) 
        public 
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(owner != spender);

        _token.exposed_mint(owner, amount1);

        vm.startPrank(owner);

        _token.approve(spender, amount1);
        assertEq(_token.allowance(owner, spender), amount1);

        _token.approve(spender, amount2);
        assertEq(_token.allowance(owner, spender), amount2);
    }

    function testFuzz_allowance_decreaseWithTransfer(
        address owner, 
        address spender, 
        address receiver, 
        uint256 amount
    ) 
    public 
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(receiver != address(0));
        vm.assume(owner != spender);

        _token.exposed_mint(owner, amount);

        vm.startPrank(owner);

        _token.approve(spender, amount);

        vm.startPrank(spender);

        _token.transferFrom(owner, receiver, amount);
        assertEq(_token.allowance(owner, spender), 0);
    }

    function testFuzz_approve_toZeroAddress(
        address owner, 
        address spender,
        uint256 amount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(owner != spender);

        _token.exposed_mint(owner, amount);

        vm.startPrank(owner);

        if (spender == address(0)) {
            vm.expectRevert("Approval of zero address");
        }
        _token.approve(spender, amount);
    }

    function testFuzz_approve_ownerNotSpender(
        address owner, 
        address spender,
        uint256 amount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));

        _token.exposed_mint(owner, amount);

        vm.startPrank(owner);

        if (owner == spender) {
            vm.expectRevert("Approval of owner as spender");
        }
        _token.approve(spender, amount);
    }

    function testFuzz_approve_allowanceIncreases(
        address owner, 
        address spender,
        uint256 amount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(owner != spender);

        _token.exposed_mint(owner, amount);

        vm.startPrank(owner);

        _token.approve(spender, amount);
        assertEq(_token.allowance(owner, spender), amount);
    }

    function testFuzz_approve_eventEmitted(
        address owner, 
        address spender,
        uint256 amount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(owner != spender);

        _token.exposed_mint(owner, amount);

        vm.startPrank(owner);

        vm.expectEmit(true, true, true, true);
        emit Approval(owner, spender, amount);
        _token.approve(spender, amount);
    }

    function testFuzz_transferFrom_insufficientAllowance(
        address owner, 
        address spender,
        address receiver,
        uint256 mintAmount,
        uint256 allowanceAmount,
        uint256 sendAmount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(receiver != address(0));
        vm.assume(owner != spender);
        vm.assume(mintAmount >= sendAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        _token.approve(spender, allowanceAmount);

        vm.startPrank(spender);

        if (sendAmount > allowanceAmount) {
            vm.expectRevert("Insufficient allowance");
        }
        _token.transferFrom(owner, receiver, sendAmount);
    }

    function testFuzz_transferFrom_insufficientFunds(
        address owner, 
        address spender,
        address receiver,
        uint256 mintAmount,
        uint256 allowanceAmount,
        uint256 sendAmount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(receiver != address(0));
        vm.assume(owner != spender);
        vm.assume(allowanceAmount >= sendAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        _token.approve(spender, allowanceAmount);

        vm.startPrank(spender);

        if (sendAmount > mintAmount) {
            vm.expectRevert("Insufficient funds");
        }
        _token.transferFrom(owner, receiver, sendAmount);
    }

    function testFuzz_transferFrom_toZeroAddress(
        address owner, 
        address spender,
        address receiver,
        uint256 mintAmount,
        uint256 allowanceAmount,
        uint256 sendAmount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(owner != spender);
        vm.assume(mintAmount >= sendAmount);
        vm.assume(allowanceAmount >= sendAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        _token.approve(spender, allowanceAmount);

        vm.startPrank(spender);

        if (receiver == address(0)) {
            vm.expectRevert("Transfer to zero address");
        }
        _token.transferFrom(owner, receiver, sendAmount);
    }

    function testFuzz_transferFrom_balanceAllowanceChanges(
        address owner, 
        address spender,
        address receiver,
        uint256 mintAmount,
        uint256 allowanceAmount,
        uint256 sendAmount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(receiver != address(0));
        vm.assume(owner != spender);
        vm.assume(mintAmount >= sendAmount);
        vm.assume(allowanceAmount >= sendAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(owner);

        _token.approve(spender, allowanceAmount);

        vm.startPrank(spender);

        _token.transferFrom(owner, receiver, sendAmount);

        if (owner != receiver) {
            assertEq(_token.balanceOf(owner), mintAmount - sendAmount);
            assertEq(_token.balanceOf(receiver), sendAmount);
        } else {
            assertEq(_token.balanceOf(owner), mintAmount);
            assertEq(_token.balanceOf(receiver), mintAmount);
        }

        assertEq(_token.allowance(owner, spender), allowanceAmount - sendAmount);
    }

    function testFuzz_transferFrom_approveBeforeMint(
        address owner, 
        address spender,
        address receiver,
        uint256 mintAmount,
        uint256 allowanceAmount,
        uint256 sendAmount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(receiver != address(0));
        vm.assume(owner != spender);
        vm.assume(mintAmount >= sendAmount);
        vm.assume(allowanceAmount >= sendAmount);
        
        vm.startPrank(owner);

        _token.approve(spender, allowanceAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(spender);

        _token.transferFrom(owner, receiver, sendAmount);

        if (owner != receiver) {
            assertEq(_token.balanceOf(owner), mintAmount - sendAmount);
            assertEq(_token.balanceOf(receiver), sendAmount);
        } else {
            assertEq(_token.balanceOf(owner), mintAmount);
            assertEq(_token.balanceOf(receiver), mintAmount);
        }

        assertEq(_token.allowance(owner, spender), allowanceAmount - sendAmount);
    }

    function testFuzz_transferFrom_allowanceUpdate(
        address owner, 
        address spender,
        address receiver,
        uint256 mintAmount,
        uint256 allowanceAmount1,
        uint256 allowanceAmount2
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(receiver != address(0));
        vm.assume(owner != spender);
        vm.assume(mintAmount >= allowanceAmount1);
        vm.assume(mintAmount >= allowanceAmount2);

        _token.exposed_mint(owner, mintAmount);
        
        vm.startPrank(owner);

        _token.approve(spender, allowanceAmount1);
        _token.approve(spender, allowanceAmount2);
        assertEq(_token.allowance(owner, spender), allowanceAmount2);

        vm.startPrank(spender);

        if (allowanceAmount1 > allowanceAmount2) {
            vm.expectRevert("Insufficient allowance");
        }
        _token.transferFrom(owner, receiver, allowanceAmount1);
    }

    function testFuzz_transferFrom_eventEmitted(
        address owner, 
        address spender,
        address receiver,
        uint256 mintAmount,
        uint256 allowanceAmount,
        uint256 sendAmount
    )
        public
    {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(receiver != address(0));
        vm.assume(owner != spender);
        vm.assume(mintAmount >= sendAmount);
        vm.assume(allowanceAmount >= sendAmount);
        
        vm.startPrank(owner);

        _token.approve(spender, allowanceAmount);

        _token.exposed_mint(owner, mintAmount);

        vm.startPrank(spender);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, receiver, sendAmount);
        _token.transferFrom(owner, receiver, sendAmount);
    }

    function testFuzz_mint_toZeroAddress(address to, uint256 amount) public {
        if (to == address(0)) {
            vm.expectRevert("Transfer to zero address");
        }
        _token.exposed_mint(to, amount);
    }

    function testFuzz_mint_totalSupplyIncreases(address to, uint256 amount) public {
        vm.assume(to != address(0));

        _token.exposed_mint(to, amount);

        assertEq(_token.totalSupply(), amount);
    }

    function testFuzz_mint_balanceIncreases(address to, uint256 amount) public {
        vm.assume(to != address(0));

        _token.exposed_mint(to, amount);

        assertEq(_token.balanceOf(to), amount);
    }

    function testFuzz_mint_eventEmitted(address to, uint256 amount) public {
        vm.assume(to != address(0));

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), to, amount);
        _token.exposed_mint(to, amount);
    }
}
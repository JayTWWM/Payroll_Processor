// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2021 Elite
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

pragma solidity >=0.5.0 <=0.7.4;

import "./EliteToken.sol";
import "./Library.sol";

contract PayrollProcessor {
    mapping(string => Library.Job) JobStore;

    mapping(address => Library.User) UserStore;
    mapping(string => address) private UserLookup;

    
}

// contract EliteTokenSale {
//     address admin;
//     EliteToken public tokenContract;
//     uint256 public tokenPrice;
//     uint256 public tokensSold;

//     event Sell(address _buyer, uint256 _amount);

//     constructor (EliteToken _tokenContract, uint256 _tokenPrice) public {
//         admin = msg.sender;
//         tokenContract = _tokenContract;
//         tokenPrice = _tokenPrice;
//     }

//     function multiply(uint x, uint y) internal pure returns (uint z) {
//         require(y == 0 || (z = x * y) / y == x);
//     }

//     function buyTokens(uint256 _numberOfTokens) public payable {
//         require(msg.value == multiply(_numberOfTokens, tokenPrice));
//         require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
//         require(tokenContract.transfer(msg.sender, _numberOfTokens));
//         tokensSold += _numberOfTokens;
//         emit Sell(msg.sender, _numberOfTokens);
//     }

//     function endSale() public {
//         require(msg.sender == admin);
//         require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
//         address(uint160(admin)).transfer(address(this).balance);
//     }
// }
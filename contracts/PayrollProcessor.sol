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

    function createUser(
        string memory _name,
        string memory _email,
        string memory _password,
        bool _isEmployer
    ) public returns (uint256) {
        require(
            UserLookup[_email] == address(0),
            "This email is already used!"
        );
        require(
            UserStore[msg.sender].addr == address(0),
            "You Already Have An Account!"
        );
        Library.User storage newUser = UserStore[msg.sender];
        newUser.name = _name;
        newUser.email = _email;
        newUser.password = _password;
        newUser.isEmployer = _isEmployer;
        newUser.addr = msg.sender;
        newUser.jobCount = 0;
        newUser.payCount = 0;
        UserLookup[_email] = msg.sender;
        emit UserCreate(_name, _email, _isEmployer);
    }
    function logInUser(string memory _password) public view  returns (bool,string memory,string memory) {
        require(
            UserStore[msg.sender].addr != address(0),
            "You Don't Have An Account!"
        );
        string memory acc = UserStore[msg.sender].password;
        require(
            keccak256(abi.encodePacked((acc))) ==
                keccak256(abi.encodePacked((_password))),
            "Invalid Password"
        );
        return (UserStore[msg.sender].isEmployer,UserStore[msg.sender].name,UserStore[msg.sender].email);
    }
    function createJob(string memory _profile,bool _isMonthly,uint _payAmount,uint _leaveDeduction,uint _delayPenalty) public returns (uint256) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(UserStore[msg.sender].isEmployer,"Not an employer!");
        require(JobStore[_profile].employerAddr  == address(0),"Profile already exists!");
        Library.Job storage newJob = JobStore[_profile];
        newJob.profile = _profile;
        newJob.employerAddr = msg.sender;
        newJob.employerEmail = UserStore[msg.sender].email;
        newJob.isMonthly = _isMonthly;
        newJob.payAmount = _payAmount;
        newJob.leaveDeduction = _leaveDeduction;
        newJob.delayPenalty = _delayPenalty;

        UserStore[msg.sender].jobCount++;

        UserStore[msg.sender].jobs[UserStore[msg.sender].jobCount] = _profile;
        emit CreateJob(UserStore[msg.sender].email,_profile,_isMonthly,_payAmount,_leaveDeduction,_delayPenalty);
    }

    function joinJob(string memory _profile) public returns (uint256) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(!UserStore[msg.sender].isEmployer,"Not an employee!");
        require(JobStore[_profile].employerAddr  != address(0),"Profile Does not exist.");
        UserStore[msg.sender].jobCount++;
        UserStore[msg.sender].jobs[UserStore[msg.sender].jobCount] = _profile;
        JobStore[_profile].employeeCount++;
        JobStore[_profile].employeeAddr[JobStore[_profile].employeeCount] = msg.sender;
        emit JoinJob(UserStore[msg.sender].email,_profile);
    }



    event UserCreate(string name,string email,bool isEmployer);
    event CreateJob(string email,string profile, bool isMonthly, uint payAmount, uint leaveDeduction, uint delayPanalty);
    event JoinJob(string email,string profile);
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
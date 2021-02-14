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

    EliteToken public tokenContract;
    uint256 public tokenPrice;

    constructor (EliteToken _tokenContract, uint256 _tokenPrice) public {
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function createUser(
        string memory _name,
        string memory _email,
        string memory _password,
        bool _isEmployer
    ) public returns (uint) {
        require(
            UserStore[msg.sender].addr == address(0),
            "You Already Have An Account!"
        );
        require(
            UserLookup[_email] == address(0),
            "This email is already used!"
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
    function createJob(string memory _profile,bool _isMonthly,uint _payAmount,uint _leaveDeduction,uint _delayPenalty) public returns (uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(UserStore[msg.sender].isEmployer,"Not an employer!");
        require(JobStore[_profile].employerAddr == address(0),"Profile already exists!");
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

    function joinJob(string memory _profile,uint _duration) public returns (uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(!UserStore[msg.sender].isEmployer,"Not an employee!");
        require(JobStore[_profile].employerAddr != address(0),"Profile Does not exist.");
        require(JobStore[_profile].work[msg.sender].employeeAddr == address(0) || (block.timestamp)>(JobStore[_profile].work[msg.sender].startTime+JobStore[_profile].work[msg.sender].duration),"You are already in the job!");
        UserStore[msg.sender].jobCount++;
        UserStore[msg.sender].jobs[UserStore[msg.sender].jobCount] = _profile;
        JobStore[_profile].employeeCount++;
        JobStore[_profile].employeeAddr[JobStore[_profile].employeeCount] = msg.sender;
        JobStore[_profile].work[msg.sender].profile = _profile;
        JobStore[_profile].work[msg.sender].employeeAddr = msg.sender;
        JobStore[_profile].work[msg.sender].startTime = block.timestamp;
        JobStore[_profile].work[msg.sender].duration = _duration;
        emit JoinJob(UserStore[msg.sender].email,_profile);
    }
    function getJobDetails(string memory _profile) public view returns (uint,uint,uint,bool) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(JobStore[_profile].employerAddr != address(0),"Profile Does not exist.");
        return (JobStore[_profile].payAmount,JobStore[_profile].leaveDeduction,JobStore[_profile].delayPenalty,JobStore[_profile].isMonthly);
    }

    function getJobCount() public view returns (uint,bool) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        return (UserStore[msg.sender].jobCount,UserStore[msg.sender].isEmployer);
    }
    function getTransCount() public view returns (uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        return UserStore[msg.sender].payCount;
    }
    function getTransaction(uint _ind) public view returns (string memory,string memory, uint, uint, string memory,string memory) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        return (UserStore[UserStore[msg.sender].payments[_ind].sender].name,
        UserStore[UserStore[msg.sender].payments[_ind].reciever].name,
        UserStore[msg.sender].payments[_ind].amount,
        UserStore[msg.sender].payments[_ind].timestamp,
        UserStore[msg.sender].payments[_ind].purpose,
        UserStore[msg.sender].payments[_ind].currency);
    }
    function getEmployeeJob(uint _ind) public view returns (string memory,string memory,string memory,bool,uint,uint,uint,uint,uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(!UserStore[msg.sender].isEmployer,"Not an employee!");
        string memory acc = UserStore[msg.sender].jobs[_ind];
        uint stTime = JobStore[acc].work[msg.sender].startTime;
        uint dur = JobStore[acc].work[msg.sender].duration;
        if (JobStore[acc].employerAddr == address(0) || (block.timestamp)>(stTime+dur)) {
            return ("None","None","None",false,0,0,0,0,0);
        }
        return (JobStore[acc].profile,
                JobStore[acc].employerEmail,
                UserStore[JobStore[acc].employerAddr].name,
                JobStore[acc].isMonthly,
                JobStore[acc].payAmount,
                JobStore[acc].leaveDeduction,
                JobStore[acc].delayPenalty,
                stTime,
                dur);
    }
    function getEmployerJob(uint ind) public view returns (string memory,bool,uint,uint,uint,uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        string memory acc = UserStore[msg.sender].jobs[ind];
        require(JobStore[acc].employerAddr == msg.sender,"Not your job!");
        return (JobStore[acc].profile,
                JobStore[acc].isMonthly,
                JobStore[acc].payAmount,
                JobStore[acc].leaveDeduction,
                JobStore[acc].delayPenalty,
                JobStore[acc].employeeCount);
    }
    function getEmployeeCount(string memory _profile) public view returns (uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(UserStore[msg.sender].isEmployer,"Not an employer!");
        require(JobStore[_profile].employerAddr != address(0),"Profile Does not exist.");
        return JobStore[_profile].employeeCount;
    }
    function getEmployee(string memory _profile, uint ind) public view returns (string memory, string memory, uint, uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(UserStore[msg.sender].isEmployer,"Not an employer!");
        require(JobStore[_profile].employerAddr == msg.sender,"Not your job!");
        address acc = JobStore[_profile].employeeAddr[ind];
        uint stTime = JobStore[_profile].work[acc].startTime;
        uint dur = JobStore[_profile].work[acc].duration;
        if (acc == address(0) || (block.timestamp)>(stTime+dur)) {
            return ("None","None",0,0);
        }
        return (UserStore[acc].email,UserStore[acc].name,stTime,dur);
    }

    function calculatePayment(string memory _profile,string memory _email,uint _leaves, uint _delays, uint _unitsWorked, uint extra)
    public view returns (uint,uint,uint,uint,uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(UserStore[msg.sender].isEmployer,"Not an employer!");
        require(JobStore[_profile].employerAddr != address(0),"Profile Does not exist.");
        require(UserLookup[_email] != address(0),"Receiver Does not exist.");
        uint worked = JobStore[_profile].payAmount*_unitsWorked;
        uint leaves = JobStore[_profile].leaveDeduction*_leaves;
        uint delay = JobStore[_profile].delayPenalty*_delays;
        return (worked+extra-leaves-delay,worked,leaves,delay,extra);
    }

    function makeTransfer(string memory _email, uint _amount, string memory _purpose) public returns (uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(UserLookup[_email] != address(0),"Receiver Does not exist.");
        // require(tokenContract.approve(msg.sender,_amount+10),"Amount not approved!");
        require(tokenContract.transferFrom(msg.sender,UserLookup[_email],_amount),"Transaction Failed");
        UserStore[msg.sender].payCount++;
        UserStore[msg.sender].payments[UserStore[msg.sender].payCount] = Library.Payment(msg.sender,UserLookup[_email],_amount,block.timestamp,_purpose,"ELT");
        UserStore[UserLookup[_email]].payCount++;
        UserStore[UserLookup[_email]].payments[UserStore[UserLookup[_email]].payCount] = Library.Payment(msg.sender,UserLookup[_email],_amount,block.timestamp,_purpose,"ELT");
        emit TransferMoney(_email,UserStore[msg.sender].email,_amount,_purpose);
    }

    function makeThirdPartyTransfer(string memory _email, uint _amount, string memory _purpose, string memory _currency) public returns (uint) {
        require(UserStore[msg.sender].addr != address(0),"You dont have an account!");
        require(UserLookup[_email] != address(0),"Receiver Does not exist.");
        // require(tokenContract.approve(msg.sender,_amount+10),"Amount not approved!");
        // require(tokenContract.transferFrom(msg.sender,UserLookup[_email],_amount),"Transaction Failed");
        UserStore[msg.sender].payCount++;
        UserStore[msg.sender].payments[UserStore[msg.sender].payCount] = Library.Payment(msg.sender,UserLookup[_email],_amount,block.timestamp,_purpose,_currency);
        UserStore[UserLookup[_email]].payCount++;
        UserStore[UserLookup[_email]].payments[UserStore[UserLookup[_email]].payCount] = Library.Payment(msg.sender,UserLookup[_email],_amount,block.timestamp,_purpose,_currency);
        emit TransferMoney(_email,UserStore[msg.sender].email,_amount,_purpose);
    }

    event UserCreate(string name,string email,bool isEmployer);
    event CreateJob(string email,string profile, bool isMonthly, uint payAmount, uint leaveDeduction, uint delayPenalty);
    event JoinJob(string email,string profile);
    event TransferMoney(string email_receiver,string email_sender,uint amount,string purpose);
}

// contract EliteTokenSale {
//     address admin;
    // EliteToken public tokenContract;
    // uint256 public tokenPrice;
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
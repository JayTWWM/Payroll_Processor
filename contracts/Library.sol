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

library Library{
    struct User {
        string name;
        string email;
        string password;
        address addr;
        bool isEmployer;
        uint jobCount;
        mapping(uint => string) jobs;
        uint payCount;
        mapping(uint => Payment) payments;
    }
    struct Job {
        string profile;
        address employerAddr;
        string employerEmail;
        bool isMonthly;
        uint payAmount;
        uint leaveDeduction;
        uint delayPenalty;
        uint employeeCount;
        mapping(uint => address) employeeAddr;
        mapping(address => Work) work;
    }
    struct Payment {
        address sender;
        address reciever;
        uint amount;
        uint timestamp;
        string purpose;
        string currency;
    }
    struct Work {
        string profile;
        address employeeAddr;
        uint startTime;
        uint duration;
        // uint leaves;
        // uint delay;
        // uint workUnits;
    }
}
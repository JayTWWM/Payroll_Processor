$.noConflict();

jQuery(document).ready(function($) {
    var employeeCount;
    
    var queryString = decodeURIComponent(window.location.search);
    queryString = queryString.substring(1);
    var queries = queryString.split("&");
    profile = queries[0].split("=")[1];
    console.log(profile);
    setTimeout(function() {
        PayrollProcessorContract.methods.getEmployeeCount(profile).call((error, response) => {
            if (error) {
                console.log(error);
            } else {
                console.log(response);
                employeeCount = response;
            }
        });
    }, 1000);

    setTimeout(function() {
        for (let k = 1; k <= employeeCount; k++) {
            PayrollProcessorContract.methods.getEmployee(profile,k).call((error, response) => {
                if (error) {
                    console.log(error);
                } else {
                    console.log(response);
                    if (response[0] != "None") {
                        var stDate = new Date(parseInt(response[2])*1000);
                        stDate = stDate.toDateString();
                        var edDate = new Date(parseInt(response[2])*1000 + parseInt(response[3])*1000);
                        edDate = edDate.toDateString();
                        var row = '<tr><td>' + k + '</td><td>' + response[1] + '</td><td>' + stDate + '</td><td>' + edDate + '</td><td><a href="' + 'mailto:' + response[0] + '?body=Hi&subject=' + '" class="btn btn-primary"><i class="fas fa-envelope"></i>&nbsp;Email Employee</a></td><td><a data-toggle="modal" data-target="#pay_employee" class="btn btn-primary"><i class="fas fa-envelope"></i>&nbsp;Pay</a></td></tr>';
                        $("#job_body").append(row);
                    }
                }
            });
        }
    }, 2000);


});
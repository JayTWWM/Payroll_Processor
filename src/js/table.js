$.noConflict();

jQuery(document).ready(function($) {
    var jobCount;
    var isEmployer;

    setTimeout(function() {
        PayrollProcessorContract.methods.getJobCount().call((error, response) => {
            if (error) {
                console.log(error);
            } else {
                console.log(response);
                jobCount = response[0];
                isEmployer = response[1];
            }
        });
    }, 1000);


    setTimeout(function() {
        for (let k = 1; k <= jobCount; k++) {
            if(isEmployer) {
                PayrollProcessorContract.methods.getEmployerJob(k).call((error, response) => {
                    if (error) {
                        console.log(error);
                    } else {
                        console.log(response);
                        if (response[0] != "None") {
                            // var stDate = new Date(response[7]);
                            // stDate = stDate.toDateString();
                            // var edDate = new Date(response[7] + response[8]);
                            // edDate = edDate.toDateString();
                            var payment = response[2];
                            if (response[1]) {
                                payment = payment.toString() + '/Month';
                            } else {
                                payment = payment.toString() + '/Hour';
                            }
                            var row = '<tr><td>' + k + '</td><td><a href="./employee.html?profile=' + response[0] + '">' + response[0] + '</a></td><td>' + response[5] + '</td><td>' + payment + '</td><td>' + response[3] + '</td><td>' + response[4] + '</td></tr>';
                            $("#jobs_body").append(row);
                        }
                    }
                });
            } else {
                PayrollProcessorContract.methods.getEmployeeJob(k).call((error, response) => {
                    if (error) {
                        console.log(error);
                    } else {
                        console.log(response);
                        if (response[0] != "None") {
                            var stDate = new Date(parseInt(response[7])*1000);
                            stDate = stDate.toDateString();
                            var edDate = new Date(parseInt(response[7])*1000 + parseInt(response[8])*1000);
                            edDate = edDate.toDateString();
                            var payment = response[4];
                            if (response[3]) {
                                payment = payment.toString() + '/Month';
                            } else {
                                payment = payment.toString() + '/Hour';
                            }
                            var row = '<tr><td>' + k + '</td><td>' + response[2] + '</td><td>' + response[0] + '</td><td>' + stDate + '</td><td>' + edDate + '</td><td>' + payment + '</td><td>' + response[5] + '</td><td>' + response[6] + '</td><td><a href="' + 'mailto:' + response[1] + '?body=Hi&subject=' + '" class="btn btn-primary"><i class="fas fa-envelope"></i>&nbsp;Email Employer</a></td></tr>';
                            $("#product_body").append(row);
                        }
                    }
                });
            }
        }
    }, 2000);


});
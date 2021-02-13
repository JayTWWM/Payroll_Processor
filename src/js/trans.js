$.noConflict();

jQuery(document).ready(function($) {
    var transCount;

    setTimeout(function() {
        PayrollProcessorContract.methods.getTransCount().call((error, response) => {
            if (error) {
                console.log(error);
            } else {
                console.log(response);
                transCount = response;
            }
        });
    }, 1000);

    setTimeout(function() {
        for (let k = 1; k <= transCount; k++) {
            PayrollProcessorContract.methods.getTransaction(k).call((error, response) => {
                if (error) {
                    console.log(error);
                } else {
                    console.log(response);
                    var stDate = new Date(parseInt(response[3]) * 1000);
                    var row = '<tr><td>' + k + '</td><td>' + stDate.toDateString() + '</td><td>' + response[0] + '</td><td>' + response[1] + '</td><td>' + response[4] + '</td><td>' + response[2] + '</td><td>' + response[5] + '</td></tr>';
                    $("#product_body").append(row);
                }
            });
        }
    }, 2000);

});
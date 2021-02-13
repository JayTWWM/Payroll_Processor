function signin() {
    var signin_form = document.getElementById("sign-in-form");
    //   var email = signin_form['signin_email'];
    var password = signin_form['signin_password'];
    //   console.log(email.value);
    console.log(password.value);
    PayrollProcessorContract.methods.logInUser(password.value)
        .send()
        .then(result => {
            if (result.status === true) {
                alert("Success");
                console.log(result);
            }
        });
    return false;

}

function ValidateEmail(mail) {
    if (/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(mail)) {
        console.log("valid");
        return (true)
    }

    return (false)
}

function signup() {
    var signup_form = document.getElementById("sign-up-form");
    var name = signup_form['name'];
    var email = signup_form['email'];
    var password = signup_form['password'];
    var position = signup_form['position'];
    console.log(name.value);
    console.log(email.value);
    console.log(password.value);
    console.log(position.value);

    if (!ValidateEmail(email.value)) {
        alert("Enter email in proper format");
        return false;
    } else if (password.value.length < 5) {
        alert("Password too short");
        return false;
    } else {
        PayrollProcessorContract.methods.createUser(name.value, email.value, password.value, position.value == 'employer')
            .send()
            .then(result => {
                if (result.status === true) {
                    alert("Success");
                    console.log(result);
                }
            });
    }
    return false;
}

function add_job() {
    var form = document.getElementById("add_role_form");
    PayrollProcessorContract.methods.createJob(form["role_name"].value, form["type_of_work"].value == 'Monthly', form["pay_amount"].value, form["leave_deduction"].value, form["delay_penalty"].value)
        .send()
        .then(result => {
            if (result.status === true) {
                alert("Success");
                console.log(result);
                window.location.reload();
            }
        });
    // console.log(jobs)
    // jobs.push(
    //     {
    //         "jobid":jobs.length,
    //         "role_name":form["role_name"].value,
    //         "type_of_work":form["type_of_work"].value,
    //         "pay_amount":form["pay_amount"].value,
    //         "leave_deduction":form["leave_deduction"].value,
    //         "delay_penalty":form["delay_penalty"].value,
    //         "employees":[]
    //     }
    // )
    // console.log(jobs)

    // var table_body = document.getElementById("jobs_body")
    // var row = table_body.insertRow(jobs.length-1);

    // var cell1 = row.insertCell(0)
    // var cell2 = row.insertCell(1)
    // var cell3 = row.insertCell(2)
    // var cell4 = row.insertCell(3)
    // var cell5 = row.insertCell(4)
    // var cell6 = row.insertCell(5)
    // var cell7 = row.insertCell(6)
    // var cell8 = row.insertCell(7)

    // cell1.innerHTML = jobs.length;
    // cell2.innerHTML = '<a href="/job.html?jobid='+(jobs.length-1)+'" style="text-decoration: none; color: black;">'+jobs[jobs.length-1]["role_name"]+'</a>'
    // cell3.innerHTML = jobs[jobs.length-1]["employees"].length
    // cell4.innerHTML = jobs[jobs.length-1]["type_of_work"]
    // cell5.innerHTML = jobs[jobs.length-1]["pay_amount"]
    // cell6.innerHTML = jobs[jobs.length-1]["leave_deduction"]
    // cell7.innerHTML = jobs[jobs.length-1]["delay_penalty"]
    // cell8.innerHTML = '<a href="#" class="btn btn-primary" data-toggle="modal" data-target="#join"><i class="fas fa-plus"></i>&nbsp;Add Employee</a>'
}

function join_job() {
    var form = document.getElementById("Add_job");
    var d = new Date();
    var n = d.getTime();
    var endDate = Date.parse(form["end_datetime"].value);
    console.log(form["profile"].value, endDate / 1000);
    PayrollProcessorContract.methods.joinJob(form["profile"].value, (endDate - n) / 1000)
        .send()
        .then(result => {
            if (result.status === true) {
                alert("Success");
                console.log(result);
                window.location.reload();
            }
        });
}

function calculate_payment() {
    // var queryString = decodeURIComponent(window.location.search);
    // queryString = queryString.substring(1);
    // var queries = queryString.split("&");
    // profile = queries[0].split("=")[1];
    const urlParams = new URLSearchParams(window.location.search);
    const profile = urlParams.get('profile');
    var extra = 0;
    for (const a in obj) {
        console.log(obj[a])
        extra = extra + Number(obj[a])
    }
    console.log(profile, currentEmployee, document.getElementById("leave").value, document.getElementById("delay").value, document.getElementById("amount_of_work").value, extra);
    PayrollProcessorContract.methods.calculatePayment(profile, currentEmployee, document.getElementById("leave").value, document.getElementById("delay").value, document.getElementById("amount_of_work").value, extra)
        .call((error, response) => {
            if (error) {
                console.log(error);
            } else {
                console.log(response);
                document.getElementById('payment').value = response[0];
                document.getElementById('pay_button').style.display = "block";
            }
        });
}

function make_payment() {
    var email = currentEmployee;
    var amount = document.getElementById('payment').value;
    // var queryString = decodeURIComponent(window.location.search);
    // queryString = queryString.substring(1);
    // var queries = queryString.split("&");
    // profile = queries[0].split("=")[1];

    const urlParams = new URLSearchParams(window.location.search);
    const profile = urlParams.get('profile');
    console.log(profile, email, amount)
    var purpose = profile;
    PayrollProcessorContract.methods.makeTransfer(email, amount, purpose)
        .send()
        .then(result => {
            if (result.status === true) {
                alert("Success");
                console.log(result);
            }
        });
}
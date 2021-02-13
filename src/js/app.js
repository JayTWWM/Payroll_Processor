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
        PayrollProcessorContract.methods.createUser(name.value, email.value, password.value, position.value == 'Employer')
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
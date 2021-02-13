const sign_in_btn = document.querySelector("#sign-in-btn");
const sign_up_btn = document.querySelector("#sign-up-btn");
const container = document.querySelector(".container");

sign_up_btn.addEventListener("click", () => {
    container.classList.add("sign-up-mode");
});

sign_in_btn.addEventListener("click", () => {
    container.classList.remove("sign-up-mode");
});

function mail() {
    var invite_form = document.getElementById("invite_form");
    console.log(invite_form)
    var email = invite_form['email'].value;
    window.location.href = "mailto:" + email + "?body=Hi&subject=Invite via Email"
}
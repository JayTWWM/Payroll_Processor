$.noConflict();

jQuery(document).ready(function($) {
    const urlParams = new URLSearchParams(window.location.search);
    const namer = urlParams.get('name');
    if (namer == null) { document.getElementById('greeting').innerHTML = "Welcome"; } else {
        document.getElementById('greeting').innerHTML = "Welcome " + namer;
    }
});
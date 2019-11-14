var app = app || {};
app.clipboard = {};

app.clipboard.copy = (text) => {

    let elem = $("textarea#clipboard");
    if (elem.length == 0) {
        elem = $("<textarea id=\"clipboard\"></textarea>")
            .css("opacity", .01)
            .css("height", 0)
            .css("position", "fixed")
            .css("z-index", -1);
        $("body").append(elem);
    }

    elem.text(text);
    elem.focus();
    elem.select();
    if (!document.execCommand('copy')) {
        console.error("Unable to copy");
    }
};
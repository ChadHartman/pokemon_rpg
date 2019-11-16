var app = app || {};

app.filter = {

    timeouts: [],

    apply: (filter) => {
        $("[data-filter=\"item\"]").each((index, item) => {
            let visible = item.innerText.toLowerCase().indexOf(filter) !== -1;
            item.style.visibility = visible ? "visible" : "collapse";
        });
    },

    setup: () => {
        $("[data-filter=\"input\"]").keyup((e) => {
            for (let timeoutId of app.filter.timeouts) {
                clearTimeout(timeoutId);
            }

            app.filter.timeouts = [];

            let filter = e.target.value.toLowerCase();
            app.filter.timeouts.push(setTimeout(app.filter.apply, 500, filter));
        });
    }
};
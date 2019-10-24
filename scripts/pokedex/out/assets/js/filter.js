var app = app || {};

app.filter = {
    setup: () => {
        $("[data-filter=\"input\"]").keyup((e) => {
            let filter = e.target.value.toLowerCase();

            $("[data-filter=\"item\"]").each((index, item) => {
                let visible = item.innerText.toLowerCase().indexOf(filter) !== -1;
                item.style.visibility = visible ? "visible" : "collapse";
            });
        });
    }
};
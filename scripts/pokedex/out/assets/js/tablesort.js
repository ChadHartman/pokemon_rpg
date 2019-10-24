var app = app || {};

app.tablesort = {

    sort: (table, e) => {
        let direction = e.target.attributes["data-tablesort"].value === "asc" ? 1 : -1;
        let index = $(e.target).parent("th,td").index();
        let rows = table.find("tr[data-tablesort]");
        let parent = rows.parent();
        let sortableRows = rows.get();

        sortableRows.sort((a, b) => {
            let aVal = a.children[index].innerText;
            let bVal = b.children[index].innerText;

            if ($.isNumeric(aVal)) {
                return direction * (aVal - bVal);
            }

            return direction * aVal.localeCompare(bVal);
        });

        rows.remove();
        parent.append(sortableRows);
    },
    setup: () => {

        $("table[data-tablesort=\"table\"]").each(function () {
            let table = $(this);
            table.find("button[data-tablesort]")
                .click((e) => app.tablesort.sort(table, e));
        });
    }
};
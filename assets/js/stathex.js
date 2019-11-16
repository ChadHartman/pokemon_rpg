var app = app || {};
app.stathex = {};

app.stathex.setup = (data) => {

    let canvas = document.getElementsByTagName("canvas")[0];
    let ctx = canvas.getContext("2d");
    ctx.fillStyle = "grey";
    ctx.strokeStyle = "black";
    ctx.font = "10px Arial";

    let padding = 10;
    let slice = 2 * Math.PI / data.length;
    let cx = Math.round(canvas.width / 2);
    let cy = Math.round(canvas.height / 2);
    let r = cy - padding;
    let angleOffset = Math.PI;
    let textOffsetX = -6;
    let textOffsetY = 5;

    for (let i in data) {
        let angle = (i * slice) + angleOffset;
        let stat = data[i];
        let valR = r * (stat.value / stat.max);

        stat.valX = cx + (valR * Math.sin(angle));
        stat.valY = cy + (valR * Math.cos(angle));
        stat.maxX = cx + (r * Math.sin(angle));
        stat.maxY = cy + (r * Math.cos(angle));
    }

    // Draw ref lines
    ctx.strokeStyle = "#999";
    ctx.setLineDash([5, 5]);

    ctx.beginPath();

    for (let stat of data) {
        ctx.moveTo(cx, cy);
        ctx.lineTo(stat.maxX, stat.maxY);
    }

    ctx.stroke();

    // Draw data
    ctx.strokeStyle = "black";
    ctx.setLineDash([]);
    ctx.beginPath();

    // Draw Outside border
    ctx.moveTo(data[0].maxX, data[0].maxY);

    for (let stat of data) {
        ctx.lineTo(stat.maxX, stat.maxY);
    }

    ctx.closePath();

    // Draw Inside line
    ctx.moveTo(data[0].valX, data[0].valY);

    for (let stat of data) {
        ctx.lineTo(stat.valX, stat.valY);
    }

    ctx.closePath();

    // Draw Points
    for (let stat of data) {
        ctx.moveTo(stat.valX, stat.valY);
        ctx.arc(stat.valX, stat.valY, 2, 0, 2 * Math.PI);

        ctx.moveTo(stat.maxX, stat.maxY);
        ctx.arc(stat.maxX, stat.maxY, 2, 0, 2 * Math.PI);

        ctx.strokeText(
            stat.label,
            stat.maxX + textOffsetX,
            stat.maxY + textOffsetY);
    }

    ctx.stroke();

};
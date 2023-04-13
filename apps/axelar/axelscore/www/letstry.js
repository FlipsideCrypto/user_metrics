// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//

const imglnk = 'https://docs.axelar.dev/images/chains/'

var data = [
  { image: imglnk.concat("polygon", ".svg"), x: 50 },
  { image: "https://docs.axelar.dev/images/chains/axelar.svg", x: 130 },
  { image: "https://docs.axelar.dev/images/chains/kujira.svg", x: 210 }
]; // example data

var patterns = svg.selectAll("pattern")
                  .data(data)
                  .enter()
                  .append("pattern")
                  .attr("id", function(d, i) { return "pattern-" + i; })
                  .attr("patternUnits", "userSpaceOnUse")
                  .attr("width", 80)
                  .attr("height", 80);

patterns.append("image")
        .attr("xlink:href", function(d) { return d.image; })
        .attr("width", 80)
        .attr("height", 80);

var circles = svg.selectAll("circle")
                 .data(data)
                 .enter()
                 .append("circle")
                 .attr("cx", function(d) { return d.x; })
                 .attr("cy", 200)
                 .attr("r", 40)
                 .attr("fill", function(d, i) { return "url(#pattern-" + i + ")"; });
                 
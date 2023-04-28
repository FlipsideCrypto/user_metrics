
var cradius = Math.min(width, height)*0.025;

const imglnk = '';

var patterns = svg.selectAll(".patterns")
                  .data(r2d3.data.nodes)
                  .enter()
                  .append("pattern")
                  .attr("id", function(d, i) { return "pattern-" + i; })
                  .attr("patternUnits", "objectBoundingBox")
                  .attr("width", 10)
                  .attr("height", 10);

patterns.append("image")
        .attr("xlink:href", function(d) { return imglnk.concat(d.station, ".svg"); })
        .attr("width", cradius*2)
        .attr("height", cradius*2)
        .attr("x", 0)
        .attr("y", 0);

r2d3.svg.append('image')
   .attr('href', 'AxelarMap.svg')
   .attr('preserveAspectRatio', 'none')
   .attr('width', width)
   .attr('height', height);
   
   
// bridges and squids
var connections = r2d3.svg.selectAll(".connections")
.data(r2d3.data.edges);

var connectionsEnter = connections.enter()
.append("image")
.attr("class", "connections")
.attr("xlink:href", d => d.connection + '.svg')
.attr("x", d => d.xprop * width)
.attr("y", d => d.yprop * height)
.attr("width", d => d.wprop * width) 
.attr("height", d => d.hprop * height);

connectionsEnter.attr("display", d => d.used === "yes" ? "inline" : "none");

var connectionsUpdate = connections
.attr("xlink:href", d => d.connection + '.svg')
.attr("x", d => d.xprop * width)
.attr("y", d => d.yprop * height)
.attr("width", d => d.wprop * width) 
.attr("height", d => d.hprop * height);

connectionsUpdate.attr("display", d => d.used === "yes" ? "inline" : "none");

connections.exit().remove();
  
var outlinecircles = r2d3.svg
  .selectAll('.outlinecircles')
  .data(r2d3.data.nodes)
  .enter()
  .append('circle')
  .attr('r', cradius*1.4)
  .attr('cx', function(d) { return d.xprop * width; })
  .attr('cy', function(d) { return d.yprop * height; })
  .attr("stroke", function(d) {return d.island_color;})
  .attr("fill", "transparent")
  .attr("stroke-width", d => d.selected === "yes" ? 1.5 : 0);

outlinecircles.exit().remove();

outlinecircles.transition()
  .duration(1)
  .attr("stroke-width", d => d.selected === "yes" ? 2 : 0);


var highlightcircles = r2d3.svg
  .selectAll('.highlightcircles')
  .data(r2d3.data.nodes)
  .enter()
  .append('circle')
  .attr('r', cradius*1.2)
  .attr('cx', function(d) { return d.xprop * width; })
  .attr('cy', function(d) { return d.yprop * height; })
  .attr("fill", d => d.selected === "yes" ? d.island_color : "transparent");
  



highlightcircles.exit().remove();

highlightcircles.transition()
  .duration(1)
  .attr("fill", d => d.selected === "yes" ? d.island_color : "transparent");
  //.style("filter", d => d.selected === "yes" ? "url(#glow)" : "");


// now we get to the 'real' circles
var circles = r2d3.svg
  .selectAll('.circles')     
  .data(r2d3.data.nodes)
  .enter()
  .append('circle')
  .attr('r', cradius)
  .attr('cx', function(d) { return d.xprop * width; })
  .attr('cy', function(d) { return d.yprop * height; })
  .attr("fill", function(d, i) { return "url(#pattern-" + i + ")"; })
  .attr("station", function(d) { return d.station; })
  .on("mouseover", function(){
      Shiny.setInputValue(
        "station_clicked", 
        d3.select(this).attr("station"),
        {priority: "event"}
        );
    })
  .on("mouseout", function() {
      Shiny.setInputValue(
        "station_clicked", 
        "",
        {priority: "event"}
      );
    });

circles.exit().remove();

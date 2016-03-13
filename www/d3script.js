Shiny.addCustomMessageHandler("jsondata",
  function(message){
    var treeData = message;

    // ************** Generate the tree diagram  *****************

d3.select("#tempID").remove()

root = JSON.parse(treeData);

var width = 800, height = root.totaltracks*25;
                   
var cluster = d3.layout.cluster().size([height-100, width - 500]);

var diagonal = d3.svg.diagonal().projection(function(d) { return [d.y, d.x]; });

var svg = d3.select("#div_tree").append("svg")
                   .attr("id","tempID")
                   .attr("width", width)
                   .attr("height", height)
                   .append("g")
                   .attr("transform", "translate(40,0)");

var nodes = cluster.nodes(root.discog),
                   links = cluster.links(nodes);

var link = svg.selectAll(".link")
                   .data(links)
                   .enter().append("path")
                   .attr("class", "link")
                   .attr("d", diagonal);

var node = svg.selectAll(".node")
                   .data(nodes)
                   .enter().append("g")
                   .attr("class", "node")
                   .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
    
    node.append("circle")
                   .attr("r", 10)
                   .style("opacity", function(d) {if(d.children){return 0;} else {return 1;}})
                   .on("click", function(d) {if(!d.children) {window.open(d.value);} })
                   ;


    node.append("image")
                  .attr("xlink:href", function(d) {if(d.children){return "http://www.clker.com/cliparts/W/i/K/w/1/D/glossy-orange-circle-icon-md.png"}                            else {return "http://www2.psd100.com/icon/2013/09/1101/Orange-play-button-icon-0911053546.png"}})
                  .attr("x", -7)
                  .attr("y", -7)
                  .attr("width", 14)
                  .attr("height", 14)
                  .on("click", function(d) {if(!d.children) {window.open(d.value);} })
                  ;
                   
    node.append("text")
                   .attr("dx", function(d) { return d.children ? 50 : 8; })
                   .attr("dy", function(d) { return d.children ? 20 : 4; })
                   .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
                   .text(function(d) { return d.name; });
                   d3.select(self.frameElement).style("height", height + "px");


  });

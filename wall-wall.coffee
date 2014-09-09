class SpringsAndMasses

    # parameters
    sw = 50 # spring width
    sh = 20 # spring height

    constructor: (@containerId, @n) ->
        
        @K = 16/@n # scale factor to modify display
        @D = 2*@K # rest distance between mass centers
        @radius = 10*@K # mass radius
        @vmax = 0.8*@K # maximum velocity

        @springSvg()

        @container = $("##{@containerId}")
        @width = @container.width()
        @height = @container.height()
        @container.empty()
        @container
            .append(@elementDiv "springs")
            .append(@elementDiv "masses")
        
        d3.select("##{@containerId}").selectAll("svg").remove()
        @fpu = d3.select("##{@containerId}").append("svg")  # ZZZ dup
        
        # map sim units to pixels
        @n_to_px = d3.scale.linear()
            .domain([0, @D*@n])
            .range([0, @width])

        # map pixels to sim units
        @px_to_n = d3.scale.linear()
            .domain([0, @width])
            .range([0, @D*@n])

        # map velocity to color
        @v_to_c = d3.scale.linear()
            .domain([0, @vmax])
            .range(["#ffdd00", "#ff0000"])
            
        # factor to scale spring length to 1 sim unit
        @ss = @n_to_px(1)/sw

        # mass radius in sim units
        @mr = @px_to_n(@radius)
 
        @springs = d3.select("#springs")
            .append("svg")
            .selectAll("g.node")
            .data([1..@n])
            .enter()
            .append("use")
            .attr("xlink:href", (d) -> "#spring" )

        @masses = d3.select("#masses").append("svg")
            .selectAll("circle").data([1..@n-1]).enter()
            .append("circle")
            .attr(
                "r": @radius
                "cy": @height/2
            )
            
    elementDiv: (id) ->
        $ "<div>",
            id: id
            class: "mass_spring_element"
            css:
                width: "#{@width}px"
                height: "#{@height}px"
                
    springSvg: ->
        divId = "svg_spring_div"
        $("##{divId}")?.remove()
        hiddenDiv = $("<div>", css: {display: "none"}, id: divId)
        $("#blab_container").append hiddenDiv
        d3.select("#codeout_html").selectAll("svg").remove()
        hiddenDiv.append """
        <svg
           id="svg_springs" xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink" 
           width="0" height="0" visibility="hidden" version="1.1">
           <defs>
           <g id="spring" transform="matrix(0.49507312,0,0,0.48532626,-81.878126,-270.14534)">
           <path d="m 165,577.36218 c 0,0 3.33333,0 10,0 5,0 5,-10 10,-15 10.54093,-10.54092 24.90712,35 10,35 -15,0 -4.90712,-40 10,-40 14.90712,0 24.90712,40 10,40 -15,0 -4.90712,-40 10,-40 14.90712,0 24.90712,40 10,40 -15,0 -0.54093,-45.54092 10,-35 5,5 5,15 10,15 6.66667,0 10,0 10,0"
                style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" />
           </g> 
           </defs>
        </svg>        
        """
        
    plot: (disp, v) ->
        
        m = [0..@n] # mass index
        t = @D*m + disp # translation for each mass
        s = @D + disp[1..@n] - disp[0..@n-1] # spring length
        
        # spring data
        tMap = t.map(@n_to_px)
        vMap = v.map(@v_to_c)
        data = ({v: vMap[i], t: tMap[i], s: si} for si, i in s)
        
        # plot masses / set color
        @masses.data(data[1..@n-1])
            .attr("cx": (d) -> d.t)
            .style("fill": (d) => d.v)
    
        # plot / scale springs
        @springs.data(data)
            .attr("transform", (d) =>
                "translate(" + (d.t + @radius) + "," + 
                (@height/2-(sh*0.75)/2) + 
                ") scale(" + @ss*(d.s-2*@mr) + ", 0.75)"
            )

$blab.SpringsAndMasses = SpringsAndMasses


figColors = null

$blab.massFigure = (params) ->
    
    n = params.n
    height = params.height
    yaxes = params.yaxes
    figColors = {disp: yaxes[0].color, vel: yaxes[1].color}
    
    yAx = (spec) ->
        position: spec.pos
        min: spec.min
        max: spec.max
        ticks: [spec.min..spec.max]
        tickDecimals: 0
        tickColor: spec.color
        tickLength: 5
        font: {color: spec.color}
    
    fig = figure
        xlabel: "mass #"
        height: height
        xaxes: [ticks: [0..n], tickDecimals: 0],
        yaxes: [yAx(yaxes[0]), yAx(yaxes[1])],
        legend: {position: "ne"}
        series: {
            shadowSize: 0
            lines:
                show: true
                lineWidth: 2
            points: {show: true}
        }
        
$blab.massPlot = (x, d, v, fig) -> #;
    disp =
        data: [x, d].T
        label: "displacement"
        color: figColors.disp
        yaxis: 1
    vel =
        data: [x, v].T
        label: "velocity"
        color: figColors.vel
        yaxis: 2
    plotSeries [disp, vel], fig: fig
    


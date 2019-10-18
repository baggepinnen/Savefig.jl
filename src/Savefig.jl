module Savefig
using Plots, PGFPlots, Colors

color_palette = [
    RGB(0.1399999, 0.1399999, 0.4),
    RGB(1.0, 0.7075, 0.35),
    RGB(0.414999, 1.0, 1.0),
    RGB(0.6, 0.21, 0.534999),
    RGB(0,0.6,0),
]

default(grid=false, color_palette=color_palette)

function replace_a_bunch_of_stuff(filename, replacements)
    temppath, temp = mktemp()
    open(filename) do f
        text = read(f, String)
        for p in replacements
            text = replace(text, p)
        end
        print(temp, text)
    end
    close(temp)
    mv(temppath, filename, force=true)
end

function set_positions(filename)
    temppath, temp = mktemp()
    fignum = 0
    for line in eachline(filename)
        if occursin("\\begin{axis}[", line)
            fignum += 1
            println(temp, line)
            println(temp, "name = fig$(fignum),")
            fignum == 1 && continue
            println(temp, "at=(fig$(fignum-1).below south west),")
            println(temp, "anchor=above north west,")
            continue
        end
        occursin(Char(8), line) && continue
        println(temp, line)
    end

    close(temp)
    mv(temppath, filename, force=true)

end

replacements_pgfplots = [
r"axis background/.style={fill={rgb,1:red,[\d\.]+;green,[\d\.]+;blue,[\d\.]+}}\s*?," => "",
"rgb,1:red,0.00000000;green,0.00000000;blue,0.00000000" => "black",
"rgb,1:red,1.00000000;green,1.00000000;blue,1.00000000" => "white",
r"height = \{[\.\d]+\w*?\}" => "height = {\\figureheight}",
r"width = \{[\.\d]+\w*?\}" => "width = {\\figurewidth}",
r",[\w\s]+? style = \{font = \{\\fontsize\{[\w\s\d\.]*?\}\{[\w\s\d\.]*?\}\\selectfont\}, color = \{rgb,1:red,0.00000000;green,0.00000000;blue,0.00000000\}, draw opacity = 1.0, rotate = 0.0\}" => "",
r",[\w\s]+? style = {color = \{rgb,1:red,0.00000000;green,0.00000000;blue,0.00000000\},\n*?draw opacity = 1.0,\n*?line width = 1,\n*?solid(,fill = \{rgb,1:red,1.00000000;green,1.00000000;blue,1.00000000\},font = \{\\fontsize\{[\w\s\d\.]*?\}\{[\w\s\d\.]*?\}\\selectfont})?\}" => "",
r"xtick\s?=\s?\{.*?\}," => "",
r"ytick\s?=\s?\{.*?\}," => "",
r"xshift\s?=\s?\d+?\.\d+?[^\\]\w*?," => ",",
r"yshift\s?=\s?\d+?\.\d+?[^\\]\w*?," => ",",
r"xticklabels\s?=\s?\{.*?\}," => "",
r"yticklabels\s?=\s?\{.*?\}," => "",
]

function savefig_pgfplots(filename, axis="")

    fig = current()
    layout = size(fig.layout.grid)
    pgffig = fig.o
    subfig = Iterators.product(0:layout[2]-1, 0:layout[1]-1)
    for (f,sfig) in zip(pgffig, subfig)
        # stylevec = split(f.style, ",")
        # push!(stylevec, "xshift=$(1.05*sfig[1])\\figurewidth, yshift=$(1.05*sfig[2])\\figureheight")
        # f.style = join(stylevec, ',')
        f.style = "xshift=$(1.02*sfig[1])\\figurewidth, yshift=$(1.05*sfig[2])\\figureheight,"*axis
        f.height = "\\figureheight"
        f.width = "\\figurewidth"
    end
    PGFPlots.save(filename, pgffig, include_preamble=false)
    # replace_a_bunch_of_stuff(filename, replacements_pgfplots)
end



using PyCall
const tikzplotlib = PyNULL()

function __init__()
    @eval global tikzplotlib = pyimport("tikzplotlib")
end


replacements_pyplot = [
r"\\definecolor\{color\d+\}\{rgb\}\{.*?\}" => Char(8),
r"xtick\s?=\s?\{.*?\}," => Char(8),
r"ytick\s?=\s?\{.*?\}," => Char(8),
r"xticklabels\s?=\s?\{.*?\}," => Char(8),
r"yticklabels\s?=\s?\{.*?\}," => Char(8),
]
"""
`savefig_pyplot(filename, fig = current().o; extra::Vector{String})`
"""
function savefig_pyplot(filename, fig = current(); kwargs...)
    tikzplotlib.save(filename,fig.o; figureheight = "\\figureheight", figurewidth = "\\figurewidth", kwargs...)
    replace_a_bunch_of_stuff(filename, replacements_pyplot)
    set_positions(filename)
end

end # module

# cd(@__DIR__)
# plot(randn(100), label="label", title="title", xlabel="xlabel", ylabel="ylabel")
# savefig_pgfplots("test.tex")

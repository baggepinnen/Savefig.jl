module Savefig
using Plots
pgfplots()

function savefig_pgfplots(filename)
    savefig(filename)
    temppath, temp = mktemp()
    pattern = r"axis background/.style={fill={rgb,1:red,[\d\.]+;green,[\d\.]+;blue,[\d\.]+}}\s*?,"
    open(filename) do f
        text = read(f, String)
        text = replace(text, pattern => "")
        text = replace(text, r"height = \{[\.\d]+\w*?\}" => "height = {\\figureheight}")
        text = replace(text, r"width = \{[\.\d]+\w*?\}" => "width = {\\figurewidth}")
        text = replace(text, r",[\w\s]+? style = \{font = \{\\fontsize\{[\w\s\d\.]*?\}\{[\w\s\d\.]*?\}\\selectfont\}, color = \{rgb,1:red,0.00000000;green,0.00000000;blue,0.00000000\}, draw opacity = 1.0, rotate = 0.0\}" => "")
        text = replace(text, r",[\w\s]+? style = {color = \{rgb,1:red,0.00000000;green,0.00000000;blue,0.00000000\},\n*?draw opacity = 1.0,\n*?line width = 1,\n*?solid(,fill = \{rgb,1:red,1.00000000;green,1.00000000;blue,1.00000000\},font = \{\\fontsize\{[\w\s\d\.]*?\}\{[\w\s\d\.]*?\}\\selectfont})?\}" => "")
        # text = replace(text, r""
        print(temp, text)
    end
    close(temp)
    mv(temppath, filename, force=true)
end

end # module

# cd(@__DIR__)
# plot(randn(100), label="label", title="title", xlabel="xlabel", ylabel="ylabel")
# savefig_pgfplots("test.tex")

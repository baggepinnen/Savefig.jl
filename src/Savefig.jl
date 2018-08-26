module Savefig
using Plots
pgfplots()

function savefig_pgfplots(filename)
    savefig(filename)
    temppath, temp = mktemp()
    pattern = r",\s*axis background/.style={fill={rgb,1:red,\d.\d+;green,\d.\d+;blue,\d.\d+}}"

    text = read(filename,String)
    text = replace(text, pattern => "")
    text = replace(text, r"width = {[\d.]+mm}" => "")
    text = replace(text, r"height = {[\d.]+mm}" => "height = \\figureheight, width = \\figurewidth")
    text = replace(text, r"width = {[\d.]+mm}" => "")
    println(temp, text)

    close(temp)
    mv(temppath, filename, remove_destination=true)
end

end # module

# cd(@__DIR__)
# plot(randn(100), label="label", title="title", xlabel="xlabel", ylabel="ylabel")
# savefig_pgfplots("test.tex")

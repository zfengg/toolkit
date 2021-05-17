### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 6e8d3022-656e-11eb-293c-adc1fb09c818
using PlutoUI, Plots, SymPy # LatexStrings, Latexify, TaylorSeries

# ╔═╡ 3ba54406-656e-11eb-3fbf-3703e3651188
md" # MATH2060A Tutorial 4"

# ╔═╡ 0e798c34-656f-11eb-067a-390731e7ec46
md"""## Ex1. Taylor expansion of $ f(x) = \sin(x)$ 
Taylor expansion at point **p** to the degree **d**: 
"""

# ╔═╡ 54a05a1c-656f-11eb-0e2b-41a5ac5425fa
md"""
##### $ p =$  $(@bind expandPt Slider(-3.2:0.2:3.2, default=0, show_value=true)); $ \quad d = $ $(@bind degreeTP Slider(1:2:20, default=1, show_value=true)) 
"""

# ╔═╡ 549391ce-6574-11eb-3ab3-45ce57368237
begin
	# using SymPy to output the Taylor expansion
	x = symbols("x")
	expr = sin(x)
	taylorExp = expr.series(x, expandPt, degreeTP+1)
	# latexTE = latexify( taylorExp |> string)
end

# ╔═╡ 5c844f8a-6584-11eb-2ede-83ed6a3db0c3
begin
	# function plot_TP()
	# 	myplot = plot(taylorPoly, lLim, rLim, label="TaylorPoly")
	# 	return myplot
	# end
	# begin
	# 	plot_TP()
	# 	plot!(sin, lLim, rLim, label="sin(x)")
	# end
	# myXLim = pi
	# myYLim = 1.5
	md"""XLim = $(@bind myXLim Slider(pi:10, default=pi, show_value=true)) $ \quad $
	YLim = $(@bind myYLim Slider(1.5:10, default=1.5, show_value=true)) 
	"""
	# println(" ")
end

# ╔═╡ 971ded2a-6581-11eb-1371-a93fc95238c1
begin
	ptNum = 10000
	xxx = collect(-myXLim:(myXLim)/ptNum:myXLim)
	taylorPoly = taylorExp.removeO()
	fTaylorPoly = lambdify(taylorPoly)
	plot(xxx,fTaylorPoly.(xxx), label="TP", size=(680,500))
	# plot(fTaylorPoly, -myXLim, myXLim, label="TaylorPoly")
	plot!(sin, -myXLim, myXLim, label="sin(x)", ylim=(-myYLim, +myYLim))
	scatter!((expandPt, sin(expandPt)), markersize = 4, c = :red, label=false)
end

# ╔═╡ d7445655-5c21-4181-991c-e2dfa580deb5
TableOfContents()

# ╔═╡ Cell order:
# ╟─3ba54406-656e-11eb-3fbf-3703e3651188
# ╟─6e8d3022-656e-11eb-293c-adc1fb09c818
# ╟─0e798c34-656f-11eb-067a-390731e7ec46
# ╟─549391ce-6574-11eb-3ab3-45ce57368237
# ╟─54a05a1c-656f-11eb-0e2b-41a5ac5425fa
# ╟─971ded2a-6581-11eb-1371-a93fc95238c1
# ╟─5c844f8a-6584-11eb-2ede-83ed6a3db0c3
# ╟─d7445655-5c21-4181-991c-e2dfa580deb5

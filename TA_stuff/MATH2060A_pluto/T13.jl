### A Pluto.jl notebook ###
# v0.14.5

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

# ╔═╡ 4a7ca994-a32e-11eb-25cf-ebbeceddf50c
begin
	using Pkg
	Pkg.activate(mktempdir())
	
	Pkg.add([
			"Lindenmayer",
			"PlutoUI",
			"Colors",
			"Plots"
			])
	
	using PlutoUI
	using Lindenmayer
	using Plots
	using Colors
	
	TableOfContents()
end

# ╔═╡ 141df477-d7e0-4461-b534-79cc22cc9426
md"# MATH2060A Tutorial 13"

# ╔═╡ 04e5aa9b-a430-4488-b86f-b7f2b3cce366
md"## Schoenberg curve"

# ╔═╡ aaa62391-9dd1-4060-b28a-214391c4b400
md"Iteration of Schoenberg $(@bind part_level Slider(1:9; default=1, show_value=true))"

# ╔═╡ 9078e4af-4a44-4200-a863-15ecc31cff5c
function gen_pts_Schoenberg(part_level::Int)
	
	evenMask = 2 * collect(1:part_level)
	oddMask = evenMask .-1
	binaryBasis = 2.0 .^ collect(1:part_level)
	
	x_pts = zeros(Float64, 4^part_level)
	y_pts = zeros(Float64, 4^part_level)
	countPts = 0

	currentStack = zeros(Int, 2 * part_level)
	while currentStack[1] <= 1

		# generate x and y coordinates
		countPts += 1
		x_vec = currentStack[oddMask] ./ binaryBasis
		x_pts[countPts] = sum(x_vec)
		
		y_vec = currentStack[evenMask] ./ binaryBasis
		y_pts[countPts] = sum(y_vec)
				
		# renew the currentStack
		currentStack[end] += 1
		for i = (2 * part_level): -1 : 2
			if currentStack[i] > 1
				currentStack[i] = 0
				currentStack[i-1] += 1
			else
				break
			end
		end
		
	end
	
	return x_pts, y_pts
	
end

# ╔═╡ 2f52cc60-584a-4e0f-bbc7-b063145de5fd
x_pts, y_pts = gen_pts_Schoenberg(part_level);

# ╔═╡ b68ba25e-25a4-4d42-9740-91287a617de1
plot(x_pts, y_pts; leg=false, title="Schoenberg curve", xlim=(0, 1), ylim=(0, 1))

# ╔═╡ e6c2cf89-b35a-469a-a3eb-e1d65604b239
md"## Peano curve"

# ╔═╡ 36882c28-3213-4553-b0b7-94686968cdb7
md"iteration of Peano curve $(@bind itr_peano Slider(1:6; default=1, show_value=true)) $ \quad $ Fix container $(@bind fix_peano CheckBox(default=false)) "

# ╔═╡ 21c881e3-f169-4732-b880-e046509bb3c6
peano_curve = LSystem(Dict(
   "L" => "LFRFL-F-RFLFR+F+LFRFL",
   "R" => "RFLFR+F+LFRFL-F-RFLFR"),
   "L") # 90°

# ╔═╡ be9c89f4-51dd-481e-905f-02418d419c59
drawLSystem(peano_curve; 
			forward=400/(3^itr_peano - fix_peano),
			turn=90, 
			iterations=itr_peano,
			startingx=-200,
			startingy=200,
			width = 680,
			height = 500)

# ╔═╡ 93474297-10d8-4838-8d98-e0424ef867d0
md"## Hilbert curve"

# ╔═╡ 7c087952-041b-41fa-9d72-bad86d3019e9
md"iteration of Hilbert curve $(@bind itr_hilbert Slider(1:9; default=1, show_value=true)) $ \quad $ Fix container $(@bind fix_hilbert CheckBox(default=false))"

# ╔═╡ 9edc2d25-6923-44c0-8c07-d1f3b5d303c0
hilbert_curve = LSystem(Dict(
   "L" => "+RF-LFL-FR+",
   "R" => "-LF+RFR+FL-"),
   "3L") # 90°

# ╔═╡ 5d28a123-a8f7-4232-99d2-de0c07e4ad08
drawLSystem(hilbert_curve;
			forward=400/(2^itr_hilbert- fix_hilbert), 
			turn=90, 
			iterations=itr_hilbert,
			startingx=-200,
			startingy=-200,
			# backgroundcolor = RGB(0.1, 0.05, 0.15),
			width = 680,
			height = 500)

# ╔═╡ Cell order:
# ╟─141df477-d7e0-4461-b534-79cc22cc9426
# ╠═4a7ca994-a32e-11eb-25cf-ebbeceddf50c
# ╟─04e5aa9b-a430-4488-b86f-b7f2b3cce366
# ╟─aaa62391-9dd1-4060-b28a-214391c4b400
# ╟─b68ba25e-25a4-4d42-9740-91287a617de1
# ╟─9078e4af-4a44-4200-a863-15ecc31cff5c
# ╟─2f52cc60-584a-4e0f-bbc7-b063145de5fd
# ╟─e6c2cf89-b35a-469a-a3eb-e1d65604b239
# ╟─36882c28-3213-4553-b0b7-94686968cdb7
# ╟─be9c89f4-51dd-481e-905f-02418d419c59
# ╟─21c881e3-f169-4732-b880-e046509bb3c6
# ╟─93474297-10d8-4838-8d98-e0424ef867d0
# ╟─7c087952-041b-41fa-9d72-bad86d3019e9
# ╟─5d28a123-a8f7-4232-99d2-de0c07e4ad08
# ╟─9edc2d25-6923-44c0-8c07-d1f3b5d303c0

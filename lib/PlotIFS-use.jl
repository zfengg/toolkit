### A Pluto.jl notebook ###
# v0.20.4

#> [frontmatter]
#> title = "Plot IFS attractors"
#> date = "2025-05-15"
#> tags = ["IFS", "self-affine", "Weierstrauss", "attractor"]
#> description = "A Pluto.jl notebook to plot attractors of IFSs via chaos game."
#> 
#>     [[frontmatter.author]]
#>     name = "Zhou Feng"

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ e8e2c9d5-15a6-4a3a-81b7-a10c32290f79
begin
	# using DrWatson
	# quickactivate(findproject())
	# using Colors, ColorVectorSpace, FileIO
	using  ColorSchemes
	using PlutoUI, HypertextLiteral
	using Plots
end

# ╔═╡ bceaed57-0485-41fc-9294-05fcebf8c3c5
# IFS structs and basic utilities.
module IFSs
using Distributions

export IFS, WIFS, IFSNonlinear
export itrPtsProb

## structs
struct IFS
	linear::Vector{Matrix{Float64}}
	trans::Vector{Vector{Float64}}
	numMaps::Int
	dimAmbient::Int

	IFS(linear::Vector{Matrix{Float64}}, trans::Vector{Vector{Float64}}, numMaps::Int, dimAmbient::Int) = new(linear, trans, numMaps, dimAmbient)
	IFS(linear::Vector{Matrix{Float64}}, trans::Vector{Vector{Float64}}) = IFS(linear, trans, size(trans, 1), size(trans[1], 1))

end

mutable struct WIFS
	linear::Vector{Matrix{Float64}}
	trans::Vector{Vector{Float64}}
	weights::Vector
	numMaps::Int
	dimAmbient::Int

	WIFS(linear::Vector{Matrix{Float64}}, trans::Vector{Vector{Float64}}, weights::Vector) = isprobvec(weights) ? new(linear, trans, weights, size(trans, 1), size(trans[1], 1)) : error("Not prob. vec!")
	WIFS(ifs::IFS, weights::Vector) = WIFS(ifs.linear, ifs.trans, weights)
	# WIFS(ifs::IFS, weights::Vector) = isprobvec(weights) ? new(ifs.linear, ifs.trans, weights, ifs.numMaps, ifs.dimAmbient) : error("Not prob. vec!")
	WIFS(ifs::IFS) = WIFS(ifs, ones(ifs.numMaps) ./ ifs.numMaps)

end

struct IFSNonlinear
	maps::Vector{Function}
	weights::Vector
	numMaps::Int
	dimAmbient::Int

	IFSNonlinear(maps::Vector{Function}, weights::Vector, dimAmbient::Int) = new(maps, weights, size(maps, 1), dimAmbient)
	IFSNonlinear(maps::Vector{Function}, dimAmbient::Int) = new(maps, ones(size(maps, 1)) ./ size(maps, 1), size(maps, 1), dimAmbient)
end

## functions
"""
Iterate points via probabilistic method.
"""
function itrPtsProb(linearIFS::Vector{Matrix{Float64}}, transIFS::Vector{Vector{Float64}}, 
	weights::Vector{Float64}, maxNumPts::Int, initPt)::Vector{Vector{Float64}}
	probDistr = Categorical(weights)
	ptsSet = fill(zeros(Float64, 2), maxNumPts)
	ptsSet[1] = initPt
	for i = 2:maxNumPts
		temptIndex = rand(probDistr)
		ptsSet[i] = linearIFS[temptIndex] * ptsSet[i - 1] + transIFS[temptIndex]
	end
	return ptsSet
end
getFixedPt(linear, trans) = ([1 0; 0 1] - linear[1]) \ trans[1]
itrPtsProb(linear, trans, weight, maxNumPts) = itrPtsProb(linear, trans, weight, maxNumPts, getFixedPt(linear, trans))
itrPtsProb(wifs::WIFS, maxNumPts::Int) = itrPtsProb(wifs.linear, wifs.trans, wifs.weights, maxNumPts)
itrPtsProb(wifs::WIFS, maxNumPts::Int, initPt) = itrPtsProb(wifs.linear, wifs.trans, wifs.weights, maxNumPts, initPt)
itrPtsProb(ifs::IFS, maxNumPts::Int) = itrPtsProb(WIFS(ifs), maxNumPts)
itrPtsProb(ifs::IFS, maxNumPts::Int, initPt) = itrPtsProb(WIFS(ifs), maxNumPts, initPt)
function itrPtsProb(ifs::IFSNonlinear, maxNumPts::Int=1000, initialPt::Vector{Float64}=[0., 0.])
	maps = ifs.maps
	probDistr = Categorical(ifs.weights)
	ptsSet = fill(zeros(Float64, 2), maxNumPts)
	ptsSet[1] = initialPt
	for i = 2:maxNumPts
		ptsSet[i] = maps[rand(probDistr)](ptsSet[i - 1])
	end
	return ptsSet
end

"add methods to determine the shape of IFS"
# size(wifs::WIFS) = size(wifs.trans, 1), size(wifs.trans[1], 1)
# size(ifs::IFS) = size(ifs.trans, 1), size(ifs.trans[1], 1)

## PredefinedIFS
"PredefinedIFS as a module"
module PredefinedIFS

import ..IFS
import ..WIFS

SierpinskiTriangle = IFS([[1 / 2 0; 0 1 / 2],
				  [1 / 2 0; 0 1 / 2],
				  [1 / 2 0; 0 1 / 2]],
				 [[0, 0],
				  [1 / 2, 0],
				  [1 / 4, 1 / 4 * sqrt(3)]])

BarnsleyFern = WIFS([[0  0; 0 0.16],
					 [ 0.85  0.04; -0.04 0.85],
					 [ 0.2  -0.26; 0.23 0.22],
					 [-0.15  0.28; 0.26 0.24]],
					[[0, 0],
					 [0, 1.6],
					 [0, 1.6],
				 	 [0, 0.44]],
					[0.01, 0.84, 0.08, 0.07])

HeighwayDragon = IFS([[1 / 2 -1 / 2; 1 / 2 1 / 2],
					[-1 / 2 -1 / 2; 1 / 2 -1 / 2]],
					[[0., 0.], [1.,0.]])

Twindragon = IFS([[1 / 2 -1 / 2; 1 / 2 1 / 2],
					[-1 / 2 1 / 2; -1 / 2 -1 / 2]],
					[[0., 0.], [1., 0.]])

Terdragon = IFS([[1 / 2 1 / (2 * sqrt(3)); -1 / (2 * sqrt(3)) 1 / 2],
					[0 -1 / sqrt(3); 1 / sqrt(3) 0],
					[1 / 2 1 / (2 * sqrt(3)); -1 / (2 * sqrt(3)) 1 / 2]],
					[[0, 0], [1 / 2, -1 / (2 * sqrt(3))], [1 / 2, 1 / (2 * sqrt(3))]])

function BaranskiCarpet(v::Vector=[0.3, 0.7], h::Vector=[0.1, 0.8, 0.1], pos::Matrix=[1 0 1; 0 1 1])::IFS
	pos = reverse(pos; dims=1)
	linear = [ [h[x[2]] 0; 0 v[x[1]]] for x in findall(pos .> 0)]
	trans = [ [sum(h[1:x[2] - 1]),  sum(v[1:x[1] - 1])] for x in findall(pos .> 0)]

	return IFS(linear, trans)
end

BedMcCarpet(pos::Matrix=[1 0 1; 0 1 1]) = BaranskiCarpet(ones(size(pos, 1)) ./ size(pos, 1), ones(size(pos, 2)) ./ size(pos, 2), pos)

# function BedMcCarpet(v::Int, h::Int, pos::Matrix)::IFS
# 	pos = reverse(pos; dims=1)
# 	numMaps = sum(pos)
# 	linear = fill([1.0/h 0.; 0 1.0/v], numMaps)
# 	trans = [ [(x[2]-1.0)/h, (x[1]-1)/v] for x in findall(pos .> 0)]

# 	return IFS(linear, trans)
# end

end # end of module PredefinedIFS
end # end of module IFS

# ╔═╡ 03386e5e-937b-4e32-b034-e1689834e0dc
TableOfContents(depth=2)

# ╔═╡ fe69d7ee-aa66-11eb-0e4e-e16fc28be586
md"# Plot IFS attractors via chaos game"

# ╔═╡ df738342-cb99-4a8e-9565-2b9422caaee2
md"# Affine IFS"

# ╔═╡ 5362df05-9334-479c-a11d-2c1cf6f664d5
md"""
## Setup
"""

# ╔═╡ cffe70b9-17bc-467a-b2c1-7a01e46ce494
begin
	# set the parameters
	linearIFS = [[0  0; 0 0.16],
				 [0.85  0.04; -0.04 0.85 ],
				 [0.2  -0.26; 0.23 0.22],
				 [-0.15  0.28; 0.26 0.24]]
	transIFS = [[0, 0],
				[0, 1.6],
				[0, 1.6],
				[0, 0.44]]
	weights = [0.01, 0.84, 0.08, 0.07]

	# linearIFS = [[1/3 0; 0 1/2],
	# 			 [1/3 0; 0 1/2],
	# 			 [1/3 0; 0 1/2]]
	# transIFS = [[0, 0],
	# 			[2/3, 0],
	# 			[1/3, 1/2]]
	# weights = [15/32, 15/32, 1/16]
end;

# ╔═╡ 52ea8214-351a-4685-b4c6-feeda6df60a0
md"""
## Examples
"""

# ╔═╡ b87c45ac-1a61-49c7-a0fd-102ea9a45cd8
md"""
Use example? $(@bind isExample CheckBox(default=true))
"""

# ╔═╡ 1133d30a-8c54-48da-88d6-da06585781b5
begin
	# # Bernsley fern
	# exLinear = [[0  0; 0 0.16],
	# 			 [0.85  0.04; -0.04 0.85 ],
	# 			 [0.2  -0.26; 0.23 0.22],
	# 			 [-0.15  0.28; 0.26 0.24]]
	# exTrans = [[0, 0],
	# 			[0, 1.6],
	# 			[0, 1.6],
	# 			[0, 0.44]]
	# exWeight = [0.01, 0.84, 0.08, 0.07]
	
	# # Morris-Shmerkin Figure 2
	# exLinear = 2.0^(-11/12) .* [
	# 	[1 -sqrt(2); 1 0],
	# 	[0 1; -sqrt(2) 1],
	# ]
	# exTrans = [
	# 	[-1., -1], 
	# 	[1, 1]
	# ]
	# exWeight = ones(2) ./ 2

	# # Morris Example 1
	# exLinear = [[-13/27 0; 0 7/9],
	# 			[0 13/27; 7/9 0]]
	# exTrans = [[13/27., 2/9], [14/27, 0]]
	# exWeight = ones(2) ./ 2

	# Morris Example 2
	exLinear = [
		[1/3 0; 0 2/3],
		[-2/3 0; 0 -1/3],
		[0 2/9; -1/3 0],
		[0 4/9; -1/3 0]
	] 
	exTrans = [
		[2/3, 0],
		[2/3, 1],
		[2/3, 1],
		[2/9, 2/3]
	]
	exWeight = ones(4) ./ 4
	
end;

# ╔═╡ 19373c06-e44b-4640-8ffd-a630e4d2586d
md"""
The created IFS is
"""

# ╔═╡ e503bc26-1c46-43dd-8631-698e64b2eb21
# create the weighted IFS
if isExample
	myWIFS = IFSs.WIFS(exLinear, exTrans, exWeight)
else
	myWIFS = IFSs.WIFS(linearIFS, transIFS, weights)
end

# ╔═╡ 59e300ef-d93b-4049-a431-b7c6ac78ba9e
md"""
numPts: $(@bind numPts Slider(10000 : 10000 : 1000000; default= 500000, show_value=true))
"""

# ╔═╡ 8a1f751a-11ad-4595-b937-ae81828da28d
md"""
Color: $(@bind myColor ColorStringPicker(default="#00000"))
"""

# ╔═╡ 9621196a-2465-4ae9-bbc3-bc6281fbad6a
begin
	# plot settings
	figSize = (2000, 2000) # figure size
end;

# ╔═╡ e8c15b61-1e15-4412-9370-fd9e5d0efa78
md"""
### Save the figure? $(@bind shouldSave CheckBox(default=false))
"""

# ╔═╡ f79b9354-c179-4189-878d-8cedf17eccea
md"""
Below please input the filename to save the figure:
"""

# ╔═╡ ce4d9abb-a298-424c-a532-c8bc0c96fade
fn = "Barnsley.png";

# ╔═╡ 6f2306ed-320f-45dc-a5ac-9407d6e4d5e9
md"""
Supported formats: `png`, `pdf`, `svg`...
"""

# ╔═╡ 87b32b70-a405-42db-87bd-16a44644e334
md"## Gallery"

# ╔═╡ 24f874d6-93f6-4f53-941c-4cc3cf56963b
md"""
numPts: $(@bind maxNumPts Slider(1000:1000:1000000; default=200000, show_value=true)) `` \quad `` Example: $(@bind selectIFS MultiSelect([ "SierpinskiTriangle" => "Sierpinski Triangle", 
							"BedMcCarpet" => "Bedford-MacMullen Carpet", 
							"BaranskiCarpet" => "Baranski Carpet",
							"HeighwayDragon" => "Heighway Dragon",
							"Twindragon" => "Twindragon",
							"Terdragon" => "Terdragon",
 							"BarnsleyFern" => "Barnsley Fern",
							];
							default=["SierpinskiTriangle"])) `` \quad `` Color: $(@bind galleryColor ColorStringPicker(default="#0053FA"))
"""

# ╔═╡ f364abae-db0a-42a5-a3f2-3d91d5ef5723
md"""
### Save the gallery picture? $(@bind saveGallery CheckBox(default=false))
"""

# ╔═╡ 5f8abed9-0be7-43c7-a6a5-8f93a94eb5ce
md"### Bedford-MacMullen carpet setup:"

# ╔═╡ e63a2bee-5b49-4b73-8598-fcf8c17b478a
posBM = [0 1 0;
		 1 0 1];

# ╔═╡ 106cbdcb-8041-40e4-924a-4693c8d2ea10
md"
### Baranski carpet setup:"

# ╔═╡ e46ee341-23bb-45a0-8e00-58afdd825634
begin
	 vv = [0.6, 0.2, 0.2]
	 hh = [0.5, 0.1, 0.1, 0.3]
end;

# ╔═╡ 2ca1aa8e-4450-43a2-a15a-ba5d5e2a652f
posB = [1 1 0 1; 
	   1 0 0 1; 
	   0 1 1 1];

# ╔═╡ dc9d671f-5279-4c8f-a4ef-9ee31ce49e76
begin
	if selectIFS[1] == "myIFSNonlinear"
		ptsSet = IFSs.itrPtsProb(myIFSNonlinear, maxNumPts)
	else
		itrIFS = eval(Meta.parse("IFSs.PredefinedIFS." * selectIFS[1]))
		if selectIFS[1] in ["SierpinskiTriangle", "BarnsleyFern", "HeighwayDragon", "Twindragon", "Terdragon"]
			ptsSet = IFSs.itrPtsProb(itrIFS, maxNumPts)
		elseif selectIFS[1] == "BedMcCarpet"
			ptsSet = IFSs.itrPtsProb(itrIFS(posBM), maxNumPts)
		else
			ptsSet = IFSs.itrPtsProb(itrIFS(vv, hh, posB), maxNumPts)
		end
	end
end;

# ╔═╡ 61e39db5-43ac-4297-97d1-35ed1c42c462
md"""
# Nonlinear IFS
"""

# ╔═╡ 402f368a-5cd0-4313-866c-9ff2df19bd32
md"""
## General setup
"""

# ╔═╡ d3e449f3-6318-4d9d-87ee-12d0733b65c9
begin
	# define the maps in IFS

	f_IFS = Function[]
	push!(f_IFS, x -> [0.7*x[1]^2 + x[2], x[2] ^ 3])
	push!(f_IFS, x -> [0.9* x[1] * x[2] + 1, -0.5 * x[1]])
	numMaps = length(f_IFS)

	# f(x) = [1/1000 * x[1] - 9/10, 1/1000 * x[2] - 9/10]
	# g(x) = [-19/20 * x[2], 19/20 * x[1]]
	# h(x) = 1 / (2 * (x[1]^2 + (x[2]-2)^2)) .* [ x[1]^2 + x[2] * (x[2]-2), 2 * x[1]]
	
	weightNL = ones(numMaps) ./ numMaps
	nlIFS = IFSs.IFSNonlinear(f_IFS, weightNL, numMaps)
	
	initPtNL = [0., 0.]
	nlfn = "nolinear.png"
end;

# ╔═╡ ceffdad9-8532-4ab6-b19a-a5c7fae0ebac
md"""
numPts: $(@bind numPtsNL Slider(10000 : 10000 : 10 * 10^5; default= 500000, show_value=true))
"""

# ╔═╡ a5290c8e-99fe-49d7-b622-9ebca55b8be2
md"""
Color: $(@bind mcNL ColorStringPicker(default="#DA0B0B"))
"""

# ╔═╡ 9b8d5d08-9139-46a4-876c-ae89fa16ee2f
md"""
## Graphs of Weierstrauss type functions
"""

# ╔═╡ 85ed7b21-6486-408b-96ee-3234a8311ef4
begin
	# ratios
	b = 2;
	λ = (√5 - 1)/2;

	ψ(x) = - (x - 1/2)^2 + 1/4

	## examples:
	# ψ(x) = - cos(2 * π * x); # classical Weierstrauss
	# ψ(x) = x < 1/2 ? x/2 : 1/2 - x/2 # Takagi
	# ψ(x) = x < 1/2 ? -1 : 1 # limit Rademacher
	# ψ(x) = x < 1/2 ? 3 * x : 3 - 3 * x # tent map
	
	f_Weier = Function[]
	for i in 1:b
		push!(f_Weier, x ->  [1/b * x[1] + (i-1)/b, λ * x[2] + ψ(x[1])])
	end
	weight_Weier = ones(b) ./ b
	WeierIFS = IFSs.IFSNonlinear(f_Weier, weight_Weier, b)
	initPt_Weier = [0., 0.]
end;

# ╔═╡ 17609d92-37b3-42fc-afa9-476d4478f5bb
md"""
numPts: $(@bind numPts_Weier Slider(10000 : 10000 : 10 * 10^5; default= 500000, show_value=true))
"""

# ╔═╡ fe3f5cf4-90a6-47f0-b856-3f9a88e00b8d
md"""
Color: $(@bind mc_Weier ColorStringPicker(default="#0053FA"))
"""

# ╔═╡ 37d05059-ea3f-42c0-8cc2-1fece7c146e7
md"""
## Sunflower
"""

# ╔═╡ eac96959-8b97-4538-81ee-b4ee6a4dc171
begin
	R = 12 # num of pedals
	L = 30 # num of maps in each pedal

	# prep
	rot(θ) = [cos(θ) -sin(θ); sin(θ) cos(θ)]
	
	# inner rotation and translation
	angInner = π / 4
	ratioCtr = 1 # > 1
	sep = 0.0001 # sep of maps in each pedal
	xStart = ratioCtr
	f_sf = Function[]
	for i in 1:L
		push!(f_sf, x -> ratioCtr * rot(angInner * i) * x + [xStart + (i-1) * 2 * ratioCtr, ratioCtr])
	end
	
	# Mobius
	Mob(x) = 1/2 * 1/(x[1]^2 + (x[2]+1)^2) * [x[1]^2+x[2]^2-1, 2*x[1]] - [1/2, 0]
	
	# nonconformal strech
	ratioAff = 1.2
	Aff(x) = [1 0; 0 ratioAff] * x
	
	# outer rotation
	angOuter = 2 * pi / R
	g_sf = Function[]
	for j in 1:R
		push!(g_sf, x -> rot(angOuter * j) * x)
	end

	# construct IFS
	IFS_sf = Function[]
	for i in 1:L, j in 1:R
		push!(IFS_sf, g_sf[j] ∘ Aff ∘ Mob ∘ f_sf[i])
	end
	y = IFS_sf[1]([xStart + L * (sep + 2 * ratioCtr), ratioCtr])
	push!(IFS_sf, x -> sqrt(y[1]^2+y[2]^2) * x)
	numMapSF = R * L + 1
	weightSF = ones(numMapSF) ./ numMapSF
	
	sunflowerIFS = IFSs.IFSNonlinear(IFS_sf, weightSF, numMapSF)
	
	# plot setting
	initPtSF = [0., 0.]
end;

# ╔═╡ a1fee67a-dad9-48d1-9c33-937f206e22e3
md"""
numPts: $(@bind numPtsSF Slider(10000 : 10000 : 10 * 10^5; default= 500000, show_value=true))
"""

# ╔═╡ b8421623-1e8d-43b8-9661-dbeb03afcf3b
md"""
Color: $(@bind mcSF ColorStringPicker(default="#0053FA"))
"""

# ╔═╡ c728a74d-1c6b-4f49-861c-94609a7047e9
md"""
## Ikeda map
"""

# ╔═╡ 429c2276-5b98-48c5-b41b-f67ddf40c760
md"""
Parameter of ikeda: $(@bind paramIkeda Slider(0.: 0.001 : 1.; default = 0.908, show_value=true))
"""

# ╔═╡ 009ff44d-e429-45ee-b681-a96c7d2e77d6
begin
	mapIkeda(x) = [1 + paramIkeda * (x[1] * cos(0.4 - 6 / (1 + x[1] ^ 2 + x[2]^2)) - x[2] * sin(0.4 - 6 / (1 + x[1] ^ 2 + x[2]^2))), paramIkeda * (x[1] * sin(0.4 - 6 / (1 + x[1] ^ 2 + x[2]^2)) + x[2] * cos(0.4 - 6 / (1 + x[1] ^ 2 + x[2]^2)))]
	
	mapId(x) = (x)
	
	IFSikeda = IFSs.IFSNonlinear([mapIkeda, mapId], [1., 0], 2)
end

# ╔═╡ b32965e0-8acd-4e45-9cc5-dfb878f80cee
md"""
numPts: $(@bind numPtsIkeda Slider(10000 : 10000 : 10 * 10^5; default= 500000, show_value=true))
"""

# ╔═╡ fb1314ca-9917-464a-9e7b-00b6718ac781
md"""
Color: $(@bind mcIkeda ColorStringPicker(default="#000000"))
"""

# ╔═╡ 3ba4d982-b95b-40e0-9844-b4801b7a1e89
md"# Appendix"

# ╔═╡ 7afa357b-4483-4cff-8b12-9401d42ea53b
function plot_ptsSet(ptsSet::Vector{Vector{Float64}}, mc::String="#000000")
	xPtsSet = [x[1] for x in ptsSet]
	yPtsSet = [x[2] for x in ptsSet]
	scatter(xPtsSet, yPtsSet, 
			leg=false,
			markershape=:circle,
			markeralpha=0.7;
			markersize=1,
			markercolor=mc,
			# markerstroke=false,
    		markerstrokewidth = 0,
    		# markerstrokealpha = 0.2,
			# grid=false,
			showaxis=false,
			ticks=false,
			xlims=extrema(xPtsSet),
			ylims=extrema(yPtsSet),
			size= figSize
	)
end

# ╔═╡ 5c10f0b0-2275-459d-a6a2-357c8dfb1af1
# generate and plot the points
myplt = plot_ptsSet(IFSs.itrPtsProb(myWIFS, numPts), myColor)

# ╔═╡ 15ecc17a-d5c4-45a6-9266-2520a895eb16
if shouldSave
	savefig(myplt, fn)
		@htl("""
	
	<div class='blue-background'>
	🎉 The above figure is saved as <span style="color:blue;">$(fn) </span> !
	</div>
	
	<style>
	.blue-background {
		padding: .5em;
		background: #D2FBA4;
		color: black;
	}
	</style>
	
	""")
else
	@htl("""
	
	<div class='blue-background'>
	⚠️ The above figure is not saved yet!
	</div>
	
	<style>
	.blue-background {
		padding: .5em;
		background: lightyellow;
		color: black;
	}
	</style>
	
	""")
end

# ╔═╡ 5a59bd1c-71e2-44dd-a143-2b3594ddc738
galleryPlt = plot_ptsSet(ptsSet, galleryColor)

# ╔═╡ 88e2cfb4-801b-4780-bf0f-8b5d4b087f9e
if saveGallery
	tmpFn = selectIFS[1] * ".png"
	savefig(galleryPlt, tmpFn)
	@htl("""
	
		<div class='blue-background'>
		This gallery picture saved as <span style="color:blue;">$(tmpFn) </span> !
		</div>
		
		<style>
		.blue-background {
			padding: .5em;
			background: #D2FBA4;
			color: black;
		}
		</style>
		
	""")
end

# ╔═╡ 10c1056d-662e-4b43-9048-87069bbb4017
nlplt = plot_ptsSet(IFSs.itrPtsProb(nlIFS, numPtsNL, initPtNL), mcNL)

# ╔═╡ 6b6b2b17-d990-4d88-8fd5-bbd389bfe604
graph_Weier = plot_ptsSet(IFSs.itrPtsProb(WeierIFS, numPts_Weier, initPt_Weier), mc_Weier)

# ╔═╡ adfa6e0c-9a05-4ad5-b7b5-24e5d7888d31
sunflower = plot_ptsSet(IFSs.itrPtsProb(sunflowerIFS, numPtsSF, initPtSF), mcSF)

# ╔═╡ b6777b5a-b68b-469a-bedd-aed88066eae5
pltIkeda = plot_ptsSet(IFSs.itrPtsProb(IFSikeda, numPtsIkeda), mcIkeda)

# ╔═╡ ac80253a-3422-4457-a51b-6baa5b48ce4f
begin
	show_image(M, n) = get.([ColorSchemes.Greys], M ./ n)
	show_image(M) = show_image(M, maximum(M))
	show_image(x::AbstractVector) = show_image(x')
end

# ╔═╡ e07906f7-a618-46e1-bd2f-4e053ca6d21e
show_image(posBM);

# ╔═╡ 756ceebb-fcaf-4786-8a13-52c150b844f0
begin
	m, n = size(posB)
	matB = similar(posB, Float64)
	for i in 1:m
		for j in 1:n
			matB[i, j] = vv[i] * hh[j] * posB[i, j]
		end
	end
	show_image(matB)
end;

# ╔═╡ 210c8db0-5083-470c-811b-1aca62ee24b2
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
ColorSchemes = "~3.20.0"
Distributions = "~0.25.75"
HypertextLiteral = "~0.9.4"
Plots = "~1.37.2"
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "3630e94b3ce64f6bf1a25d07e95e8a492b9a1b42"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "03aa5d44647eaec98e1920635cdfed5d5560a8b9"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.117"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d55dffd9ae73ff72f1c0482454dcf2ec6c6c4a63"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.5+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "21fac3c77d7b5a9fc03b0ec503aa1a6392c34d2b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.15.0+0"

[[deps.Formatting]]
deps = ["Logging", "Printf"]
git-tree-sha1 = "fb409abab2caf118986fc597ba84b50cbaf00b87"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.3"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "786e968a8d2fb167f2e4880baba62e0e26bd8e4e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "846f7026a9decf3679419122b49f8a1fdb48d2d5"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.16+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "4423d87dc2d3201f3f1768a29e807ddc8cc867ef"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "3657eb348d44575cc5560c80d7e55b812ff6ffe1"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01979f9b37367603e2848ea225918a3b3861b606"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "2bd56245074fab4015b9174f24ceba8293209053"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.27"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "71b48d857e86bf7a1838c4736545699974ce79a2"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.9"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eac1206917768cb54957c65a615460d87b455fc1"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "8c57307b5d9bb3be1ff2da469063628631d4d51e"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.21"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    DiffEqBiologicalExt = "DiffEqBiological"
    ParameterizedFunctionsExt = "DiffEqBase"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    DiffEqBase = "2b5f629d-d688-5b77-993f-72d75c75574e"
    DiffEqBiological = "eb300fae-53e8-50a0-950c-e21f52c2b7e0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "ff3b4b9d35de638936a525ecd36e86a8bb919d11"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "df37206100d39f79b3376afb6b9cee4970041c61"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.51.1+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89211ea35d9df5831fca5d33552c02bd33878419"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.3+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e888ad02ce716b319e6bdb985d2ef300e7089889"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.3+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "cc0a5deefdb12ab3a096f00a6d42133af4560d71"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ad31332567b189f508a3ea8957a2640b1147ab00"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+1"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "966b85253e959ea89c53a9abebbf2e964fbf593b"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.32"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3b31172c032a1def20c98dae3f2cdc9d10e3b561"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.1+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "dadd6e31706ec493192a70a7090d369771a9a22a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.37.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "7e71a55b87222942f0f9337be62e26b1f103d3e4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.61"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9da16da70037ba9d701192e27befedefb91ec284"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.2"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "85c7811eddec9e7f22615371c3cc81a504c508ee"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+2"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5db3e9d307d32baba7067b13fc7b5aa6edd4a19a"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.36.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "9dafcee1d24c4f024e7edc92603cedba72118283"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+3"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e9216fdcd8514b7072b43653874fd688e4c6c003"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.12+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89799ae67c17caa5b3b5a19b8469eeee474377db"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.5+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d7155fea91a4123ef59f42c4afb5ab3b4ca95058"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+3"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "6fcc21d5aea1a0b7cce6cab3e62246abd1949b86"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.0+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "984b313b049c89739075b8e2a94407076de17449"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.2+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a1a7eaf6c3b5b05cb903e35e8372049b107ac729"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.5+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "b6f664b7b2f6a39689d822a6300b14df4668f0f4"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.4+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a490c6212a0e90d2d55111ac956f7c4fa9c277a6"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+1"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c57201109a9e4c0585b208bb408bc41d205ac4e9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.2+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "1a74296303b6524a0472a8cb12d3d87a78eb3612"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "ab2221d309eda71020cdda67a973aa582aa85d69"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+1"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6dba04dbfb72ae3ebe5418ba33d087ba8aa8cb00"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.1+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522c1df09d05a71785765d19c9524661234738e9"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.11.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "068dfe202b0a05b8332f1e8e6b4080684b9c7700"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.47+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "63406453ed9b33a0df95d570816d5366c92b7809"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+2"
"""

# ╔═╡ Cell order:
# ╟─e8e2c9d5-15a6-4a3a-81b7-a10c32290f79
# ╟─03386e5e-937b-4e32-b034-e1689834e0dc
# ╟─fe69d7ee-aa66-11eb-0e4e-e16fc28be586
# ╟─df738342-cb99-4a8e-9565-2b9422caaee2
# ╟─5362df05-9334-479c-a11d-2c1cf6f664d5
# ╠═cffe70b9-17bc-467a-b2c1-7a01e46ce494
# ╟─52ea8214-351a-4685-b4c6-feeda6df60a0
# ╟─b87c45ac-1a61-49c7-a0fd-102ea9a45cd8
# ╠═1133d30a-8c54-48da-88d6-da06585781b5
# ╟─19373c06-e44b-4640-8ffd-a630e4d2586d
# ╟─e503bc26-1c46-43dd-8631-698e64b2eb21
# ╟─59e300ef-d93b-4049-a431-b7c6ac78ba9e
# ╟─8a1f751a-11ad-4595-b937-ae81828da28d
# ╟─5c10f0b0-2275-459d-a6a2-357c8dfb1af1
# ╟─9621196a-2465-4ae9-bbc3-bc6281fbad6a
# ╟─e8c15b61-1e15-4412-9370-fd9e5d0efa78
# ╟─f79b9354-c179-4189-878d-8cedf17eccea
# ╠═ce4d9abb-a298-424c-a532-c8bc0c96fade
# ╟─6f2306ed-320f-45dc-a5ac-9407d6e4d5e9
# ╟─15ecc17a-d5c4-45a6-9266-2520a895eb16
# ╟─87b32b70-a405-42db-87bd-16a44644e334
# ╟─24f874d6-93f6-4f53-941c-4cc3cf56963b
# ╟─5a59bd1c-71e2-44dd-a143-2b3594ddc738
# ╟─dc9d671f-5279-4c8f-a4ef-9ee31ce49e76
# ╟─f364abae-db0a-42a5-a3f2-3d91d5ef5723
# ╟─88e2cfb4-801b-4780-bf0f-8b5d4b087f9e
# ╟─5f8abed9-0be7-43c7-a6a5-8f93a94eb5ce
# ╠═e63a2bee-5b49-4b73-8598-fcf8c17b478a
# ╟─e07906f7-a618-46e1-bd2f-4e053ca6d21e
# ╟─106cbdcb-8041-40e4-924a-4693c8d2ea10
# ╠═e46ee341-23bb-45a0-8e00-58afdd825634
# ╠═2ca1aa8e-4450-43a2-a15a-ba5d5e2a652f
# ╟─756ceebb-fcaf-4786-8a13-52c150b844f0
# ╟─61e39db5-43ac-4297-97d1-35ed1c42c462
# ╟─402f368a-5cd0-4313-866c-9ff2df19bd32
# ╠═d3e449f3-6318-4d9d-87ee-12d0733b65c9
# ╟─ceffdad9-8532-4ab6-b19a-a5c7fae0ebac
# ╟─a5290c8e-99fe-49d7-b622-9ebca55b8be2
# ╟─10c1056d-662e-4b43-9048-87069bbb4017
# ╟─9b8d5d08-9139-46a4-876c-ae89fa16ee2f
# ╠═85ed7b21-6486-408b-96ee-3234a8311ef4
# ╟─17609d92-37b3-42fc-afa9-476d4478f5bb
# ╟─fe3f5cf4-90a6-47f0-b856-3f9a88e00b8d
# ╟─6b6b2b17-d990-4d88-8fd5-bbd389bfe604
# ╟─37d05059-ea3f-42c0-8cc2-1fece7c146e7
# ╠═eac96959-8b97-4538-81ee-b4ee6a4dc171
# ╟─a1fee67a-dad9-48d1-9c33-937f206e22e3
# ╟─b8421623-1e8d-43b8-9661-dbeb03afcf3b
# ╟─adfa6e0c-9a05-4ad5-b7b5-24e5d7888d31
# ╟─c728a74d-1c6b-4f49-861c-94609a7047e9
# ╟─429c2276-5b98-48c5-b41b-f67ddf40c760
# ╟─009ff44d-e429-45ee-b681-a96c7d2e77d6
# ╟─b32965e0-8acd-4e45-9cc5-dfb878f80cee
# ╟─fb1314ca-9917-464a-9e7b-00b6718ac781
# ╟─b6777b5a-b68b-469a-bedd-aed88066eae5
# ╟─3ba4d982-b95b-40e0-9844-b4801b7a1e89
# ╟─7afa357b-4483-4cff-8b12-9401d42ea53b
# ╟─ac80253a-3422-4457-a51b-6baa5b48ce4f
# ╟─210c8db0-5083-470c-811b-1aca62ee24b2
# ╟─bceaed57-0485-41fc-9294-05fcebf8c3c5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

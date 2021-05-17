### A Pluto.jl notebook ###
# v0.12.12

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

# ╔═╡ 587d7c48-532f-11eb-30fe-47a30d219dbf
using Random, Distributions, Plots, LaTeXStrings, PlutoUI

# ╔═╡ 91c9b6ba-54d3-11eb-3f05-ade993f22e1a
md" # MATH2060A Tutorial 1"

# ╔═╡ ff1acbf0-54d3-11eb-3d56-a5182e9275fd
md"## Ex1. $ f_{\alpha}(x) = x^{\alpha} \sin(1/x) $"

# ╔═╡ 582d7ab8-54d3-11eb-2271-03491aac34b4
@bind α html"<input type='range' id = L'\alpha' name='α' min='0' max='3' step='0.01' value='2'>"

# ╔═╡ e4e2566e-54d7-11eb-307a-411e0fc2d884
md"##### α = $α"

# ╔═╡ 7f877302-54d3-11eb-0949-f7a8df25b5d7
begin
	Num2 = 100000;
	# function fAlpha(x, α = 2) return  end;
	x_co = collect(1:floor(Num2/6))./Num2;	
	falpha_y = [z^(α)*sin(1/z) for z in x_co];
	env_y = [z^α for z in x_co];
	
	# derivative
	fprime_y = [α*z^(α-1)*sin(1/z)-z^(α-2)*cos(1/z) for z in x_co];
	envPrime = [z^(α-2) for z in x_co];
	
	alpha1 = 1.5
	xxx = [-x_co x_co];
	feven_y = [abs(z)^(alpha1)*sin(1/abs(z)) for z in xxx];
	envEven_y = [abs(z)^(alpha1) for z in xxx];
	
	println(" ")
end

# ╔═╡ 578c6c7c-54d8-11eb-245d-4fc0cda0dbb3
plot(x_co, [falpha_y env_y -env_y], label=[L"f_{\alpha}" L"+x^{\alpha}" L"-x^{\alpha}"], title = "Envelope-Oscillation")

# ╔═╡ c6fc5c5e-5560-11eb-2826-4718b7b62bef
begin
	plot(x_co, [fprime_y envPrime -envPrime], label = [L"f_{\alpha}^{'}" L"+x^{\alpha-2}" L"-x^{\alpha-2}"],  xlims = (-0.001, 0.12))
	origin = (0,0);
	scatter!(origin, markersize = 6, c = :red, label=false)
end

# ╔═╡ e8ea6962-554b-11eb-3a57-493b08d8588d
md" ### $ \cdot \quad f_\alpha(\lvert x\rvert)=\lvert x\rvert ^{\alpha}\sin(1/\lvert x\rvert)$"

# ╔═╡ 816f265a-554a-11eb-029a-e9a81de5b675
plot(xxx, [feven_y envEven_y -envEven_y], legend = false)

# ╔═╡ 7b829f4c-54e3-11eb-237d-95d0958798ee
md"""## Ex2. Weierstrass function

### $f(x) = \sum_{n=1}^{\infty}\frac{1}{2^{n}}\cos(3^n x)$
"""

# ╔═╡ 7cd8a9e0-54e3-11eb-20bc-39ac818b5b31
begin
		num_wf = 100000;
		sumN = 100;
		x_wf = collect(1:2*num_wf)./num_wf;
		function wf(x) return sum([0.5^n*cos(3^n*x) for n in 1:sumN]) end
		y_wf = [wf(x) for x in x_wf];
		println(" ")
end

# ╔═╡ e0971790-54e4-11eb-1d0f-9b7b8b226ee1
plot(x_wf, y_wf, label=false)

# ╔═╡ dd1f3bbc-54d3-11eb-185a-5380c1f9bcd3
md"## Ex3. 1-dim Brownian Motions"

# ╔═╡ 3772ab96-5cc8-11eb-32f7-c1ce4735fa8a
# plotly()

# ╔═╡ 08b8e6e6-54df-11eb-01c9-e9e02ea7dd01
ptNum = 10000;

# ╔═╡ 23dc9bb0-5332-11eb-21b2-733b5e2d44eb
begin
x = collect(1:ptNum)./ptNum;
g = Normal(0, sqrt(1/ptNum));
pts = rand(g, ptNum);
rw = cumsum(pts);
println(" ")
end

# ╔═╡ bc992c32-5333-11eb-38b6-d5d7c90c451c
plot(x, rw, label = "trajectory")

# ╔═╡ Cell order:
# ╟─91c9b6ba-54d3-11eb-3f05-ade993f22e1a
# ╟─587d7c48-532f-11eb-30fe-47a30d219dbf
# ╟─ff1acbf0-54d3-11eb-3d56-a5182e9275fd
# ╟─578c6c7c-54d8-11eb-245d-4fc0cda0dbb3
# ╟─e4e2566e-54d7-11eb-307a-411e0fc2d884
# ╟─582d7ab8-54d3-11eb-2271-03491aac34b4
# ╟─7f877302-54d3-11eb-0949-f7a8df25b5d7
# ╟─c6fc5c5e-5560-11eb-2826-4718b7b62bef
# ╟─e8ea6962-554b-11eb-3a57-493b08d8588d
# ╟─816f265a-554a-11eb-029a-e9a81de5b675
# ╟─7b829f4c-54e3-11eb-237d-95d0958798ee
# ╟─e0971790-54e4-11eb-1d0f-9b7b8b226ee1
# ╟─7cd8a9e0-54e3-11eb-20bc-39ac818b5b31
# ╟─dd1f3bbc-54d3-11eb-185a-5380c1f9bcd3
# ╟─3772ab96-5cc8-11eb-32f7-c1ce4735fa8a
# ╟─bc992c32-5333-11eb-38b6-d5d7c90c451c
# ╠═08b8e6e6-54df-11eb-01c9-e9e02ea7dd01
# ╟─23dc9bb0-5332-11eb-21b2-733b5e2d44eb

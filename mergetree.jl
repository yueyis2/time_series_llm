### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 8c776746-c13d-4bc6-b468-c96bdd468aa0
import Pkg

# ╔═╡ e117278c-c8cb-4123-891c-6363c3c5a3ea
# ╠═╡ show_logs = false
Pkg.activate(temp=true)

# ╔═╡ 2ed75d2a-50c6-44e0-9974-5ba0e1da2ddb
# ╠═╡ show_logs = false
begin
	Pkg.add(url="https://github.com/JuliaPluto/PlutoUI.jl", rev="DrawCanvas")
	Pkg.add("Loess")
	Pkg.add("Plots")
	Pkg.add("DataStructures")
end

# ╔═╡ 947d8328-c109-449f-a6db-aab0daaa2a66
using PlutoUI, Plots, Loess, DataStructures

# ╔═╡ f7312f93-254a-4395-839d-7136b51821af
md"""### NOTE: 
Please provide only well like functions."""

# ╔═╡ 9c7b7422-72c3-4e59-8943-734ce530ecf1
@bind cb confirm(DrawCanvas(;help=false, output_size=(300,500)))

# ╔═╡ 7eaf8f7a-1c57-4847-ac98-89d3fbc9de97
md"""### TODO: 
Implement some checks for "well"-defined (pun intended) functions."""

# ╔═╡ 5df7dc13-3ca9-454f-80f5-f0eb8ab37475
begin
	sketch = Tuple.(findall(iszero, cb))
	y = map(z->300- z[1] , sketch) |> collect
	x = map(x->x[2], sketch) |> collect
end;

# ╔═╡ 5bc697b6-22d9-4da4-9aef-19269da5eac7
function minmax_pairs(series::AbstractVector)
	mx = maximum(series)
	tser = [Inf, mx+10, series..., mx+10, Inf]
	pers = Deque{Tuple{Real, Integer, Real, Integer, Integer}}()
	stackx = Deque{Tuple{Real, Integer}}()
	stackn = Deque{Tuple{Real, Integer}}()
	up, opos = -1, 0
	
	for (pos, tp) in enumerate(tser[1:end-1])
		(up>0  && !isempty(stackx)) && 
			for i=1:sum(map(x -> first(x) <= tp, stackx))
				push!(pers, (pop!(stackn)..., pop!(stackx)..., pos))
			end
		(up<0 && !isempty(stackn)) &&
			for i=1:sum(map(x -> first(x) >= tp, stackn))
				push!(pers, (pop!(stackn)..., pop!(stackx)..., pos))
			end
		if (up*(tser[pos+1]-tp)<0)
			up > 0 ? push!(stackx, (tser[pos], pos-2)) :
				 push!(stackn, (tser[pos], pos-2))
			up = -up 
		end
		opos = pos
	end
	push!(pers, (pop!(stackn)..., NaN, 1, opos))
end

# ╔═╡ 2a66cd14-c1ac-4234-b39b-f694246441b3
function deque2mat(dq::Deque{Tuple{R, I, R, I, I}}) :: Matrix{R} where R<:Real where I<:Integer
	permutedims(reduce(hcat, map(collect, dq) |> collect))
end

# ╔═╡ c1da9ef4-e59a-4896-b7e1-aa8b0d49b232
begin
	if sketch == []
		plot()
	else
		model = loess(x, y, span=0.2)
		vs = predict(model, x)
		pp1 = plot(x, vs, title="Extracted function", label=false)
		stack_mat_orig = deque2mat(minmax_pairs(vs))
		stack_mat = replace(stack_mat_orig, NaN=>maximum(vs))
		local b, bind, d, dind = stack_mat_orig[:, 1], stack_mat_orig[:, 2], stack_mat_orig[:, 3], stack_mat_orig[:, 4]
		scatter!(pp1, x[bind], b, label="Mins")
		scatter!(pp1, x[dind], d, label="Maxs")
		pp2 = hline([b..., d...], alpha=0.25, label=false, color=:black)
		
		local b, bind, d, dind = stack_mat[:, 1], stack_mat[:, 2], stack_mat[:, 3], stack_mat[:, 4]
		for (y1, xi, y2) in zip(b, bind, d)
			plot!(pp2, [x[xi];x[xi]], [y1;y2], label=false, color=:black, lw=2, title="Bar diagram")
		end
		plot(pp1, pp2, layout=(1,2), ylim=ylims(pp1), size=(600,300))
	end
end

# ╔═╡ Cell order:
# ╠═8c776746-c13d-4bc6-b468-c96bdd468aa0
# ╠═e117278c-c8cb-4123-891c-6363c3c5a3ea
# ╠═2ed75d2a-50c6-44e0-9974-5ba0e1da2ddb
# ╠═947d8328-c109-449f-a6db-aab0daaa2a66
# ╟─f7312f93-254a-4395-839d-7136b51821af
# ╟─9c7b7422-72c3-4e59-8943-734ce530ecf1
# ╟─7eaf8f7a-1c57-4847-ac98-89d3fbc9de97
# ╟─5df7dc13-3ca9-454f-80f5-f0eb8ab37475
# ╟─c1da9ef4-e59a-4896-b7e1-aa8b0d49b232
# ╟─5bc697b6-22d9-4da4-9aef-19269da5eac7
# ╟─2a66cd14-c1ac-4234-b39b-f694246441b3

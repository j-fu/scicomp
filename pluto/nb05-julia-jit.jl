### A Pluto.jl notebook ###
# v0.12.13

using Markdown
using InteractiveUtils

# ╔═╡ baf88246-01d1-11eb-3d35-1393445b1476
begin
	using Pkg; 
	Pkg.activate(mktempdir()); 
	Pkg.add(["PlutoUI","BenchmarkTools"]); 
	using PlutoUI, BenchmarkTools
end

# ╔═╡ 3d6dcce0-252c-11eb-20a8-7f1a5f42a23c
using LinearAlgebra

# ╔═╡ 79bcc848-0a49-11eb-2ef3-e967d80edd4a
md"""
 Julia: just-in-time compilation and Performance
 ========================================

"""

# ╔═╡ c88f5ce0-01db-11eb-0fb6-89bab3e040fa
md"""

## The JIT
 - Just-in-time compilation is another feature setting Julia apart, as it was developed with this possibility in mind. 
 - Julia uses the tools from the [The LLVM Compiler Infrastructure Project](https://llvm.org) to organize on-the-fly compilation  of Julia code to machine code
 - Tradeoff: startup time for code execution in interactive situations
 - Multiple steps: Parse the code, analyze data types etc.
 - Intermediate results can be inspected using a number of macros (blue color in the diagram below) 

"""

# ╔═╡ 084cb828-01dc-11eb-0287-fb577782e74a
html"""
 <img src="https://wias-berlin.de/people/fuhrmann/blobs/julia_introspect.png" width=600 valign=center/><br>

 <font size=-3> From <a href="https://docs.google.com/viewer?a=v&pid=sites&srcid=ZGVmYXVsdGRvbWFpbnxibG9uem9uaWNzfGd4OjMwZjI2YTYzNDNmY2UzMmE">Introduction to Writing High Performance Julia</a> by D. Robinson </font>

"""

# ╔═╡ 3999c2fc-2522-11eb-0ff8-914fac501169
md"""
##### Let us see what is going on:
"""

# ╔═╡ ecb14696-01dc-11eb-2c33-7f0c5f3ed551
g(x,y)=x+y

# ╔═╡ 5ad0f0fa-2522-11eb-2ce5-4b7a57abe32a
md"""
- Call with integer parameter:
"""

# ╔═╡ 03a88b34-01dd-11eb-3a94-478b950f2a9f
g(2,3)

# ╔═╡ 664e0076-2522-11eb-3395-a5b389e9ca3d
md"""
- Call with floating point parameter:
"""

# ╔═╡ 0afad932-01dd-11eb-3f70-fd57c6c6a75a
g(2.0,3.0)

# ╔═╡ 569cbd38-01dd-11eb-053e-ef75f9fd6cc9
md"""
- The macro `@code_lowered` describes the abstract syntax tree behind the code
"""

# ╔═╡ 37eff710-01dd-11eb-39cb-234687629b00
@code_lowered g(2,3)

# ╔═╡ 498c72f0-01dd-11eb-10f7-dd1ad6c77efa
@code_lowered g(2.0,3.0)

# ╔═╡ 86f4a694-01dd-11eb-2ca5-79bd00db755a
md"""
- `@code_warntype` (with output to terminal) provides the result of type inference  (detection ot the parameter types and coorsponding choice of the translation strategy) according to the input:
"""

# ╔═╡ a2a988d4-01dd-11eb-11b7-c762bee44129
with_terminal() do
	@code_warntype g(2,3)
end

# ╔═╡ bcbbc198-01dd-11eb-1852-f37b2a99e0d8
with_terminal() do
	@code_warntype g(2.0,3.0)
end

# ╔═╡ caecc610-01dd-11eb-26c9-a51f007ec79c
md"""
- `@llvm_bytecode` prints the LLVM intermediate byte code representation:
"""

# ╔═╡ e6ad947e-01dd-11eb-0246-f1b267e12159
with_terminal() do
	@code_llvm g(2,3)
end

# ╔═╡ fcba0126-01dd-11eb-3274-8b9f6c44e508
with_terminal() do
	@code_llvm g(2.0,3.0)
end

# ╔═╡ 05a4ab68-01de-11eb-189e-d7677febe4bf
md"""
- Finally, `@code_native` prints the assembler code generated, which is a close match to the machine code sent to the CPU:
"""

# ╔═╡ 184ed632-01de-11eb-2cf0-e98f0dbd45a5
with_terminal() do
	@code_native g(2,3)
end

# ╔═╡ 20ffec3a-01de-11eb-0a08-bd750db2d058
with_terminal() do
	@code_native g(2.0,3.0)
end

# ╔═╡ 53ee961a-2523-11eb-3a0c-a728549123ee
md"""
We see that for the very same function, Julia creates different variants of executable code depending on the data types of the parameters passed. In certain sense, this extends the multiple dispatch paradigm to the lower level by automatically created methods.
"""

# ╔═╡ 55e41caa-01de-11eb-3639-358f2f400252
md"""
## Performance measurment
- Julia provides a number of macros to support performance testing.

- Performance measurement of the first invocation of a function includes the compilation step. If in doubt, measure timing twice.

- Pluto has the nice feature to indicate the execution time used below the lower right corner of a cell. There seems to be also some overhead hidden in the pluto cell handling which is however not measured.
"""

# ╔═╡ 63955be8-01de-11eb-0516-31417b1b2861
md"""
- `@elapsed`: wall clock time used returned as a number.
"""

# ╔═╡ 573e2724-01e0-11eb-3f7b-f342312e13c1
f(n1,n2)= mapreduce(x->norm(x,2),+,[rand(n1) for i=1:n2])

# ╔═╡ 5112bd20-01df-11eb-06a3-713bab78f13d
@elapsed f(1000,1000)

# ╔═╡ a0cd4920-01df-11eb-12a1-e304e689a2e7
md"""
- `@allocated`: sum of memory allocated (including temporary) during the excution of the code. For storing intermediate and final calculation results, computer languages request memory from the operating system. This process is called allocation. Allocations as a rule are linked with lots of bookkeeping, so they can slow down code.
"""

# ╔═╡ bb4cbb14-01df-11eb-1531-7dbaffbb5ad1
@allocated f(1000,1000)

# ╔═╡ 1a76c2f6-01e0-11eb-1ed5-3dc80b013a64
md"""
- `@time`: `@elapsed` and `@allocated` together, with output to the terminal.
   Be careful to time at least twice in order to take into account compilation time.
   In addition, the number of allocations is printed along with time spent for garbage    collection. Garbage collection is the process of returning unused (temporary)     memory to the system.
"""

# ╔═╡ 31b780ea-01e0-11eb-1ae9-1b8ee30e77df
with_terminal() do
	@time f(1000,2000)
end

# ╔═╡ ecf01b06-01e0-11eb-3611-35896a37ad32
md"""
- `@benchmark` from `BenchmarkTools.jl` creates a statistic over multiple samples in order to give a more reliable estimate.
"""

# ╔═╡ c8abc592-01e0-11eb-121f-37f4a714e7bd
@benchmark f(1000,1000)

# ╔═╡ 4ebc18f8-01e1-11eb-314d-01acf9b1800c
md"""
## Some performance gotchas

In order to write efficient Julia code, a number recommendations should be followed.

##### Gotcha #1: global variables
"""

# ╔═╡ 17c403aa-01e2-11eb-2cfd-0d3e0ff854ee
myvec=ones(Float64,1_000_000)

# ╔═╡ 33a16342-01e2-11eb-1d3a-172dc9d4dedd
function mysum(v)
    x=0.0
    for i=1:length(v)
        x=x+v[i]
	end
    return x
end;

# ╔═╡ 3baa562a-01e2-11eb-0256-f9d62751f43b
@elapsed mysum(myvec)

# ╔═╡ 22f910e4-01e2-11eb-2fff-61ec8244e466
@elapsed begin
	x=0.0
    for i=1:length(myvec)
		global x
        x=x+myvec[i]
    end
end

# ╔═╡ 845e9b9c-01e2-11eb-2c9b-4984eeca5ac4
md"""
- Observation: both the begin/end block and the function do the same operation and calculate the same value. However the function is faster.

- The code within the begin/end clause works in the _global context_, whereas in `myfunc`, it works in the scope of  a function. Julia is unable to dispatch on variable types in the global scope as they can change their type anytime. In the global context it has to put all variables into "boxes" tagged with type information allowing to dispatch on their type at runtime (this is by the way the default mode of Python). In functions, it has a chance to generate specific code for known types.

- This situation als occurs in the REPL.
		
- Conclusion: __Avoid  [Julia Gotcha #1](http://www.stochasticlifestyle.com/7-julia-gotchas-handle/) by wrapping time critical code into functions and avoiding the use of global variables.__

- In fact it is anyway good coding style to separate out pieces of code into functions

"""

# ╔═╡ 85611e64-0a4a-11eb-1a31-c9985b9f2642
md"""
##### Gotcha #2: type instabilities
"""

# ╔═╡ fb6974d6-01e3-11eb-258b-9db21b4c39dd
function f1(n)
  x=1
  for i = 1:n
    x = x/2
  end
end

# ╔═╡ 36244b3c-01e4-11eb-3828-2fa69b8b0835
function f2(n)
  x=1.0
  for i = 1:n
    x = x/2
  end
end

# ╔═╡ 57fe324a-01e4-11eb-0608-c93721fe489d
@benchmark f1(10)

# ╔═╡ 5dba7e84-01e4-11eb-0f24-6f39f244cc07
@benchmark f2(10)

# ╔═╡ 862882a6-01e4-11eb-21ef-75d4fed7f04c
md""" 
- Observation: function `f2` is faster than `f1` for the same operations.
"""

# ╔═╡ 87d6bd98-01e4-11eb-0938-4b4bb2f0ae7e
with_terminal() do
		@code_native f1(10)
end

# ╔═╡ bbe41894-01e4-11eb-2fec-27c074cd30ea
with_terminal() do
		@code_native f2(10)
end

# ╔═╡ 32710042-01e5-11eb-169f-e3216fe132df
with_terminal() do
		@code_warntype f1(10)
end

# ╔═╡ 432b3330-01e5-11eb-2eea-830d81a0d8cb
with_terminal() do
		@code_warntype f2(10)
end

# ╔═╡ 7658f634-01e5-11eb-3699-3dd253e48c9e
md"""
- Once again, "boxing" occurs to handle x: in `g()` it changes its type from Int64 to Float64. We see this with the union type for x in @code_warntype
	
- Conclusion: __Avoid  [Julia Gotcha #2](http://www.stochasticlifestyle.com/7-julia-gotchas-handle/) by ensuring variables keep their type also in functions__.
"""

# ╔═╡ ca37ea3e-01e6-11eb-161c-f3c529c6a653
md"""
##### Gotcha #6: allocations
"""

# ╔═╡ a8270820-01e7-11eb-34b4-093d698d80c1
mymat=rand(10,100000)

# ╔═╡ 042c5900-2528-11eb-08ce-91e2310b4ad4
md"""
- Define three different ways of summing of squares of matrix rows:
"""

# ╔═╡ 1a4f2320-01e7-11eb-3dcd-5bc9fb5a2820
function g1(a)
	y=0.0
	for j=1:size(a,2)
		for i=1:size(a,1)
			y=y+a[i,j]^2
		end
	end
	y
end

# ╔═╡ c8cb9d52-01e7-11eb-048e-45dff3378373
function g2(a)
    y=0.0
	for j=1:size(a,2)
		y=y+mapreduce(z->z^2,+,a[:,j])
	end
	y
end

# ╔═╡ 18fd5ee4-01e8-11eb-396e-9ddeef23ead5
function g3(a)
    y=0.0
	for j=1:size(a,2)
		@views y=y+mapreduce(z->z^2,+,a[:,j])
	end
	y
end

# ╔═╡ c37ae8c8-01e7-11eb-0756-13c84f5cec69
g1(mymat)≈ g2(mymat) && g2(mymat)≈ g3(mymat)

# ╔═╡ b1f2f53a-023c-11eb-11be-e389b3f69d69
@benchmark g1(mymat)

# ╔═╡ bba953e4-023c-11eb-1e1e-8f5598ba31c5
@benchmark g2(mymat)

# ╔═╡ 1567a5ca-01e8-11eb-044d-7dab08270d46
@benchmark g3(mymat)

# ╔═╡ 29b6d2aa-01e9-11eb-1ab1-ff180544b940
md"""
- Observation: g3 is the fastest implemetation, then comes g1 and then g2.

- The difference between g2 and g1  is that each time we use a matrix slice `a[:,i]`,
  memory is allocated and data copied. Only then the mapreduce is employed, and the
  intermediate memory is garbage collected.
- The difference between g2 and g1 lies in the use of the `@views` macro which allows to  avoid the creation of intermediae memory for matrix rows.

- Conclusion: avoid [Gotcha #6](http://www.stochasticlifestyle.com/7-julia-gotchas-handle/) __by carefully checking your code for allocations__ and avoiding the use of temporary memory.
"""

# ╔═╡ Cell order:
# ╠═baf88246-01d1-11eb-3d35-1393445b1476
# ╟─79bcc848-0a49-11eb-2ef3-e967d80edd4a
# ╟─c88f5ce0-01db-11eb-0fb6-89bab3e040fa
# ╟─084cb828-01dc-11eb-0287-fb577782e74a
# ╟─3999c2fc-2522-11eb-0ff8-914fac501169
# ╠═ecb14696-01dc-11eb-2c33-7f0c5f3ed551
# ╟─5ad0f0fa-2522-11eb-2ce5-4b7a57abe32a
# ╠═03a88b34-01dd-11eb-3a94-478b950f2a9f
# ╟─664e0076-2522-11eb-3395-a5b389e9ca3d
# ╠═0afad932-01dd-11eb-3f70-fd57c6c6a75a
# ╟─569cbd38-01dd-11eb-053e-ef75f9fd6cc9
# ╠═37eff710-01dd-11eb-39cb-234687629b00
# ╠═498c72f0-01dd-11eb-10f7-dd1ad6c77efa
# ╟─86f4a694-01dd-11eb-2ca5-79bd00db755a
# ╠═a2a988d4-01dd-11eb-11b7-c762bee44129
# ╠═bcbbc198-01dd-11eb-1852-f37b2a99e0d8
# ╟─caecc610-01dd-11eb-26c9-a51f007ec79c
# ╠═e6ad947e-01dd-11eb-0246-f1b267e12159
# ╠═fcba0126-01dd-11eb-3274-8b9f6c44e508
# ╟─05a4ab68-01de-11eb-189e-d7677febe4bf
# ╠═184ed632-01de-11eb-2cf0-e98f0dbd45a5
# ╠═20ffec3a-01de-11eb-0a08-bd750db2d058
# ╟─53ee961a-2523-11eb-3a0c-a728549123ee
# ╟─55e41caa-01de-11eb-3639-358f2f400252
# ╟─63955be8-01de-11eb-0516-31417b1b2861
# ╠═3d6dcce0-252c-11eb-20a8-7f1a5f42a23c
# ╠═573e2724-01e0-11eb-3f7b-f342312e13c1
# ╠═5112bd20-01df-11eb-06a3-713bab78f13d
# ╟─a0cd4920-01df-11eb-12a1-e304e689a2e7
# ╠═bb4cbb14-01df-11eb-1531-7dbaffbb5ad1
# ╟─1a76c2f6-01e0-11eb-1ed5-3dc80b013a64
# ╠═31b780ea-01e0-11eb-1ae9-1b8ee30e77df
# ╟─ecf01b06-01e0-11eb-3611-35896a37ad32
# ╠═c8abc592-01e0-11eb-121f-37f4a714e7bd
# ╟─4ebc18f8-01e1-11eb-314d-01acf9b1800c
# ╠═17c403aa-01e2-11eb-2cfd-0d3e0ff854ee
# ╠═33a16342-01e2-11eb-1d3a-172dc9d4dedd
# ╠═3baa562a-01e2-11eb-0256-f9d62751f43b
# ╠═22f910e4-01e2-11eb-2fff-61ec8244e466
# ╟─845e9b9c-01e2-11eb-2c9b-4984eeca5ac4
# ╟─85611e64-0a4a-11eb-1a31-c9985b9f2642
# ╠═fb6974d6-01e3-11eb-258b-9db21b4c39dd
# ╠═36244b3c-01e4-11eb-3828-2fa69b8b0835
# ╠═57fe324a-01e4-11eb-0608-c93721fe489d
# ╠═5dba7e84-01e4-11eb-0f24-6f39f244cc07
# ╟─862882a6-01e4-11eb-21ef-75d4fed7f04c
# ╠═87d6bd98-01e4-11eb-0938-4b4bb2f0ae7e
# ╠═bbe41894-01e4-11eb-2fec-27c074cd30ea
# ╠═32710042-01e5-11eb-169f-e3216fe132df
# ╠═432b3330-01e5-11eb-2eea-830d81a0d8cb
# ╟─7658f634-01e5-11eb-3699-3dd253e48c9e
# ╟─ca37ea3e-01e6-11eb-161c-f3c529c6a653
# ╠═a8270820-01e7-11eb-34b4-093d698d80c1
# ╟─042c5900-2528-11eb-08ce-91e2310b4ad4
# ╠═1a4f2320-01e7-11eb-3dcd-5bc9fb5a2820
# ╠═c8cb9d52-01e7-11eb-048e-45dff3378373
# ╠═18fd5ee4-01e8-11eb-396e-9ddeef23ead5
# ╠═c37ae8c8-01e7-11eb-0756-13c84f5cec69
# ╠═b1f2f53a-023c-11eb-11be-e389b3f69d69
# ╠═bba953e4-023c-11eb-1e1e-8f5598ba31c5
# ╠═1567a5ca-01e8-11eb-044d-7dab08270d46
# ╟─29b6d2aa-01e9-11eb-1ab1-ff180544b940

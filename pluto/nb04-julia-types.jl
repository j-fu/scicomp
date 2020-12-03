### A Pluto.jl notebook ###
# v0.12.9

using Markdown
using InteractiveUtils

# ╔═╡ baf88246-01d1-11eb-3d35-1393445b1476
using Pkg; Pkg.activate(mktempdir()); Pkg.add("PlutoUI"); using PlutoUI

# ╔═╡ 1b70a5be-01d6-11eb-2cf0-9de8fa2a665e
using LinearAlgebra,InteractiveUtils

# ╔═╡ 5a1cb7c8-01d9-11eb-1bf2-33a6b84fc123
Pkg.add("AbstractTrees")

# ╔═╡ 87ee0ddc-01d9-11eb-24fc-0b4a10a7acc2
import AbstractTrees

# ╔═╡ 1b221e84-01d2-11eb-3e46-67e2a59b03dc
md"""
Julia type system
===================
- Julia is a strongly typed language
- Knowledge about the layout of a value in memory is encoded in its type
- Prerequisite for performance
- There are concrete types and abstract types
- See the [Julia WikiBook](https://en.wikibooks.org/wiki/Introducing_Julia/Types) for more


## Concrete types
 - Every value in Julia has a concrete type
 - Concrete types correspond to computer representations of objects
 - Inquire type info using `typeof()`

#### Built-in types
 - Default types are deduced from concrete representations
"""

# ╔═╡ 13ccfef0-01d3-11eb-0be7-87721fe2c996
typeof(10)

# ╔═╡ 3b84bb40-01d3-11eb-1416-db63210faba4
typeof(10.0)

# ╔═╡ 7462dc44-01d3-11eb-310e-3f6d6b6a7a4f
typeof(3.0+3im)

# ╔═╡ 802e2ace-01d3-11eb-039a-fff2bbc9b2a3
typeof(π)

# ╔═╡ 45de6c76-01d3-11eb-0e9d-47f8108ba1b4
typeof(false)

# ╔═╡ 4c6a79ea-01d3-11eb-268e-c32f7a6c85cd
typeof("false")

# ╔═╡ c924835e-01d3-11eb-0fcb-0d7d4050b32c
typeof(Float16[1,2,3])

# ╔═╡ d2cca0be-01d3-11eb-017f-5f72d26f23ba
typeof(rand(Int,3,3))

# ╔═╡ fb556f26-01d2-11eb-0244-d353d4ae0c9d
md"""
- One can initialize a variable with an explicitely given fixed type.
  Currently this is possible only in the body of functions and for return values, not in the global context. The content of a do block is implicitely used as a function.
"""

# ╔═╡ be8b20de-01d2-11eb-353e-2b2d81ca29b7
with_terminal() do
    i::Int8=10
    @show i,typeof(i)
    x::Float16=5.0
    @show x,typeof(x)
    z::Complex{Float32}=15+3im
    @show z,typeof(z)	
end

# ╔═╡ b0fd81fe-01d3-11eb-19da-190f2787d98a
md"""
#### Custom types
- Structs allow to define custom types
"""

# ╔═╡ f61a4092-01d3-11eb-3460-5b62b5dae5de
struct Color64
    r::Float64
    g::Float64
    b::Float64
end

# ╔═╡ 17711ea0-01d4-11eb-2428-53f6e3d61d05
Color64(0.1,0.2,0.3)

# ╔═╡ 2eedb7dc-01d4-11eb-0cd6-c7ec9611e2bd
md"""
- Types can be parametrized. This is similar to array types which are parametrized by their element types
"""

# ╔═╡ 372503d0-01d4-11eb-1211-b9395834842a
struct TColor{T}
    r::T
    g::T
    b::T
end

# ╔═╡ 4ef772e8-01d4-11eb-314a-ed0d1c24da77
TColor{UInt8}(4,25,233)

# ╔═╡ c2be228a-01d4-11eb-243f-cf35c0ec0164
md"""
### Functions,  Methods and Multiple Dispatch
- Functions can have different variants of their implementation depending
  on the types of parameters passed to them
- These variants are called __methods__
- All methods of a function `f` can be listed calling `methods(f)`
- The act of figuring out which method of a function to call depending on
  the type of parameters is called __multiple dispatch__

"""

# ╔═╡ f5cc25e6-0954-11eb-179b-eddff99dd392
test_dispatch(x)="general case: $(typeof(x)), x=$(x)";

# ╔═╡ 0468c2da-0955-11eb-271b-5d84d5d8343d
test_dispatch(x::AbstractFloat)="special case Float, $(typeof(x)), x=$(x)";

# ╔═╡ 0cc7808a-0955-11eb-0b4d-ff491af88cf5
test_dispatch(x::Int64)="special case Int64, x=$(x)";

# ╔═╡ 125f7b0e-01d5-11eb-28ed-772426c25218
test_dispatch(3)

# ╔═╡ 4c81312e-01d5-11eb-0fd8-3be89232486b
test_dispatch(false)

# ╔═╡ 625bfc6a-01d5-11eb-25cf-259a7943063d
test_dispatch(3.0)

# ╔═╡ 6d712526-01d5-11eb-3feb-e74c800fa893
md"""
Here we defined a generic method which works for any variable passed. In the case of `Int64` or `Float64` parameters, special cases are handeld by different methods of the same function. The compiler decides which method to call. This approach allows to specialize implemtations dependent on data types, e.g. in order to optimize perfomance.

The `methods` function can be used to figure out which methods of a function exists.
"""

# ╔═╡ ec9abf90-01d5-11eb-257b-f3a2f681c7b9
methods(test_dispatch)

# ╔═╡ ec5288ec-01d5-11eb-2b09-a96fbe8fc00f
md"""
The function/method concept somehow corresponds to [C++14 generic lambdas](https://isocpp.org/wiki/faq/cpp14-language#generic-lambdas)
````
auto myfunc=[](auto  &y, auto &y)
{
  y=sin(x);
};
````
is equivalent to
````
function myfunc!(y,x)
    y=sin(x)
end
````
Many [generic programming](https://en.wikipedia.org/wiki/Generic_programming) approaches possible in C++ also work in Julia,

If not specified otherwise via parameter types, Julia functions are generic: "automatic auto"
"""

# ╔═╡ c7194b4a-01d7-11eb-0175-fda4e2b3947a
md"""
 ### Abstract types
 - Abstract types label concepts which work for a several
   concrete types without regard to their memory layout etc.
 - All variables with concrete types corresponding to a given
   abstract type (should) share a common interface
 - A common interface consists of a set of functions with methods working for all 
   types exhibiting this interface
 - The functionality of an abstract type is implicitely characterized
   by the methods working on it
 - This concept is close to ["duck typing"](https://en.wikipedia.org/wiki/Duck_typing):
   use the "duck test" — "If it walks like a duck and it quacks like a duck, then it must be a duck" —
   to determine if an object can be used for a particular purpose

- When trying to force a parmameter to have an abstract type,it
ends up with having a conrete type which is compatible with that abstract type
"""

# ╔═╡ 450a16a6-01d8-11eb-0d07-979219c7e493
with_terminal() do
	i::Integer=10
    @show i,typeof(i)
    x::Real=5.0
    @show x,typeof(x)
    z::Any=15+3im
    @show z,typeof(z)
end

# ╔═╡ d776bf38-01d8-11eb-2765-43dc1dbc3344
md"""
 ### The type tree
 - Types can have subtypes and a supertype
 - Concrete types are the leaves of the resulting type tree
 - Supertypes are necessarily abstract
 - There is only one supertype for every (abstract or concrete) type
 - Abstract types can have several subtypes
"""

# ╔═╡ fd9463d4-01d8-11eb-0a87-f7924aa63bda
subtypes(AbstractFloat)

# ╔═╡ 21d47428-01d9-11eb-1a5e-73de9310fc01
md"""
 - Concrete types have no subtypes
"""

# ╔═╡ 0ce950e0-01d9-11eb-0345-bd84b69b7e0a
subtypes(Float64)

# ╔═╡ c6834da2-2466-11eb-26a3-8b760d0bed2b
supertype(Number)

# ╔═╡ 49f559c2-01d9-11eb-3fb0-a9dc6c3ab515
md"""
- "Any" is the root of the type tree and has itself as supertype
"""

# ╔═╡ 327f7c32-01d9-11eb-0d80-69042308ae71
supertype(Any)

# ╔═╡ 910831ea-01d9-11eb-359d-996096e2641c
md"""
We can use the `AbstractTrees` package to walk the type tree. We just need  to define what it means to have children for a type.
"""

# ╔═╡ c66752b2-01d9-11eb-3c0e-cfe0e76253fd
AbstractTrees.children(x::Type) = subtypes(x)

# ╔═╡ ddf7a328-01d9-11eb-21b9-79c484f01134
AbstractTrees.Tree(Number)

# ╔═╡ 6a7e7916-01da-11eb-2857-3fff96092457
md"""
There are operators for testing type relationships
"""

# ╔═╡ 76efc16e-01da-11eb-3a78-bd1c99b5c79e
 Float64<: Number

# ╔═╡ 7d5c58e6-01da-11eb-1c79-a7b650bf3dc4
 Float64<: Integer

# ╔═╡ 3c243910-2463-11eb-1a37-8da1192a193e
isa(3,Float64)

# ╔═╡ 494294a0-2463-11eb-1fea-eff0f59ccfee
isa(3.0,Float64)

# ╔═╡ 8384fe94-01da-11eb-1c96-47c7cf183364
md"""
Abstract types can be used for method dispatch as well
"""

# ╔═╡ 8ef2b906-01da-11eb-1641-01ce9253d537
begin
	dispatch2(x::AbstractFloat)="$(typeof(x)) <:AbstractFloat, x=$(x)"
	dispatch2(x::Integer)="$(typeof(x)) <:Integer, x=$(x)"
end

# ╔═╡ d3cdc5ca-01da-11eb-3c3b-2bb31eb037ee
dispatch2(13)

# ╔═╡ da2d5e80-01da-11eb-1642-b519a74b2a87
dispatch2(13.0)

# ╔═╡ f113e434-01da-11eb-15d2-edf4d0e13b20
md"""
### The power of multiple dispatch
 - Multiple dispatch is one of the defining features of Julia
 - Combined with the  the hierarchical type system it allows for
   powerful generic program design
 - New datatypes (different kinds of numbers, differently stored arrays/matrices) work with existing code
   once they implement the same interface as existent ones.
 - In some respects C++ comes close to it, but for the price of more and less obvious code

"""

# ╔═╡ Cell order:
# ╠═baf88246-01d1-11eb-3d35-1393445b1476
# ╠═5a1cb7c8-01d9-11eb-1bf2-33a6b84fc123
# ╠═1b70a5be-01d6-11eb-2cf0-9de8fa2a665e
# ╠═87ee0ddc-01d9-11eb-24fc-0b4a10a7acc2
# ╟─1b221e84-01d2-11eb-3e46-67e2a59b03dc
# ╠═13ccfef0-01d3-11eb-0be7-87721fe2c996
# ╠═3b84bb40-01d3-11eb-1416-db63210faba4
# ╠═7462dc44-01d3-11eb-310e-3f6d6b6a7a4f
# ╠═802e2ace-01d3-11eb-039a-fff2bbc9b2a3
# ╠═45de6c76-01d3-11eb-0e9d-47f8108ba1b4
# ╠═4c6a79ea-01d3-11eb-268e-c32f7a6c85cd
# ╠═c924835e-01d3-11eb-0fcb-0d7d4050b32c
# ╠═d2cca0be-01d3-11eb-017f-5f72d26f23ba
# ╟─fb556f26-01d2-11eb-0244-d353d4ae0c9d
# ╠═be8b20de-01d2-11eb-353e-2b2d81ca29b7
# ╟─b0fd81fe-01d3-11eb-19da-190f2787d98a
# ╠═f61a4092-01d3-11eb-3460-5b62b5dae5de
# ╠═17711ea0-01d4-11eb-2428-53f6e3d61d05
# ╟─2eedb7dc-01d4-11eb-0cd6-c7ec9611e2bd
# ╠═372503d0-01d4-11eb-1211-b9395834842a
# ╠═4ef772e8-01d4-11eb-314a-ed0d1c24da77
# ╟─c2be228a-01d4-11eb-243f-cf35c0ec0164
# ╠═f5cc25e6-0954-11eb-179b-eddff99dd392
# ╠═0468c2da-0955-11eb-271b-5d84d5d8343d
# ╠═0cc7808a-0955-11eb-0b4d-ff491af88cf5
# ╠═125f7b0e-01d5-11eb-28ed-772426c25218
# ╠═4c81312e-01d5-11eb-0fd8-3be89232486b
# ╠═625bfc6a-01d5-11eb-25cf-259a7943063d
# ╟─6d712526-01d5-11eb-3feb-e74c800fa893
# ╠═ec9abf90-01d5-11eb-257b-f3a2f681c7b9
# ╟─ec5288ec-01d5-11eb-2b09-a96fbe8fc00f
# ╟─c7194b4a-01d7-11eb-0175-fda4e2b3947a
# ╠═450a16a6-01d8-11eb-0d07-979219c7e493
# ╟─d776bf38-01d8-11eb-2765-43dc1dbc3344
# ╠═fd9463d4-01d8-11eb-0a87-f7924aa63bda
# ╟─21d47428-01d9-11eb-1a5e-73de9310fc01
# ╠═0ce950e0-01d9-11eb-0345-bd84b69b7e0a
# ╠═c6834da2-2466-11eb-26a3-8b760d0bed2b
# ╟─49f559c2-01d9-11eb-3fb0-a9dc6c3ab515
# ╠═327f7c32-01d9-11eb-0d80-69042308ae71
# ╟─910831ea-01d9-11eb-359d-996096e2641c
# ╠═c66752b2-01d9-11eb-3c0e-cfe0e76253fd
# ╠═ddf7a328-01d9-11eb-21b9-79c484f01134
# ╟─6a7e7916-01da-11eb-2857-3fff96092457
# ╠═76efc16e-01da-11eb-3a78-bd1c99b5c79e
# ╠═7d5c58e6-01da-11eb-1c79-a7b650bf3dc4
# ╠═3c243910-2463-11eb-1a37-8da1192a193e
# ╠═494294a0-2463-11eb-1fea-eff0f59ccfee
# ╟─8384fe94-01da-11eb-1c96-47c7cf183364
# ╠═8ef2b906-01da-11eb-1641-01ce9253d537
# ╠═d3cdc5ca-01da-11eb-3c3b-2bb31eb037ee
# ╠═da2d5e80-01da-11eb-1642-b519a74b2a87
# ╟─f113e434-01da-11eb-15d2-edf4d0e13b20

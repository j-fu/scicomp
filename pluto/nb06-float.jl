### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ baf88246-01d1-11eb-3d35-1393445b1476
begin 
	using Pkg
	Pkg.activate(mktempdir()) 
	Pkg.add("PyPlot") 
	Pkg.add("PlutoUI")
	using PlutoUI,PyPlot
end

# ╔═╡ 69ac7f34-0292-11eb-32f1-d13bc04bd157
md"""
# Number representation
"""

# ╔═╡ a0c3c2ca-0319-11eb-258a-0d840331a21b
md"""
Besides of the concrete names of Julia library functions everything in this chapter is valid for all modern programming languagues and computer systems.
"""

# ╔═╡ bbbf8334-029c-11eb-13fa-4935023dee37
md"""
All data in computers are stored as sequences of bits. For concrete number types, the `bitstring` function returns this information as a sequence of `0` and `1`. The `sizeof` function returns the number of bytes in the binary representation.
"""

# ╔═╡ b1dda478-25e6-11eb-279c-a3e70a77dc01
md"""
## Integer numbers
"""

# ╔═╡ ddad34ce-25e6-11eb-3167-391a86e54916
T_int=Int16

# ╔═╡ e8107464-25e6-11eb-14a1-e5f32194b8b0
i=T_int(1)

# ╔═╡ f79b9fc4-25e6-11eb-1fb8-b3ef6441f74c
sizeof(i)

# ╔═╡ d1aaf44e-029c-11eb-275e-df714a2a3f2c
bitstring(i)

# ╔═╡ 9521e016-0317-11eb-0aaf-3f781874b998
md"""
 Positive integer numbers are represented by their representation in the binary system. For negative numbers $n$, the binary representation of their "two's complement" $2^N-|n|$ (where $N$ is the number of available bits) is stored. 

`typemin` and `typemax` return the smallest and largest numbers which can be represented in  number type.


"""

# ╔═╡ 6a87a15e-0319-11eb-0fe2-e39ca48790b1
typemin(T_int),typemax(T_int),2^(8*sizeof(T_int)-1)-1

# ╔═╡ 78dfc6dc-25e7-11eb-289d-fd73ee2845e6
md"""
Unless the possible range of the representation $(-2^{N-1},2^{N-1})$ is exceeded, addition, multiplication and subtraction of integers are exact. If it is exceeded, operation results wrap around into the opposite sign region.
"""

# ╔═╡ d18a9994-0317-11eb-11ba-c57262a26191
3+7

# ╔═╡ 88f14302-25e7-11eb-01f2-910158096295
typemax(T_int)+T_int(10)

# ╔═╡ 5f917b08-25e7-11eb-0352-df96ff7a2684
md"""
## Floating point numbers
"""

# ╔═╡ dee68dd0-029c-11eb-302e-1dd77841b4e8
md"""
How does this work for floating point numbers ?
"""

# ╔═╡ 5cc5716e-029b-11eb-38c9-1d3e428ac8d2
0.1+0.2

# ╔═╡ a36d99aa-25ed-11eb-31df-a1ddef79b2d6
md"""
__But this should be 0.3. What is happening ???__
"""

# ╔═╡ 87e9a9aa-029b-11eb-1e0c-bff7c04e602d
md"""
#### Real number representation

- Let us think about representation real numbers. Usually we write them as decimal fractions and cut the representation off if the number of digits is infinite.

- Any real number $x\in \mathbb{R}$ can be expressed via the representation formula: $x=\pm \sum_{i=0}^{\infty} d_i\beta^{-i} \beta^e$ with __base__ $\beta\in \mathbb N, \beta\geq 2$, __significand__ (or __mantissa__) digits $d_i \in \mathbb N, 0\leq d_i < \beta$ and __exponent__ $e\in \mathbb Z$

- The representation is infinite for periodic decimal numbers and irrational numbers.


"""

# ╔═╡ bb5776c6-25ed-11eb-2603-bd0ad342ae17
md"""
#### Scientific notation
The scientific notation of real numbers is derived from this representation in the case of  $\beta=10$. Let  e.g. $x= 6.022\cdot 10^{23}$=`6.022e23`. Then
 - ``\beta=10``
 - ``d=(6,0,2,2,0\dots)``
 - $ e=23 $
This representation is not unique, e.g.   $x_1= 0.6022\cdot 10^{24}$=`0.6022e24`$=x$ with
  - $ \beta=10 $
  - $ d=(0,6,0,2,2,0\dots) $
  - $ e=24 $
"""

# ╔═╡ 651c4a2a-029d-11eb-03e9-6df3be9f306c
md"""
####  IEEE754 standard
This is the actual standard format for storing floating point numbers.
It was developed in the 1980ies.

 -  $\beta =2 $, therefore $d_i\in \{0,1\}$
 - Truncation to fixed finite size:
      $x=\pm \sum_{i=0}^{t-1} d_i\beta^{-i} \beta^e$
 - $ t $ :  significand (mantissa) length
 - Normalization: assume $d_0=1 \Rightarrow$ save one bit for the storage of the significand. This requires a normalization step after operations which  adjusts significand and exponent of the result.
 -  $k$: exponent size. Define $L,K$: $ -\beta^k+1=L\leq e \leq U = \beta^k-1$
 - Extra bit for sign
 -  $\Rightarrow$ storage size: $ (t-1) + k + 1$
 
 - Standardized for most modern languages
 - Hardware support usually for 64bit and 32bit

| precision | Julia   | C/C++  | k   | t   | bits|
| :---      | :---    | :---   | --- | --- | --- |
|quadruple  | n/a     | long double | 16  | 113  | 128  |
|double     | Float64 | double | 11  |53  | 64  |
|single     | Float32 | float  | 8   | 24  | 32  |
|half       | Float16 |  n/a   | 5   | 11  | 16  |

 - See also the [__Julia Documentation on floating point numbers__](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Floating-Point-Numbers-1), [__0.30000000000000004.com__](https://0.30000000000000004.com/), [__wikipedia__](https://en.wikipedia.org/wiki/IEEE_754) and the links therein.

The storage sequence is: Sign bit, exponent, mantissa.
"""

# ╔═╡ 12f7fef2-25ee-11eb-14a1-27f3507d7268
md"""
Storage layout for a normalized Float32 number ($d_0=1$):
 - bit 1: sign, ``0\to +,\quad 1\to-``
 - bit $2\dots 9$: $k=8$ exponent bits
    - the value ``e+2^{k-1}-1=e+127`` is stored $\Rightarrow$ no need for sign bit in exponent
 - bit $10\dots 32$: $23=t-1$ mantissa bits $d_1\dots d_{23}$
 - $ d_0=1 $ not stored $\equiv$ "hidden bit"
"""

# ╔═╡ 81da7240-25e8-11eb-37ea-cdcacee235e7
md"""
Julia allows to obtain the signifcand and the exponent of a floating point number
"""

# ╔═╡ c868e0ac-25e8-11eb-32ee-e99f4956f977
x0=2.0

# ╔═╡ ce0e4538-25e8-11eb-04ed-e503fab8341d
significand(x0),exponent(x0)

# ╔═╡ 7e2ee3ac-029e-11eb-2124-8d7d67c99e33
md"""
- We can calculate the length of the exponent $k$ from the maximum representable floating point number by taking the base-2 logarithm of its exponent:
"""

# ╔═╡ 79770ddc-0286-11eb-1893-49dc86e0104a
exponent_length(T::Type{<:AbstractFloat})=Int(log2(exponent(floatmax(T))+1)+1);

# ╔═╡ 94caced0-029e-11eb-1e21-e32618c9752b
md"""
- The size of the significand $t$ is calculated from the overall size of the representation minus the size of the exponent and the size of the sign bit + 1 for the "hidden bit".
"""

# ╔═╡ 06f0e562-028b-11eb-3285-611b2de92f01
significand_length(T::Type{<:AbstractFloat})=8*sizeof(T)-exponent_length(T)-1+1;

# ╔═╡ e2664e24-029e-11eb-07ed-135fbeb0998c
md"""
This allows to define a more readable variant of the bitstring repredentatio
for floats.

- The sign bit is the first bit in the representation:
"""

# ╔═╡ 7a74c4e8-028b-11eb-0e4b-8199f0fe35b0
signbit(x::AbstractFloat)=bitstring(x)[1:1];

# ╔═╡ f2d96006-029e-11eb-0d87-914ea607e248
md"""
- Next comes the exponent:
"""

# ╔═╡ a9a5b06a-028b-11eb-15c7-179c50f68f2d
exponent_bits(x::AbstractFloat)=bitstring(x)[2:exponent_length(typeof(x))+1]

# ╔═╡ 0f5bcd02-029f-11eb-1650-4356527b6e35
md"""
- And finally, the significand:
"""

# ╔═╡ e1393e04-028b-11eb-12f6-2f9b8dc82ad1
significand_bits(x::AbstractFloat)=bitstring(x)[exponent_length(typeof(x))+2:8*sizeof(x)];

# ╔═╡ 1b3d2c6a-029f-11eb-114b-699b422427f2
md"""
- Put them together:
"""

# ╔═╡ a2c4e692-031e-11eb-115f-b924e9ad117b
floatbits(x::AbstractFloat)=signbit(x)*"_"*exponent_bits(x)*"_"*significand_bits(x);

# ╔═╡ 434b3386-25ee-11eb-0ece-33bcc44fa73b
md"""
#### Julia floating point types
"""

# ╔═╡ 50bbc27a-02a4-11eb-3216-23b7e120ed42
T=Float16

# ╔═╡ ec9715b4-029f-11eb-00e8-e381386dd5e2
md"""
Type $(T):
- size of exponent: $(exponent_length(T))
- size of significand: $(significand_length(T))
"""

# ╔═╡ 96d8be54-031f-11eb-386e-23f053fd2b32
x=T(0.1)

# ╔═╡ e421a09c-02a0-11eb-2643-c36da13a2f35
md"""
- Binary representation: $(floatbits(x))
- Exponent e=$(exponent(x))  
- Stored: e+$(2^(exponent_length(T)-1)-1)=  $(exponent(x)+(2^(exponent_length(T)-1)-1))
- $ d_0=1 $ assumed implicitely.
"""

# ╔═╡ b1ed9008-02a1-11eb-0fdb-cd538be69cc3
md"""
 - Numbers which are exactly represented in decimal system may not be exactly represented in binary system! 

- Such numbers are always rounded to a finite approximate
"""

# ╔═╡ 2c762d6e-066f-11eb-1962-89e2eb99e54a
x_per=T(0.1)+T(0.2)

# ╔═╡ 80eeb87c-25e9-11eb-08c6-2fc07f517ef1
floatbits(x_per)

# ╔═╡ dc4197d2-02a1-11eb-23b0-a327e4a7cacc
md"""
 ##### Floating point limits
  - Finite size of representation $\Rightarrow$ there are minimal and maximal
    possible numbers which can be represented    
  - symmetry wrt. 0 because of sign bit

  -  smallest positive denormalized number:    $d_i=0, i=0\dots t-2, d_{t-1}=1$ $\Rightarrow$   $x_{min} = 2^{1-t}2^L$
"""

# ╔═╡ ee794c56-02a1-11eb-0a28-21bdc287c8f0
 nextfloat(zero(T)), floatbits(nextfloat(zero(T)))

# ╔═╡ 327cd152-02a2-11eb-0ce3-a3c8229132e2
md"""
 - smallest positive normalized number: $d_0=1, d_i=0, i=1\dots t-1$ $\Rightarrow$    $x_{min} = 2^L$
"""

# ╔═╡ 386837be-02a2-11eb-14bc-55a48dac2005
floatmin(T),floatbits(floatmin(T))

# ╔═╡ 51deeb48-02a2-11eb-15b9-693daa14af86
md"""
- largest positive normalized number: $d_i=1, 0\dots t-1$ $\Rightarrow$     $x_{max} = 2(1-2^{1-t}) 2^U$

"""

# ╔═╡ 77029c58-02a2-11eb-3692-25577ceefe7e
floatmax(T), floatbits(floatmax(T))

# ╔═╡ a2b2fd34-02a2-11eb-3008-8b29c1c55e15
md"""
- Largest representable number:
"""

# ╔═╡ 9fcca4d0-02a2-11eb-1797-b93ee654034f
typemax(T),floatbits(typemax(T)),prevfloat(typemax(T)), floatbits(prevfloat(typemax(T)))

# ╔═╡ eae1243c-02a2-11eb-1c47-2f0f21411c52
md"""
 ##### Machine precision
 -  There cannot be more than $2^{t+k}$ floating point numbers   $\Rightarrow$ almost all real numbers have to be approximated
 -  Let $x$ be an exact value and $\tilde x$ be its approximation.    Then $|\frac{\tilde x-x}{x}|<\epsilon$ is the best accuracy
    estimate we can get, where
     - $ \epsilon=2^{1-t} $ (truncation)
     - $ \epsilon=\frac12 2^{1-t} $ (rounding)
 - Also: $\epsilon$ is the smallest representable number such that $1+\epsilon >1$.
 - Relative errors show up in particular when
     - subtracting two close numbers
     - adding smaller numbers to larger ones
 ###### How do operations work?
 E.g. Addition
 - Adjust exponent of number to be added:
     - Until both exponents are equal, add 1 to exponent, shift mantissa to right bit by bit
 - Add both numbers
 - Normalize result

 The smallest number one can add to 1 can have at most $t$ bit shifts of normalized mantissa until mantissa becomes 0, so 
 its value must be $2^{-t}$.

 ###### Machine epsilon
 - Smallest floating point number $\epsilon$  such that  $1+\epsilon>1$ in floating    point arithmetic
 - In exact math it is true that from $1+\varepsilon=1$  it follows  that
    $0+\varepsilon=0$ and vice versa. In floating point computations this is not true

"""

# ╔═╡ 6733a3a2-02a3-11eb-1e6f-cb2d7f3be109
ϵ=eps(T)

# ╔═╡ b19c6726-02a3-11eb-0772-bf817873eb07
floatbits(ϵ)

# ╔═╡ 7a5ca7a0-02a3-11eb-31f7-9bb4f138b789
one(T)+ϵ/2,floatbits(one(T)+ϵ/2), floatbits(one(T))

# ╔═╡ 083c84e4-02a4-11eb-3e09-2fb8be352128
 one(T)+ϵ,floatbits(one(T)+ϵ)

# ╔═╡ 323a83e0-02a4-11eb-255e-9d0431ef8da9
nextfloat(one(T))-one(T),floatbits(nextfloat(one(T))-one(T))

# ╔═╡ 635a0b52-02a5-11eb-3d70-e3566a63ff60
md"""
#### Density of floating point numbers

How dense are floating point numbers on the real axis?
"""

# ╔═╡ 6dc7cbce-02a5-11eb-1553-cf56a2d13caf
function fpdens(x::AbstractFloat;sample_size=1000) 
    xleft=x
    xright=x
    for i=1:sample_size
        xleft=prevfloat(xleft)
        xright=nextfloat(xright)
    end
    return prevfloat(2.0*sample_size/(xright-xleft))
end;

# ╔═╡ 9db82bee-02a5-11eb-3a17-0752368d11bb
X=T(10.0) .^collect(-10:T(0.1):10)

# ╔═╡ b85b25c6-02a5-11eb-3215-619de72f826d
begin
	fig=PyPlot.figure()
	PyPlot.loglog(X,fpdens.(X))
	PyPlot.title("$(eltype(X)) numbers per unit interval")
	PyPlot.grid()
	PyPlot.xlabel("x")
	fig
end

# ╔═╡ Cell order:
# ╠═baf88246-01d1-11eb-3d35-1393445b1476
# ╟─69ac7f34-0292-11eb-32f1-d13bc04bd157
# ╟─a0c3c2ca-0319-11eb-258a-0d840331a21b
# ╟─bbbf8334-029c-11eb-13fa-4935023dee37
# ╟─b1dda478-25e6-11eb-279c-a3e70a77dc01
# ╠═ddad34ce-25e6-11eb-3167-391a86e54916
# ╠═e8107464-25e6-11eb-14a1-e5f32194b8b0
# ╠═f79b9fc4-25e6-11eb-1fb8-b3ef6441f74c
# ╠═d1aaf44e-029c-11eb-275e-df714a2a3f2c
# ╟─9521e016-0317-11eb-0aaf-3f781874b998
# ╠═6a87a15e-0319-11eb-0fe2-e39ca48790b1
# ╟─78dfc6dc-25e7-11eb-289d-fd73ee2845e6
# ╠═d18a9994-0317-11eb-11ba-c57262a26191
# ╠═88f14302-25e7-11eb-01f2-910158096295
# ╟─5f917b08-25e7-11eb-0352-df96ff7a2684
# ╟─dee68dd0-029c-11eb-302e-1dd77841b4e8
# ╠═5cc5716e-029b-11eb-38c9-1d3e428ac8d2
# ╟─a36d99aa-25ed-11eb-31df-a1ddef79b2d6
# ╟─87e9a9aa-029b-11eb-1e0c-bff7c04e602d
# ╟─bb5776c6-25ed-11eb-2603-bd0ad342ae17
# ╟─651c4a2a-029d-11eb-03e9-6df3be9f306c
# ╟─12f7fef2-25ee-11eb-14a1-27f3507d7268
# ╟─81da7240-25e8-11eb-37ea-cdcacee235e7
# ╠═c868e0ac-25e8-11eb-32ee-e99f4956f977
# ╠═ce0e4538-25e8-11eb-04ed-e503fab8341d
# ╟─7e2ee3ac-029e-11eb-2124-8d7d67c99e33
# ╠═79770ddc-0286-11eb-1893-49dc86e0104a
# ╟─94caced0-029e-11eb-1e21-e32618c9752b
# ╠═06f0e562-028b-11eb-3285-611b2de92f01
# ╟─e2664e24-029e-11eb-07ed-135fbeb0998c
# ╠═7a74c4e8-028b-11eb-0e4b-8199f0fe35b0
# ╟─f2d96006-029e-11eb-0d87-914ea607e248
# ╠═a9a5b06a-028b-11eb-15c7-179c50f68f2d
# ╟─0f5bcd02-029f-11eb-1650-4356527b6e35
# ╠═e1393e04-028b-11eb-12f6-2f9b8dc82ad1
# ╟─1b3d2c6a-029f-11eb-114b-699b422427f2
# ╠═a2c4e692-031e-11eb-115f-b924e9ad117b
# ╟─434b3386-25ee-11eb-0ece-33bcc44fa73b
# ╠═50bbc27a-02a4-11eb-3216-23b7e120ed42
# ╟─ec9715b4-029f-11eb-00e8-e381386dd5e2
# ╠═96d8be54-031f-11eb-386e-23f053fd2b32
# ╟─e421a09c-02a0-11eb-2643-c36da13a2f35
# ╟─b1ed9008-02a1-11eb-0fdb-cd538be69cc3
# ╠═2c762d6e-066f-11eb-1962-89e2eb99e54a
# ╠═80eeb87c-25e9-11eb-08c6-2fc07f517ef1
# ╟─dc4197d2-02a1-11eb-23b0-a327e4a7cacc
# ╠═ee794c56-02a1-11eb-0a28-21bdc287c8f0
# ╟─327cd152-02a2-11eb-0ce3-a3c8229132e2
# ╠═386837be-02a2-11eb-14bc-55a48dac2005
# ╟─51deeb48-02a2-11eb-15b9-693daa14af86
# ╠═77029c58-02a2-11eb-3692-25577ceefe7e
# ╟─a2b2fd34-02a2-11eb-3008-8b29c1c55e15
# ╠═9fcca4d0-02a2-11eb-1797-b93ee654034f
# ╟─eae1243c-02a2-11eb-1c47-2f0f21411c52
# ╠═6733a3a2-02a3-11eb-1e6f-cb2d7f3be109
# ╠═b19c6726-02a3-11eb-0772-bf817873eb07
# ╠═7a5ca7a0-02a3-11eb-31f7-9bb4f138b789
# ╠═083c84e4-02a4-11eb-3e09-2fb8be352128
# ╠═323a83e0-02a4-11eb-255e-9d0431ef8da9
# ╟─635a0b52-02a5-11eb-3d70-e3566a63ff60
# ╠═6dc7cbce-02a5-11eb-1553-cf56a2d13caf
# ╠═9db82bee-02a5-11eb-3a17-0752368d11bb
# ╠═b85b25c6-02a5-11eb-3215-619de72f826d

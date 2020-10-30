### A Pluto.jl notebook ###
# v0.12.3

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

# ╔═╡ baf88246-01d1-11eb-3d35-1393445b1476
using Pkg; Pkg.activate(mktempdir()); Pkg.add("PlutoUI"); using PlutoUI

# ╔═╡ 0434bba0-01d2-11eb-124f-ef216f314163
md"""Hide package status: $(@bind hide_pkg_status CheckBox(false))"""

# ╔═╡ fccd863a-01d1-11eb-126c-f5a20a339413
if !hide_pkg_status 
	with_terminal(Pkg.status)
end


# ╔═╡ ace1c08a-01e0-11eb-0fb2-87673f00ffda
Pkg.add("PyPlot"); import PyPlot

# ╔═╡ 69ac7f34-0292-11eb-32f1-d13bc04bd157
md"""
# Number representation with focus on floating point numbers
"""

# ╔═╡ a0c3c2ca-0319-11eb-258a-0d840331a21b
md"""
Besides of the concrete names of Julia library functions everything in this chapter is valid for all modern programming languagues and computer systems.
"""

# ╔═╡ bbbf8334-029c-11eb-13fa-4935023dee37
md"""
All data in computers are stored as sequences of bits. For concrete number types, the `bitstring` function returns this information as a sequence of `0` and `1`. The `sizeof` function returns the number of bytes in the binary representation.
"""

# ╔═╡ d1aaf44e-029c-11eb-275e-df714a2a3f2c
bitstring(1), sizeof(1), sizeof(Int64)

# ╔═╡ 9521e016-0317-11eb-0aaf-3f781874b998
md"""
 Positive integer numbers are represented by their representation in the binary system. For negative numbers $n$, the binary representation of their "two's complement" $2^N-|n|$ (where $N$ is the number of available bits) is stored. 

`typemin` and `typemax` return the smallest and largest numbers which can be represented in  number type.

Unless the possible range of the representation $(-2^{N-1},2^{N-1})$ is exceeded, addition, multiplication and subtraction of integers are exact. If it is exceeded, operation results wrap around into the opposite sign region.
"""

# ╔═╡ 6a87a15e-0319-11eb-0fe2-e39ca48790b1
typemin(Int64),typemax(Int64),2^(8*sizeof(Int64)-1)-1

# ╔═╡ d18a9994-0317-11eb-11ba-c57262a26191
3+7

# ╔═╡ dee68dd0-029c-11eb-302e-1dd77841b4e8
md"""
How does this work for real numbers ?
"""

# ╔═╡ 5cc5716e-029b-11eb-38c9-1d3e428ac8d2
0.1+0.7

# ╔═╡ 87e9a9aa-029b-11eb-1e0c-bff7c04e602d
md"""

But this should be 0.8. What is happening ???

Let us think about representation real numbers. Usually we write them as decimal fractions and cut the representation off if the number of digits is infinite.

Any real number $x\in \mathbb{R}$ can be expressed via the representation formula: $x=\pm \sum_{i=0}^{\infty} d_i\beta^{-i} \beta^e$
with __base__ $\beta\in \mathbb N, \beta\geq 2$,
__significand__ (or mantissa) digits $d_i \in \mathbb N, 0\leq d_i < \beta$
and __exponent__ $e\in \mathbb Z$

The representation is infinite for periodic decimal numbers and irrational numbers.


### Scientific notation
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
###  IEEE754 standard
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

 - See also the [Julia Documentation on floating point numbers](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Floating-Point-Numbers-1), [0.30000000000000004.com](https://0.30000000000000004.com/) and the links therein.

The storage sequence is: Sign bit, exponent, mantissa.

Storage layout for a normalized Float32 number ($d_0=1$):
 - bit 1: sign, ``0\to +,\quad 1\to-``
 - bit $2\dots 9$: $k=8$ exponent bits
    - the value ``e+2^{k-1}-1=e+127`` is stored $\Rightarrow$ no need for sign bit in exponent
 - bit $10\dots 32$: $23=t-1$ mantissa bits $d_1\dots d_{23}$
 - $ d_0=1 $ not stored $\equiv$ "hidden bit"
 """

# ╔═╡ 7e2ee3ac-029e-11eb-2124-8d7d67c99e33
md"""
We can calculate the length of the exponent $k$ from the maximum representable floating point number:
"""

# ╔═╡ 79770ddc-0286-11eb-1893-49dc86e0104a
exponent_length(T::Type{<:AbstractFloat})=Int(log2(exponent(floatmax(T))+1)+1);

# ╔═╡ 94caced0-029e-11eb-1e21-e32618c9752b
md"""
The size of the significand $t$ is calculated from the overall size of the representation minus the size of the exponent and the size of the sign bit + 1 for the "hidden bit".
"""

# ╔═╡ 06f0e562-028b-11eb-3285-611b2de92f01
significand_length(T::Type{<:AbstractFloat})=8*sizeof(T)-exponent_length(T)-1+1;

# ╔═╡ e2664e24-029e-11eb-07ed-135fbeb0998c
md"""
The sign bit is the first bit in the representation with can be obtained as the bitring of the stored number.
"""

# ╔═╡ 7a74c4e8-028b-11eb-0e4b-8199f0fe35b0
signbit(x::AbstractFloat)=bitstring(x)[1:1];

# ╔═╡ f2d96006-029e-11eb-0d87-914ea607e248
md"""
Next comes the exponent:
"""

# ╔═╡ a9a5b06a-028b-11eb-15c7-179c50f68f2d
exponent_bits(x::AbstractFloat)=bitstring(x)[2:exponent_length(typeof(x))+1]

# ╔═╡ 0f5bcd02-029f-11eb-1650-4356527b6e35
md"""
And finally, the significand:
"""

# ╔═╡ e1393e04-028b-11eb-12f6-2f9b8dc82ad1
significand_bits(x::AbstractFloat)=bitstring(x)[exponent_length(typeof(x))+2:8*sizeof(x)];

# ╔═╡ 1b3d2c6a-029f-11eb-114b-699b422427f2
md"""
We can bring then together in a way which allows to have a better overview on the parts.
"""

# ╔═╡ a2c4e692-031e-11eb-115f-b924e9ad117b
floatbits(x::AbstractFloat)=signbit(x)*"_"*exponent_bits(x)*"_"*significand_bits(x);

# ╔═╡ 50bbc27a-02a4-11eb-3216-23b7e120ed42
T=Float64

# ╔═╡ ec9715b4-029f-11eb-00e8-e381386dd5e2
md"""
Type $(T):
- size of exponent: $(exponent_length(T))
- size of significand: $(significand_length(T))
"""

# ╔═╡ 96d8be54-031f-11eb-386e-23f053fd2b32
x=T(1)

# ╔═╡ e421a09c-02a0-11eb-2643-c36da13a2f35
md"""
- Binary representation: $(floatbits(x))
- Exponent e=$(exponent(x))  
- Stored: e+$(2^(exponent_length(T)-1)-1)=  $(exponent(x)+(2^(exponent_length(T)-1)-1))
- $ d_0=1 $ assumed implicitely.
"""

# ╔═╡ 2c762d6e-066f-11eb-1962-89e2eb99e54a
x_per=T(0.1)

# ╔═╡ b1ed9008-02a1-11eb-0fdb-cd538be69cc3
md"""
 - Numbers which are exactly represented in decimal system may not be exactly represented in binary system! 
 - Example: $(x_per) is an finite fraction in the decimal system but not  in the binary system, but not in the decimal system - it's binary representation is $(floatbits(x_per))
- Such numbers are always rounded to a finite approximate
"""

# ╔═╡ dc4197d2-02a1-11eb-23b0-a327e4a7cacc
md"""
 ##### Floating point limits
  - Finite size of representation $\Rightarrow$ there are minimal and maximal
    possible numbers which can be represented    
  - symmetry wrt. 0 because of sign bit

  -  smallest positive denormalized number:    $d_i=0, i=0\dots t-2, d_{t-1}=1$ $\Rightarrow$   $x_{min} = \beta^{1-t}\beta^L$
"""

# ╔═╡ ee794c56-02a1-11eb-0a28-21bdc287c8f0
 nextfloat(zero(T)), floatbits(nextfloat(zero(T)))

# ╔═╡ 327cd152-02a2-11eb-0ce3-a3c8229132e2
md"""
 - smallest positive normalized number: $d_0=1, d_i=0, i=1\dots t-1$ $\Rightarrow$    $x_{min} = \beta^L$
"""

# ╔═╡ 386837be-02a2-11eb-14bc-55a48dac2005
floatmin(T),floatbits(floatmin(T))

# ╔═╡ 51deeb48-02a2-11eb-15b9-693daa14af86
md"""
- largest positive normalized number: $d_i=\beta-1, 0\dots t-1$ $\Rightarrow$     $x_{max} = \beta (1-\beta^{1-t}) \beta^U$

"""

# ╔═╡ 77029c58-02a2-11eb-3692-25577ceefe7e
floatmax(T),floatbits(floatmax(T))

# ╔═╡ a2b2fd34-02a2-11eb-3008-8b29c1c55e15
md"""
- Largest representable number:
"""

# ╔═╡ 9fcca4d0-02a2-11eb-1797-b93ee654034f
typemax(T),floatbits(typemax(T)),prevfloat(typemax(T))

# ╔═╡ eae1243c-02a2-11eb-1c47-2f0f21411c52
md"""
 ##### Machine precision
 -  There cannot be more than $2^{t+k}$ floating point numbers   $\Rightarrow$ almost all real numbers have to be approximated
 -  Let $x$ be an exact value and $\tilde x$ be its approximation.    Then $|\frac{\tilde x-x}{x}|<\epsilon$ is the best accuracy
    estimate we can get, where
     - $ \epsilon=\beta^{1-t} $ (truncation)
     - $ \epsilon=\frac12\beta^{1-t} $ (rounding)
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

# ╔═╡ ccdad576-02a4-11eb-371a-9d1b22b0c5c2
md"""
Associativity ?

Without optimization:
"""

# ╔═╡ d3f20c42-02a4-11eb-12e1-f9654b48b12a
 (1.0 + 0.5*eps(T)) - 1.0

# ╔═╡ e1e9a44a-02a4-11eb-2643-6f01b2cc9111
1.0 + (0.5*eps(T) - 1.0)

# ╔═╡ 2409b768-02a5-11eb-0def-79999428899f
md"""
With optimization:
"""

# ╔═╡ fd113db6-02a4-11eb-0608-bb3e56cd0958
 (1.0 + ϵ/2) - 1.0

# ╔═╡ 06df5a80-02a5-11eb-00bb-670b1eda8e71
 1.0 + (ϵ/2 - 1.0)

# ╔═╡ 635a0b52-02a5-11eb-3d70-e3566a63ff60
md"""
##### Density of floating point numebers:

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
X=10.0 .^collect(-10.0:0.1:10)

# ╔═╡ b85b25c6-02a5-11eb-3215-619de72f826d
begin
	fig=PyPlot.figure()
	PyPlot.loglog(X,fpdens.(X))
	PyPlot.title("Floating point numbers per unit interval")
	PyPlot.grid()
	PyPlot.xlabel("x")
	fig
end

# ╔═╡ Cell order:
# ╠═baf88246-01d1-11eb-3d35-1393445b1476
# ╟─0434bba0-01d2-11eb-124f-ef216f314163
# ╟─fccd863a-01d1-11eb-126c-f5a20a339413
# ╠═ace1c08a-01e0-11eb-0fb2-87673f00ffda
# ╠═69ac7f34-0292-11eb-32f1-d13bc04bd157
# ╠═a0c3c2ca-0319-11eb-258a-0d840331a21b
# ╠═bbbf8334-029c-11eb-13fa-4935023dee37
# ╠═d1aaf44e-029c-11eb-275e-df714a2a3f2c
# ╠═9521e016-0317-11eb-0aaf-3f781874b998
# ╠═6a87a15e-0319-11eb-0fe2-e39ca48790b1
# ╠═d18a9994-0317-11eb-11ba-c57262a26191
# ╠═dee68dd0-029c-11eb-302e-1dd77841b4e8
# ╠═5cc5716e-029b-11eb-38c9-1d3e428ac8d2
# ╠═87e9a9aa-029b-11eb-1e0c-bff7c04e602d
# ╠═651c4a2a-029d-11eb-03e9-6df3be9f306c
# ╠═7e2ee3ac-029e-11eb-2124-8d7d67c99e33
# ╠═79770ddc-0286-11eb-1893-49dc86e0104a
# ╠═94caced0-029e-11eb-1e21-e32618c9752b
# ╠═06f0e562-028b-11eb-3285-611b2de92f01
# ╠═e2664e24-029e-11eb-07ed-135fbeb0998c
# ╠═7a74c4e8-028b-11eb-0e4b-8199f0fe35b0
# ╠═f2d96006-029e-11eb-0d87-914ea607e248
# ╠═a9a5b06a-028b-11eb-15c7-179c50f68f2d
# ╠═0f5bcd02-029f-11eb-1650-4356527b6e35
# ╠═e1393e04-028b-11eb-12f6-2f9b8dc82ad1
# ╠═1b3d2c6a-029f-11eb-114b-699b422427f2
# ╠═a2c4e692-031e-11eb-115f-b924e9ad117b
# ╠═50bbc27a-02a4-11eb-3216-23b7e120ed42
# ╠═ec9715b4-029f-11eb-00e8-e381386dd5e2
# ╠═96d8be54-031f-11eb-386e-23f053fd2b32
# ╠═e421a09c-02a0-11eb-2643-c36da13a2f35
# ╠═2c762d6e-066f-11eb-1962-89e2eb99e54a
# ╠═b1ed9008-02a1-11eb-0fdb-cd538be69cc3
# ╠═dc4197d2-02a1-11eb-23b0-a327e4a7cacc
# ╠═ee794c56-02a1-11eb-0a28-21bdc287c8f0
# ╠═327cd152-02a2-11eb-0ce3-a3c8229132e2
# ╠═386837be-02a2-11eb-14bc-55a48dac2005
# ╠═51deeb48-02a2-11eb-15b9-693daa14af86
# ╠═77029c58-02a2-11eb-3692-25577ceefe7e
# ╠═a2b2fd34-02a2-11eb-3008-8b29c1c55e15
# ╠═9fcca4d0-02a2-11eb-1797-b93ee654034f
# ╠═eae1243c-02a2-11eb-1c47-2f0f21411c52
# ╠═6733a3a2-02a3-11eb-1e6f-cb2d7f3be109
# ╠═b19c6726-02a3-11eb-0772-bf817873eb07
# ╠═7a5ca7a0-02a3-11eb-31f7-9bb4f138b789
# ╠═083c84e4-02a4-11eb-3e09-2fb8be352128
# ╠═323a83e0-02a4-11eb-255e-9d0431ef8da9
# ╟─ccdad576-02a4-11eb-371a-9d1b22b0c5c2
# ╠═d3f20c42-02a4-11eb-12e1-f9654b48b12a
# ╠═e1e9a44a-02a4-11eb-2643-6f01b2cc9111
# ╠═2409b768-02a5-11eb-0def-79999428899f
# ╠═fd113db6-02a4-11eb-0608-bb3e56cd0958
# ╠═06df5a80-02a5-11eb-00bb-670b1eda8e71
# ╠═635a0b52-02a5-11eb-3d70-e3566a63ff60
# ╠═6dc7cbce-02a5-11eb-1553-cf56a2d13caf
# ╠═9db82bee-02a5-11eb-3a17-0752368d11bb
# ╠═b85b25c6-02a5-11eb-3215-619de72f826d

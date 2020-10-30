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

# ╔═╡ 74e7b588-0753-11eb-10d5-f98133cdbd37
using Pkg; Pkg.activate(mktempdir()); Pkg.add("PlutoUI"); using PlutoUI; md"""Hide package manager logs: $(@bind hide_status CheckBox(default=false))"""

# ╔═╡ 50551f36-0755-11eb-2ccd-111cbb151846
using LinearAlgebra

# ╔═╡ a2859d7a-0753-11eb-2899-f1c7694422fe
hide_status ? nothing : with_terminal(Pkg.status)

# ╔═╡ 8cfb9372-0753-11eb-320a-f3aa8e25a8dc
Pkg.add("BenchmarkTools")

# ╔═╡ a6634eec-0753-11eb-1e17-459995c901e5
md"""
# Linear System Solution

- Let $A$ be an  $N \times N$ matrix, $b\in \mathbb R^N$.
- Solve $Ax=b$

__Direct methods__:
  - Exact up to machine precision
  - Sometimes expensive, sometimes not
__Iterative methods__:
  - "Only" approximate
  - With good convergence and proper accuracy control, results may be not  worse than for direct methods
 - Sometimes expensive, sometimes not
 - Convergence guarantee is problem dependent and can be tricky
"""

# ╔═╡ 0debcc2e-0754-11eb-0d63-d97ee52fdbee
md"""
## Matrix and Vector norms

#### Vector norms

let $x= (x_i)\in \mathbb R^n$
"""

# ╔═╡ d80a35a4-0754-11eb-3db4-a55fcc791545
v=[0.2, 0.3,  1.0];

# ╔═╡ df02ce48-0754-11eb-3da1-9bed1696db10
md"""
- ``||x||_1 = \sum_{i=1}^n |x_i|``: sum norm, ``l_1``-norm
"""

# ╔═╡ 4290591c-0755-11eb-1fdf-a9bc1f928988
norm(v,1)

# ╔═╡ 716b78a0-0755-11eb-315a-cbbd504cc47f
md"""
 - ``||x||_2 = \sqrt{\sum_{i=1}^n x_i^2}``: Euclidean norm, ``l_2``-norm
"""

# ╔═╡ 8d652e18-0755-11eb-08dc-9572175e54aa
norm(v,2),norm(v)

# ╔═╡ a4db244e-0755-11eb-1c84-4fe111f9ad64
md"""
- ``||x||_\infty = \max_{i=1}^n |x_i|``: maximum norm, ``l_\infty``-norm
"""

# ╔═╡ ba2c3360-0755-11eb-262e-3f088275edce
norm(v,Inf)

# ╔═╡ fa66b45a-0755-11eb-1cf8-8509ef135247
md"""
#### Matrix norms


 Matrix ``A= (a_{ij})\in \mathbb R^{n} \times \mathbb R^{n}``
 - Representation of linear operator       ``\mathcal A: \mathbb R^{n} \to \mathbb R^{n}`` defined by       ``\mathcal A: x\mapsto y=Ax`` with ``y_i= \sum_{j=1}^n a_{ij} x_j``
     
 - Vector norm ``||\cdot||_p`` induces corresponding matrix norm:

     ``||A||_p=\max_{x\in \mathbb R^n,x\neq 0} \frac{||Ax||_p}{||x||_p}
      =\max_{x\in \mathbb R^n,||x||_p=1} \frac{||Ax||_p}{||x||_p}``
"""

# ╔═╡ aa3cc202-0756-11eb-185b-2193e91fedf9
M=[3.0 2.0 3.0; 
   0.1 0.3 0.5; 
   0.6 2.0 3.0]

# ╔═╡ c95cbaa2-0756-11eb-1bc3-39e8978628f2
md"""
- ``||A||_1= \max_{j=1}^n \sum_{i=1}^n |a_{ij}|`` maximum of column  sums of absolute values of entries
"""

# ╔═╡ d3de46e4-0756-11eb-0afb-a12993be472f
opnorm(M,1)

# ╔═╡ e5de80c0-0756-11eb-13bb-c5277a8657d9
md"""
- ``||A||_2=\sqrt{\lambda_{max}}`` with ``\lambda_{max}``: largest eigenvalue of ``A^TA``.
"""

# ╔═╡ f4b01c12-0756-11eb-1bbb-cd985eceb276
opnorm(M,2), opnorm(M),sqrt(maximum(eigvals(M'*M)))

# ╔═╡ 43333c52-0757-11eb-0bd4-8d55d373663f
md"""
- ``||A||_\infty= \max_{i=1}^n \sum_{j=1}^n |a_{ij}| = ||A^T||_1`` maximum of row sums of absolute values of entries
"""

# ╔═╡ 5386385c-0757-11eb-146f-2ba456f3b141
opnorm(M,Inf),opnorm(M',1)

# ╔═╡ f145b298-0757-11eb-2a39-81e3eae68732
md"""
## Matrix condition number and error propagation

- Solve ``Ax=b``, where ``b`` is inexact
- Let ``\Delta b`` be the error in ``b`` and ``\Delta x`` be    the resulting error in ``x`` such that
   
     ``A(x+\Delta x)=b+\Delta b.`` 
 
- Since ``Ax=b``, we get ``A\Delta x=\Delta b``
- Therefore   ``\Delta x=A^{-1} \Delta b``
       
   ``||A||\cdot ||x||\geq||b||`` 

   ``||\Delta x||\leq ||A^{-1}||\cdot ||\Delta b||``

   ``\Rightarrow
   \frac{||\Delta x||}{||x||}
   \leq \kappa(A) \frac{||\Delta b||}{||b||}``
 
 where ``\kappa(A)= ||A||\cdot ||A^{-1}||`` is the *condition number* of ``A``.

This means that the relative error in the solution is proportional to the relative error of the right hand side. The proportionality factor ``\kappa(A)`` is usually larger (and in most relevant cases significantly larger) than one. Just remark that
this estimates does not assume inexact arithmetics.
"""

# ╔═╡ e44842a6-075f-11eb-3bde-033a382534a0
md"""
Let us have an example. We use rational arithmetics in order to obtain exact values:
"""

# ╔═╡ 46bcf25e-080c-11eb-0318-1777997a27af
T_test=Rational

# ╔═╡ c68c1eca-080b-11eb-2e0b-615717edcac8
a=T_test(1_000_000)

# ╔═╡ e8c1995c-080b-11eb-0e1b-57ed72f8a132
pert_b=T_test(1//1_000_000_000)

# ╔═╡ 661e1b68-0759-11eb-291d-2784e3eb53ba
A=[ 1 -1;
    a  a]

# ╔═╡ 89b9dccc-075b-11eb-272d-832ad3585a49
κ=opnorm(A)*opnorm(inv(A))

# ╔═╡ b5bd7948-0759-11eb-2253-3d328838aa0f
inv(A)

# ╔═╡ 7b9c1ec0-0760-11eb-292f-53c107cedfaf
md"""
Assume a solution vector:
"""

# ╔═╡ 98cfb558-0759-11eb-179b-eb79724273cd
x=[1,1]

# ╔═╡ 8940bb94-0760-11eb-1ca3-43edfc5ce911
md"""
Create corresponding right hand side:
"""

# ╔═╡ 94684000-080f-11eb-10e8-9598b369602b
b=A*x

# ╔═╡ c0ad6866-0760-11eb-3944-d1b49a337a6b
md"""
Define a perturbation of the right hand side:
"""

# ╔═╡ df573300-0759-11eb-0679-a520f177ead5
Δb=[pert_b, pert_b]

# ╔═╡ db09b0c0-0760-11eb-0793-c1cda30e7c23
md"""
Calculate the error with respect to the unperturbed solution:
"""

# ╔═╡ f4173742-0759-11eb-35f9-ada91a23883c
Δx=inv(A)*(b+Δb)-x

# ╔═╡ 2de0e4a8-0761-11eb-013e-212932e723e6
md"""
Relative error of right hand side:
"""

# ╔═╡ 57576354-075a-11eb-1d73-2d6a9412aba7
δb=norm(Δb)/norm(b)

# ╔═╡ 3d6394aa-0761-11eb-1d86-4d2dc4a0419c
md"""
Relative error of solution:
"""

# ╔═╡ 1241e4ba-075a-11eb-38df-1bb1b74ed44e
δx=norm(Δx)/norm(x)

# ╔═╡ 4432f8a4-0761-11eb-2831-91c0e848c67d
md"""
Comparison with condition number based estimate:
"""

# ╔═╡ 628aeb1a-075a-11eb-01d8-8de2ca6c2405
κ,δx/δb

# ╔═╡ 1550be6a-0811-11eb-2e70-f1c5fe9285f6
md"""
## Complexity: "big O notation"

  Let ``f,g: \mathbb V \to \mathbb R^+`` be some functions, where ``\mathbb V=\mathbb N`` or ``\mathbb V=\mathbb R``.

  Write 

```math
  f(x)=O(g(x)) \quad (x\to\infty) 
```
if there exists a constant ``C>0`` and ``x_0\in \mathbb V`` such that
     `` \forall x>x_0, \quad |f(x)|\leq C|g(x)|`` 

 Often, one skips the part "``(x \to \infty)``"
 
Examples:
  - Addition of two vectors: ``O(N)``
  - Matrix-vector multiplication (for matrix where all entries are assumed to be nonzero): ``O(N^2)``

"""

# ╔═╡ 2b1a17e2-0812-11eb-0211-79e5ca3d815e
md"""
### A Direct method: Cramer's rule

Solve $Ax=b$ by  Cramer's rule:

```math
x_i=\left|
    \begin{matrix}
      a_{11}&a_{12}&\ldots&a_{1i-1}&b_1&a_{1i+1}&\ldots&a_{1N}\\
      a_{21}&      &\ldots&        &b_2&        &\ldots&a_{2N}\\
      \vdots&      &      &        &\vdots&     &      &\vdots\\
      a_{N1}&      &\ldots&        &b_N&        &\ldots&a_{NN}
    \end{matrix}\right|
    / |A| \quad (i=1\dots N)
```

This takes     $O(N!)$ operations...

"""

# ╔═╡ 52d9bc72-0819-11eb-2fa2-691c3945def5
md"""
### Gaussian elimination and LU decomposition

So let us have a look at Gaussian elimination to solve ``Ax=b``.
The elementary matrix manipulation step in Gaussian elimination ist the multiplication of row k by ``-a_{jk}/a_{kk}`` and its addition to row j such that element
``_{jk}`` in the resulting matrix becomes zero. If this is done at once for all ``j>k``, we can express this operation as the left multiplication of ``A`` by a lower triangular Gauss transformation matrix ``M(A,k)``.  
"""

# ╔═╡ 94cdcbd0-0816-11eb-03d7-f59181081b02
function gausstransform(A,k)
	n=size(A,1)
	M=Matrix(one(eltype(A))I,n,n)
	for j=k+1:n
		M[j,k]=-A[j,k]/A[k,k]
	end
	M
end;

# ╔═╡ a7a6e6a4-0a72-11eb-34f1-c7660907183f
md"""
Define the number type for the following examples:
"""

# ╔═╡ 6276db6a-081e-11eb-0b52-094f4a3547be
T_lu=Rational

# ╔═╡ a60e1810-0a72-11eb-1cea-1546555701e9
md"""
Define a test matrix:
"""

# ╔═╡ 9a7790de-0816-11eb-04e2-7de97dfbf14f
A1=[2 1 3 4;
    5 6 7 8;
    7 6 8 5;
	3 4 2 T_lu(2)]	

# ╔═╡ d54e9954-0a72-11eb-3734-9787b5ac704f
md"""
This is the Gauss transform for  first column:
"""

# ╔═╡ 53dcdfb0-082a-11eb-0a08-adf08587add5
gausstransform(A1,1)

# ╔═╡ 72b75306-081b-11eb-1804-09e8c9b5ce1e
md"""
Applying it then sets all elements in the first column to zero besides of the main diagonal element:
"""

# ╔═╡ 2c314ed4-0817-11eb-3736-91c38f29725d
U1=gausstransform(A1,1)*A1

# ╔═╡ 9fd828ea-081b-11eb-29b4-1da4df221be2
md"""
We can repeat this with the second column:
"""

# ╔═╡ bfc79c24-0818-11eb-3c70-bdbe308eb7f5
U2=gausstransform(U1,2)*U1

# ╔═╡ fea411aa-0a72-11eb-3a89-e9103ecf4cf1
md"""
And the third column:
"""

# ╔═╡ f3325530-081e-11eb-158d-97fe2978c5e3
U3=gausstransform(U2,3)*U2

# ╔═╡ ac4403f4-081b-11eb-3be0-8326129a74e9
md"""
And here, we arrived at a triangular matrix. In the standard Gaussian elimination we would have manipulated the right hand side accordingly. 

From here on we would start the backsubstitution which in fact is the solution of a triangular system of equations.

However, let's have a look at what we have done here: we arrived at
```math
\begin{align}
U_1&=M(A,1)A\\
U_2&=M(U_1,2)U_1=M(U_1,2)M(A,1)A\\
U_3&=M(U_2,3)U_2=M(U_2,3)M(U_1,2)M(A,1)A
\end{align}
```
Thus, ``A=LU`` with ``L=M(A,1)^{-1}M(U_1,2)^{-1}M(U_2,3)^{-1}`` and ``U=U_3``
``L`` is a lower triangular matrix and ``U`` is a upper triangular matrix.

We can put this together into a function:
"""

# ╔═╡ 18bd1684-0818-11eb-3719-bbc66b19a46f
function lu_decomposition(A)
    n=size(A,1)
	L=Matrix(one(eltype(A))I,n,n) # L=I
	U=A
	for k=1:n-1
	   M=gausstransform(U,k)
	   L=L*inv(M)
	   U=M*U
	end
	L,U
end;

# ╔═╡ 868140a0-0818-11eb-31f3-97ceaa9e3ee6
Lx,Ux=lu_decomposition(A1)

# ╔═╡ 7f1e9ae6-081e-11eb-0a8c-37c2e5e4f46f
md"""
Check for correctness:
"""

# ╔═╡ a6ca35ee-0818-11eb-27c2-31db3f216318
Lx*Ux-A1

# ╔═╡ b6d7052c-081e-11eb-0e73-dfbcb5ce9f2b
md"""
So now we can write  ``A=LU``. 
Solving ``LUx=b`` then amounts to solve two tridiagonal systems:
```math
\begin{align}
   Ly&=b\\
   Ux&=y
\end{align}
```
"""

# ╔═╡ bc936a22-081f-11eb-31db-1de6f1dcd8cd
function lu_solve(L,U,b)
   y=inv(L)*b
   x=inv(U)*y
end

# ╔═╡ f7c14e8e-081f-11eb-20b0-0b0d5dfd36e4
b1=[1,2,3,4]

# ╔═╡ 0ba95716-0820-11eb-2a2e-85ba1889194c
x1=lu_solve(Lx,Ux,b1)

# ╔═╡ 2815bb92-0820-11eb-2070-0fbe9cc51801
md"""
Check...
"""

# ╔═╡ 1f08663a-0820-11eb-00d2-6f1abf7a9fe4
A1*x1-b1

# ╔═╡ ecf0d32a-0820-11eb-19c8-c7b25c9f88a0
md"""
... in order to be didactical, in this example, we made a very inefficient implementation by creating matrices in each step. We even cheated by using `inv` in order to solve a triangular system.
"""

# ╔═╡ 8a44392c-0822-11eb-1b27-63b7e8dad654
function better_ludecomposition!(LU,A)
	n = size(A,1)
    # decomposition of matrix, Doolittle’s Method
	if LU!=A
		LU.=A
	end
    for i = 1:n
        for j = 1:(i - 1)
            alpha = LU[i,j];
            for k = 1:(j - 1)
                alpha = alpha - LU[i,k]*LU[k,j];
            end
            LU[i,j] = alpha/LU[j,j];
        end
        for j = i:n
            alpha = LU[i,j];
            for k = 1:(i - 1)
                alpha = alpha - LU[i,k]*LU[k,j];
            end
            LU[i,j] = alpha;
        end
    end

end

# ╔═╡ 86969070-0822-11eb-3413-0b4ea4c0fdb9
function better_lusolve(LU,b)
    n = length(b);
    x = zeros(eltype(LU),n);
    y = zeros(eltype(LU),n);
    # LU= L+U-I
    # find solution of Ly = b
    for i = 1:n
        alpha = 0;
        for k = 1:i
            alpha = alpha + LU[i,k]*y[k];
        end
        y[i] = b[i] - alpha;
    end
    # find solution of Ux = y
    for i = n:-1:1
        alpha = 0;
        for k = (i + 1):n
            alpha = alpha + LU[i,k]*x[k];
        end
        x[i] = (y[i] - alpha)/LU[i, i];
    end    
	x
end

# ╔═╡ 8e2eed9c-0823-11eb-12cc-5158402bb8a1
begin
	global LU1=similar(A1)
	better_ludecomposition!(LU1,A1)
	LU1
end

# ╔═╡ 19042400-0824-11eb-12c2-6f3abcf33d35
x2=better_lusolve(LU1,b1)

# ╔═╡ 88aae398-0824-11eb-1f61-69ee34faf04b
A1*x2-b1

# ╔═╡ f55f7f58-0824-11eb-0d3c-896973fee2d2
function better_solve(A,b)
	LU=similar(A)
	better_ludecomposition!(LU,A)
	better_lusolve(LU,b)
end

# ╔═╡ 280a2750-0825-11eb-15d9-1b698affa368
x3=better_solve(A1,b1)

# ╔═╡ bbb84ac6-0826-11eb-0e9b-6b1052b422a2
x3-x2

# ╔═╡ 2439605a-0825-11eb-27d8-4b6081a391ef
function better_solve!(A,b)
	better_ludecomposition!(A,A)
	better_lusolve(A,b)
end

# ╔═╡ 852716f8-0825-11eb-125e-09c8f9ccd219
A2=copy(A1)

# ╔═╡ 8bb67cae-0825-11eb-38f4-25091d37bfa5
x4=better_solve!(A2,b1)

# ╔═╡ c53282f6-0826-11eb-2a46-a9ed5d4c95ab
x4-x3

# ╔═╡ 5564a86e-0821-11eb-08e9-511392c0f92f
md"""
#### Pivoting
So far, we ignored the possibility that a diagonal element becomes zero.

Pivoting tries to remedy the problem that  during the algorithm, diagonal elements can become zero. Before undertaking the next Gauss transformation step, we can exchange rows such that we always dividy by the largest of the remaining diagonal elements.
This would then in fact result in a decompositon
```math
PA=LU
```
where ``P`` is a permutation matrix which can be stored in an integer vector.  This approach is called "partial pivoting". Full pivoting in addition would perform column
permutations. This would result in another permutation matrix ``Q`` and the decomposition
```math
PAQ=LU
```
Almost all practically used LU decomposition implementations use partial pivoting.
"""

# ╔═╡ 0da631a4-0827-11eb-3dcd-fb59e166c995
md"""
Julia implements a pivoting LU factorization
"""

# ╔═╡ e9bf45f0-0826-11eb-034b-e99fcd8145f4
lu1=lu(A1)

# ╔═╡ faaa0d64-0826-11eb-347c-adc171c57373
lu1\b1

# ╔═╡ 4cad3a1e-0827-11eb-3a02-8d91f4c3c96a
A3=copy(A1)

# ╔═╡ 5199eb9e-0827-11eb-2089-c592541190a2
lu3=lu!(A3)

# ╔═╡ 727e6dbc-0827-11eb-3109-c91315e552f3
lu3\b1

# ╔═╡ 1b0d9364-0827-11eb-1d28-1f1d5122410e
lu([0 T_lu(1); 
  2 0])

# ╔═╡ 9b882b1c-0827-11eb-2dad-05b7d27a95c6
md"""
# TODO
- lu vs inv, Julia lu, lapack
- complexity
- what type of matrices is interesting ? differential operators (1/2/3D)
- progonka
- sparse
- homework: beat Julia: implement progonka
"""


# ╔═╡ Cell order:
# ╟─74e7b588-0753-11eb-10d5-f98133cdbd37
# ╟─a2859d7a-0753-11eb-2899-f1c7694422fe
# ╠═8cfb9372-0753-11eb-320a-f3aa8e25a8dc
# ╠═50551f36-0755-11eb-2ccd-111cbb151846
# ╠═a6634eec-0753-11eb-1e17-459995c901e5
# ╟─0debcc2e-0754-11eb-0d63-d97ee52fdbee
# ╠═d80a35a4-0754-11eb-3db4-a55fcc791545
# ╟─df02ce48-0754-11eb-3da1-9bed1696db10
# ╠═4290591c-0755-11eb-1fdf-a9bc1f928988
# ╟─716b78a0-0755-11eb-315a-cbbd504cc47f
# ╠═8d652e18-0755-11eb-08dc-9572175e54aa
# ╟─a4db244e-0755-11eb-1c84-4fe111f9ad64
# ╠═ba2c3360-0755-11eb-262e-3f088275edce
# ╠═fa66b45a-0755-11eb-1cf8-8509ef135247
# ╠═aa3cc202-0756-11eb-185b-2193e91fedf9
# ╟─c95cbaa2-0756-11eb-1bc3-39e8978628f2
# ╠═d3de46e4-0756-11eb-0afb-a12993be472f
# ╟─e5de80c0-0756-11eb-13bb-c5277a8657d9
# ╠═f4b01c12-0756-11eb-1bbb-cd985eceb276
# ╟─43333c52-0757-11eb-0bd4-8d55d373663f
# ╠═5386385c-0757-11eb-146f-2ba456f3b141
# ╟─f145b298-0757-11eb-2a39-81e3eae68732
# ╟─e44842a6-075f-11eb-3bde-033a382534a0
# ╠═46bcf25e-080c-11eb-0318-1777997a27af
# ╠═c68c1eca-080b-11eb-2e0b-615717edcac8
# ╠═e8c1995c-080b-11eb-0e1b-57ed72f8a132
# ╠═661e1b68-0759-11eb-291d-2784e3eb53ba
# ╠═89b9dccc-075b-11eb-272d-832ad3585a49
# ╠═b5bd7948-0759-11eb-2253-3d328838aa0f
# ╟─7b9c1ec0-0760-11eb-292f-53c107cedfaf
# ╠═98cfb558-0759-11eb-179b-eb79724273cd
# ╟─8940bb94-0760-11eb-1ca3-43edfc5ce911
# ╠═94684000-080f-11eb-10e8-9598b369602b
# ╟─c0ad6866-0760-11eb-3944-d1b49a337a6b
# ╠═df573300-0759-11eb-0679-a520f177ead5
# ╟─db09b0c0-0760-11eb-0793-c1cda30e7c23
# ╠═f4173742-0759-11eb-35f9-ada91a23883c
# ╟─2de0e4a8-0761-11eb-013e-212932e723e6
# ╠═57576354-075a-11eb-1d73-2d6a9412aba7
# ╟─3d6394aa-0761-11eb-1d86-4d2dc4a0419c
# ╠═1241e4ba-075a-11eb-38df-1bb1b74ed44e
# ╟─4432f8a4-0761-11eb-2831-91c0e848c67d
# ╠═628aeb1a-075a-11eb-01d8-8de2ca6c2405
# ╠═1550be6a-0811-11eb-2e70-f1c5fe9285f6
# ╠═2b1a17e2-0812-11eb-0211-79e5ca3d815e
# ╠═52d9bc72-0819-11eb-2fa2-691c3945def5
# ╠═94cdcbd0-0816-11eb-03d7-f59181081b02
# ╠═a7a6e6a4-0a72-11eb-34f1-c7660907183f
# ╠═6276db6a-081e-11eb-0b52-094f4a3547be
# ╠═a60e1810-0a72-11eb-1cea-1546555701e9
# ╠═9a7790de-0816-11eb-04e2-7de97dfbf14f
# ╠═d54e9954-0a72-11eb-3734-9787b5ac704f
# ╠═53dcdfb0-082a-11eb-0a08-adf08587add5
# ╠═72b75306-081b-11eb-1804-09e8c9b5ce1e
# ╠═2c314ed4-0817-11eb-3736-91c38f29725d
# ╠═9fd828ea-081b-11eb-29b4-1da4df221be2
# ╠═bfc79c24-0818-11eb-3c70-bdbe308eb7f5
# ╠═fea411aa-0a72-11eb-3a89-e9103ecf4cf1
# ╠═f3325530-081e-11eb-158d-97fe2978c5e3
# ╠═ac4403f4-081b-11eb-3be0-8326129a74e9
# ╠═18bd1684-0818-11eb-3719-bbc66b19a46f
# ╠═868140a0-0818-11eb-31f3-97ceaa9e3ee6
# ╠═7f1e9ae6-081e-11eb-0a8c-37c2e5e4f46f
# ╠═a6ca35ee-0818-11eb-27c2-31db3f216318
# ╠═b6d7052c-081e-11eb-0e73-dfbcb5ce9f2b
# ╠═bc936a22-081f-11eb-31db-1de6f1dcd8cd
# ╠═f7c14e8e-081f-11eb-20b0-0b0d5dfd36e4
# ╠═0ba95716-0820-11eb-2a2e-85ba1889194c
# ╠═2815bb92-0820-11eb-2070-0fbe9cc51801
# ╠═1f08663a-0820-11eb-00d2-6f1abf7a9fe4
# ╠═ecf0d32a-0820-11eb-19c8-c7b25c9f88a0
# ╠═8a44392c-0822-11eb-1b27-63b7e8dad654
# ╠═86969070-0822-11eb-3413-0b4ea4c0fdb9
# ╠═8e2eed9c-0823-11eb-12cc-5158402bb8a1
# ╠═19042400-0824-11eb-12c2-6f3abcf33d35
# ╠═88aae398-0824-11eb-1f61-69ee34faf04b
# ╠═f55f7f58-0824-11eb-0d3c-896973fee2d2
# ╠═280a2750-0825-11eb-15d9-1b698affa368
# ╠═bbb84ac6-0826-11eb-0e9b-6b1052b422a2
# ╠═2439605a-0825-11eb-27d8-4b6081a391ef
# ╠═852716f8-0825-11eb-125e-09c8f9ccd219
# ╠═8bb67cae-0825-11eb-38f4-25091d37bfa5
# ╠═c53282f6-0826-11eb-2a46-a9ed5d4c95ab
# ╠═5564a86e-0821-11eb-08e9-511392c0f92f
# ╠═0da631a4-0827-11eb-3dcd-fb59e166c995
# ╠═e9bf45f0-0826-11eb-034b-e99fcd8145f4
# ╠═faaa0d64-0826-11eb-347c-adc171c57373
# ╠═4cad3a1e-0827-11eb-3a02-8d91f4c3c96a
# ╠═5199eb9e-0827-11eb-2089-c592541190a2
# ╠═727e6dbc-0827-11eb-3109-c91315e552f3
# ╠═1b0d9364-0827-11eb-1d28-1f1d5122410e
# ╠═9b882b1c-0827-11eb-2dad-05b7d27a95c6

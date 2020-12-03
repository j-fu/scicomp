### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin 
	using Pkg
	Pkg.activate(mktempdir())
	Pkg.add("PyPlot")
	Pkg.add("PlutoUI")
	using PlutoUI
	using PyPlot
	using LinearAlgebra
end

# ╔═╡ a12dd656-2f42-11eb-0121-232559f8c5d8
md"""
### Tridiagonal systems

In the previous lecture (nb08) we introudced the discretization matrix for the 1D heat conduction problem. In general form it can be written as a tridiagonal matrix
$$A=	 \left(\begin{matrix}
    {b_1} & {c_1} & {   } & {   } & {  } \\
    {a_2} & {b_2} & {c_2} & {   } & {   } \\
    {   } & {a_3} & {b_3} & \ddots & {   } \\
   {   } & {   } & \ddots & \ddots & {c_{n-1}}\\
    {  } & {   } & {   } & {a_N} & {b_N}\\
\end{matrix}\right)$$

and stored in three arrays $a$,$b$,$c$.

"""

# ╔═╡ bb873226-2f43-11eb-25b7-a337aa24be5c
md"""

  Gaussian elimination using arrays $a,b,c$ as   matrix storage ?
 -   From what we have seen, this question arises in a quite natural way, and historically,
   the answer has been given several times and named differently
  - TDMA (tridiagonal matrix algorithm)
  - "Thomas algorithm" (Llewellyn H. Thomas, 1949 (?))
  - "Progonka method" (from Russian "прогонка":  "run through"; Gelfand, Lokutsievski, 1952, published 1960)

"""

# ╔═╡ d66daf7c-2f46-11eb-15c2-4d812fe88d24
md"""
#### Прогонка: derivation

Write solution of $A u=f$ as 

$a_i u_{i-1} + b_i u_i + c_i u_{i+1} = f_i \quad (i=1\dots N)$

where we define $a_1=0$, $c_N=0$.

- For $i=1\dots N-1$, assume there are coefficients $\alpha_i, \beta_i$ such that
$u_i=\alpha_{i+1}u_{i+1}+\beta_{i+1}$.
 - Re-arranging, we can express $u_{i-1}$ and $u_{i}$ via $u_{i+1}$:
$$(a_i\alpha_i\alpha_{i+1}+ b_i \alpha_{i+1} + c_i) u_{i+1} + (a_i\alpha_i\beta_{i+1}+ a_i\beta_i +b_i \beta_{i+1} -f_i)=0$$
 - This is true for arbitrary $u$ if
   $\begin{cases}
    a_i\alpha_i\alpha_{i+1}+ b_i \alpha_{i+1} + c_i&=0\\
    a_i\alpha_i\beta_{i+1}+ a_i\beta_i +b_i \beta_{i+1} -f_i &=0
   \end{cases}$

 - Re-arranging gives for ``i=1\dots N-1``: 
  $\begin{cases}
  \alpha_{i+1}&= -\frac{c_i}{a_i\alpha_i+b_i}\\
  \beta_{i+1} &= \frac{f_i - a_i\beta_i}{a_i\alpha_i+b_i}
  \end{cases}$
"""

# ╔═╡ fb002752-2f46-11eb-2157-e327139a92c6
md"""
#### Прогонка: realization

- Initialization of forward sweep:
$\begin{cases}
  \alpha_{2}&= -\frac{c_1}{b_1}\\
  \beta_{2} &= \frac{f_i}{b_1}
\end{cases}$

-  Forward sweep:  for $i=2\dots N-1$:  
$\begin{cases}
\alpha_{i+1}&= -\frac{c_i}{a_i\alpha_i+b_i}\\
\beta_{i+1} &= \frac{f_i - a_i\beta_i}{a_i\alpha_i+b_i}
\end{cases}$

- Initialization of backward sweep: $u_N=\frac{f_N - a_N\beta_N}{a_N\alpha_N+b_N}$
- Backward sweep: for $i= N-1 \dots 1$:
$u_i=\alpha_{i+1}u_{i+1}+\beta_{i+1}$

"""

# ╔═╡ 763e2eb8-2f48-11eb-3d2a-71866b4541d5
md"""
#### Прогонка: properties
 -   $N$ unknowns, one forward sweep, one backward sweep $\Rightarrow$   $O(N)$ operations vs. $O(N^{2.75})$ for algorithm using full matrix
 - No pivoting $\Rightarrow$ stability issues
 - Stability for diagonally dominant matrices where  $|b_i| > |a_i| + |c_i|$
 - Stability for symmetric positive definite matrices
 - In fact, this is a  realization of Gaussian elimination on a particular data structure.
"""

# ╔═╡ fde68d14-2f49-11eb-1070-197ff13c6cdc
md"""
### Tridiagonal matrices in Julia

In Julia, solution of a tridiagonal system is based on the LU factorization in the LAPACK routine `dgtsv` which also does pivoting.
"""

# ╔═╡ 2675ca66-2f49-11eb-0c96-df0ebe01f9a6
N=5

# ╔═╡ 24bf0d52-2f4b-11eb-0e70-d1b84966a75f
md"""
- LU Factorization in the case of a tridiagonal matrix with random diagonal entries
"""

# ╔═╡ 3fdaa814-2f49-11eb-1461-53cad42f3a12
A=Tridiagonal(rand(N-1),rand(N),rand(N-1))

# ╔═╡ 6493bbf0-2f49-11eb-2d91-1323d94e9a4a
lu(A)

# ╔═╡ dec5cfda-2f49-11eb-3380-df3fa789b4f1
lu(A).p

# ╔═╡ b9de72d2-2f4c-11eb-26b8-ff8eaea37726
A\ones(N)

# ╔═╡ 1300085a-2f4d-11eb-0cf7-9576c0ad3f65
md"""
Solving this system with a positive right hand side can yield negative solution components.
"""

# ╔═╡ a3bb5e8a-2f4b-11eb-264d-ab52c3a61156
md"""
We see that the in order to maintain stability, pivoting is performed: the LU factorization is performed as $PA=LU$ where $P$ is a permutation matrix. The underlying permutation can be obtained as `lu(A).p)`
"""

# ╔═╡ 174ce71a-2f4c-11eb-1626-7989e7ff73af
md"""
- Define a diagonally dominant matrix with random entries with positive main diagonal and nonpositive off-diagonal elements:
"""

# ╔═╡ bad5da00-2f49-11eb-3ab2-1d5e13ea503d
A1=Tridiagonal(-rand(N-1),rand(N).+2,-rand(N-1))

# ╔═╡ cdbb648e-2f49-11eb-3fe8-1557995f2780
lu(A1)

# ╔═╡ d6038dce-2f49-11eb-02aa-09bd435cea84
lu(A1).p

# ╔═╡ 28ecadfe-2f4c-11eb-3f66-5bc33fa7c1c1
md"""
Here we see, that no permutation is needed to maintain stability, confirming the statement made. In this case, the underlying algorithm is equivalent to Progonka, and the resulting LU factorization can be stored in three diagonals.
"""

# ╔═╡ d4d13368-2f4c-11eb-326a-57f93ddd8924
A1\ones(N)

# ╔═╡ 3840ad6e-2f4d-11eb-3fd2-c5f281e1ce94
md"""
Here we get only nonnegative solution values, though the matrix off-diagonal elements are nonpositive. Later we will see that this is a theorem for this type of matrices.
"""

# ╔═╡ dc00ceb4-2f4c-11eb-09f4-331df751f5e5
inv(A1)

# ╔═╡ 70078454-2f4d-11eb-38ed-5382faf3df03
md"""
The inverse is a nonnegative full matrix! This is a theorem as well.
"""

# ╔═╡ Cell order:
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╟─a12dd656-2f42-11eb-0121-232559f8c5d8
# ╟─bb873226-2f43-11eb-25b7-a337aa24be5c
# ╟─d66daf7c-2f46-11eb-15c2-4d812fe88d24
# ╟─fb002752-2f46-11eb-2157-e327139a92c6
# ╟─763e2eb8-2f48-11eb-3d2a-71866b4541d5
# ╟─fde68d14-2f49-11eb-1070-197ff13c6cdc
# ╠═2675ca66-2f49-11eb-0c96-df0ebe01f9a6
# ╟─24bf0d52-2f4b-11eb-0e70-d1b84966a75f
# ╠═3fdaa814-2f49-11eb-1461-53cad42f3a12
# ╠═6493bbf0-2f49-11eb-2d91-1323d94e9a4a
# ╠═dec5cfda-2f49-11eb-3380-df3fa789b4f1
# ╠═b9de72d2-2f4c-11eb-26b8-ff8eaea37726
# ╟─1300085a-2f4d-11eb-0cf7-9576c0ad3f65
# ╟─a3bb5e8a-2f4b-11eb-264d-ab52c3a61156
# ╟─174ce71a-2f4c-11eb-1626-7989e7ff73af
# ╠═bad5da00-2f49-11eb-3ab2-1d5e13ea503d
# ╠═cdbb648e-2f49-11eb-3fe8-1557995f2780
# ╠═d6038dce-2f49-11eb-02aa-09bd435cea84
# ╟─28ecadfe-2f4c-11eb-3f66-5bc33fa7c1c1
# ╠═d4d13368-2f4c-11eb-326a-57f93ddd8924
# ╟─3840ad6e-2f4d-11eb-3fd2-c5f281e1ce94
# ╠═dc00ceb4-2f4c-11eb-09f4-331df751f5e5
# ╟─70078454-2f4d-11eb-38ed-5382faf3df03

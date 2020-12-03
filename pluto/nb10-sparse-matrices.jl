### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 7d87b6dc-036d-11eb-06ac-0f859f68fa10
begin
	using Pkg;
	Pkg.activate(mktempdir())
	Pkg.add("PlutoUI")
	Pkg.add("PyPlot")
	Pkg.add("ExtendableSparse")
    Pkg.add("BenchmarkTools")
		
	using PlutoUI,PyPlot,BenchmarkTools
end;

# ╔═╡ b095159c-2f78-11eb-2d38-57093031eced
using SparseArrays,LinearAlgebra

# ╔═╡ f2c0f61e-2f7f-11eb-283d-814a026b5d25
using ExtendableSparse

# ╔═╡ b51447ec-2fd1-11eb-2c6c-33105b64f825
# A function to handle sizing and return of a pyplot figure
function pyplot(f;width=3,height=3)
		clf()
		f()
		fig=gcf()
		fig.set_size_inches(width,height)
		fig
	end

# ╔═╡ a4d0550c-036d-11eb-3f28-d7d519f48b7b
md"""
# Sparse matrices
"""

# ╔═╡ d45a0e2c-2f70-11eb-1016-df98d0b81272
md"""
In the previous lectures we found examples of matrices from partial differential equations which have only 3 of 5 nonzero diagonals. For 3D computations this would be 7 diagonals.  One can make use of this diagonal structure, e.g. when coding the progonka method. 

Matrices from unstructured meshes for finite element  or finite volume methods have a more irregular pattern, but as a rule only a few entries per row compared to the number of unknowns. In this case storing the diagonals becomes unfeasible.
"""

# ╔═╡ a178503a-2f71-11eb-109c-65bfd10243b8
md"""
__Definition__: We call a matrix *sparse* if  regardless of the number of unknowns $N$, the number of non-zero entries per row and per column remains limited by a constant $n_s$

-   If we find a scheme which allows to store only the non-zero matrix   entries, we would need not more than $Nn_s= O(N)$ storage locations instead of $N^2$
 -  The same would be true for the matrix-vector multiplication if we
  program it in such a way that we use every nonzero element just once:
  matrix-vector multiplication would use $O(N)$ instead of $O(N^2)$
  operations
"""

# ╔═╡ 4c50642e-2f71-11eb-01c0-7fcced661907
md"""
 - What is a good storage format for sparse matrices?
 - Is there a way to implement Gaussian elimination for general sparse matrices which allows for linear system solution with $O(N)$  operation ?
 - Is there a way to implement Gaussian elimination \emph{with pivoting} for general sparse matrices which allows for linear system solution  with $O(N)$ operations?
 -  Is there *any algorithm* for sparse linear system solution with $O(N)$ operations?
"""

# ╔═╡ 46f0bb2e-2f72-11eb-292e-53fe136d97fd
md"""
### Triplet storage format
"""

# ╔═╡ 58387f84-2f72-11eb-2f43-6fd37ba8c9db
md"""
- Store all nonzero elements along with their row and column indices
- One real, two integer arrays, length = nnz= number of nonzero elements
$(Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/saad-triplet.png",:width=>500))
(Y.Saad, Iterative Methods, p.92)

- Also known as Coordinate (COO) format

- This format often is used  as an intermediate format  for matrix construction
"""

# ╔═╡ f10923ca-2f73-11eb-3dc9-91376ebdd2f8
md"""
### Compressed Sparse Row (CSR) format

(aka Compressed Sparse Row (CSR) or IA-JA etc.)
- float array `AA`, length nnz, containing all nonzero elements row by row
- integer array `JA`, length nnz, containing the column indices of the elements of `AA`
-  integer array `IA`, length N+1, containing the start indizes  of each row in the arrays `IA` and `JA` and  `IA[N+1]=nnz+1` 
$A=  \left(\begin{matrix}
   1.& 0. & 0.& 2.& 0.\\
   3.& 4. & 0.& 5.& 0.\\
   6.& 0. & 7.& 8.& 9.\\
   0.& 0. & 10.& 11. & 0.\\
   0.& 0. & 0.& 0.& 12.
		\end{matrix}\right)$
$(Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/iaja.png",:width=>500))

- Used in many sparse matrix solver packages
"""

# ╔═╡ 45d57898-2f74-11eb-0f19-5b7ce2967002
md"""
### Compressed Sparse Column (CSC) format
- Uses similar principle  but stores the matrix column-wise. 
- Used in Julia
"""


# ╔═╡ 88ed88dc-2f7b-11eb-1fce-79d7d3ec1bf9
md"""
### Sparse matrices in Julia
"""

# ╔═╡ 1deedbba-2fd2-11eb-246f-633cefb8c3cb
md"""
##### Create sparse matrix from a full matrix
"""

# ╔═╡ 205244ea-2f79-11eb-0c6f-9dc090c847f9
A=Float64[1 0  0  2  0;
          3 4  0  5  0;
          6 0  7  8  9;
          0 0  10 11 0;
          0 0  0  0  12]

# ╔═╡ 74f3b47c-2f79-11eb-1e66-892b89b8bf0a
As=sparse(A)

# ╔═╡ 918e62b0-2f79-11eb-1d5d-d7d74104e0b5
As.colptr

# ╔═╡ ad2f38b4-2f79-11eb-0520-cf9389099855
As.rowval

# ╔═╡ b1a45438-2f79-11eb-31f2-51a4778c7610
As.nzval

# ╔═╡ fc955622-2f79-11eb-18a9-8315a3c84757
pyplot(width=2,height=2) do 
	spy(As,marker=".")
end

# ╔═╡ 2af5e218-2fd2-11eb-1f16-8fd5bcd2e0db
md"""
##### Create a random sparse matrix
"""

# ╔═╡ cf760af4-2f78-11eb-2692-294cd9596756
N=100

# ╔═╡ f10c83c6-2f78-11eb-316e-f149cf82b738
p=0.1

# ╔═╡ d8b0062c-2f78-11eb-30bf-833782edc9f2
md"""
 Random sparse matrix with probability p=$(p) that ``A_{ij}`` is nonzero:
"""

# ╔═╡ ee326bac-2f78-11eb-3086-b55ba8375f0c
A2=sprand(N,N,p)

# ╔═╡ 57ab5c18-2f7b-11eb-10ce-f15d877e6e6b
pyplot(width=3,height=3) do 
	spy(A2,marker=".",markersize=0.5)
end

# ╔═╡ 9fc0eb9e-2f7b-11eb-285c-d95b12605942
md"""
##### Create a sparse matrix from given data

- There are several possibilities to create a sparse matrix for given data
- As an example, we create a tridiagonal matrix.
"""

# ╔═╡ c60cec76-2f7b-11eb-1dd6-5f0c1f435c68
N1=10000

# ╔═╡ af702546-2f7b-11eb-15d3-f98abbc44248
a=rand(N1-1)

# ╔═╡ d008f044-2f7b-11eb-0526-c17829299cc8
b=rand(N1)

# ╔═╡ d9988f8e-2f7b-11eb-29cc-857c7a32b2c0
c=rand(N1-1)

# ╔═╡ 191b8832-2f7c-11eb-1abd-41cecfd0bce9
md"""
- Special case: use the Julia tridiagonal matrix constructor
"""

# ╔═╡ e1528374-2f7b-11eb-0833-1f446ba84d24
sptri_special(a,b,c)=sparse(Tridiagonal(a,b,c))

# ╔═╡ 44b0ef9c-2fd0-11eb-0598-3f58c2b0521c
md"""
- Create an empty Julia sparse matrix and fill it incrementally
"""

# ╔═╡ be1efea2-2fd8-11eb-1501-254e7c26c175
B=spzeros(10,10)

# ╔═╡ c735fe78-2fd8-11eb-01f0-5962d860a731
B[1,2]=3

# ╔═╡ cdd60f5c-2fd8-11eb-262d-ed7d6055122d
B

# ╔═╡ 40068618-2f7c-11eb-1c6d-811ebd42a449
function sptri_incremental(a,b,c)
	N=length(b)
	A=spzeros(N,N)
	A[1,1]=b[1]
	A[1,2]=c[1]
	for i=2:N-1
		A[i,i-1]=a[i-1]
		A[i,i]=b[i]
		A[i,i+1]=c[i]
	end
	A[N,N-1]=a[N-1]
	A[N,N]=b[N]
	A
end

# ╔═╡ 5e4cc17e-2fd0-11eb-0e5a-c5bd1e9c5586
md"""
- Use the coordinate format as intermediate storage, and construct sparse matrix from there. This is the recommended way.
"""

# ╔═╡ fec84866-2f7c-11eb-0cae-93c3dea56e54
function sptri_coo(a,b,c)
	N=length(b)
	II=[1,1]
	JJ=[1,2]
	AA=[b[1],c[1]]
	for i=2:N-1
		push!(II,i)
		push!(JJ,i-1)
		push!(AA,a[i-1])
		
		push!(II,i)
		push!(JJ,i)
		push!(AA,b[i])

		push!(II,i)
		push!(JJ,i+1)
		push!(AA,c[i])

	end
	push!(II,N)
	push!(JJ,N-1)
	push!(AA,a[N-1])
	
	push!(II,N)
	push!(JJ,N)
	push!(AA,b[N])
	
	sparse(II,JJ,AA)
end

# ╔═╡ 728b6940-2fd0-11eb-0d68-77c7a856171b
md"""
- Use the [ExtendableSparse.jl](https://github.com/j-fu/ExtendableSparse.jl) package which implicitely uses the so-called linked list format for intermediate storage  of new entries. Note the flush!() method which needs to be called in order to transfer them to the Julia sparse matrix structure.
"""

# ╔═╡ fe72f8c4-2f7f-11eb-3843-5f8446790b04
function sptri_ext(a,b,c)
	N=length(b)
	A=ExtendableSparseMatrix(N,N)
	A[1,1]=b[1]
	A[1,2]=c[1]
	for i=2:N-1
		A[i,i-1]=a[i-1]
		A[i,i]=b[i]
		A[i,i+1]=c[i]
	end
	A[N,N-1]=a[N-1]
	A[N,N]=b[N]
	flush!(A)
end

# ╔═╡ 4993ecc0-2f81-11eb-3abe-e53badac5af6
@benchmark sptri_special(a,b,c)

# ╔═╡ a6941e3e-2f81-11eb-3135-edc74bbaa307
@benchmark sptri_incremental(a,b,c)

# ╔═╡ d893e272-2f81-11eb-18f1-b39e880601c4
@benchmark sptri_coo(a,b,c)

# ╔═╡ f04222c6-2f81-11eb-01a1-27fdaa9116a5
@benchmark sptri_ext(a,b,c)

# ╔═╡ c995519e-2fd0-11eb-266a-05b500df55c5
md"""
Benchmark summary:
- The incremental creation of a SparseMartrixCSC from an initial state with non nonzero entries is slow because of the data shifts and reallocations necessary during the construction
- The COO intermediate format is sufficiently fast, but inconvenient
- The ExtendableSparse package provides has similar peformance and is easy to use.
"""

# ╔═╡ cf1acb64-2f74-11eb-0018-91e006653364
md"""
## Sparse direct solvers

-  Sparse direct solvers implement LU factorization with different  pivoting strategies. Some examples:
  - UMFPACK: e.g. used in Julia
  - Pardiso (omp + MPI parallel)
  - SuperLU (omp parallel)
  - MUMPS (MPI parallel)
  - Pastix
- Quite efficient for 1D/2D problems - we will discuss this more deeply
- Essentially they implement the LU factorization algorithm
- They suffer from *fill-in*, especially for 3D problems:  
 Let $A=LU$ be an LU-Factorization. Then, as 
 a rule, $nnz(L+U) >> nnz(A)$.
  - increased memory usage to store L,U
  - high operation count
"""

# ╔═╡ 63cc776c-2fd1-11eb-0144-b32b3055ae9c
pyplot(width=3,height=3) do 
	spy(A2,marker=".",markersize=0.5)
end

# ╔═╡ 65a29588-2fd1-11eb-25df-83a535446473
pyplot(width=3,height=3) do 
	spy(lu(A2).L,marker=".",markersize=0.5)
end

# ╔═╡ 7dbd7a52-2fd1-11eb-1ac7-3fb35845f75a
pyplot(width=3,height=3) do 
	spy(lu(A2).U,marker=".",markersize=0.5)
end

# ╔═╡ 84d11178-2fd1-11eb-2f60-73ff907ffad4
nnz(A2), nnz(lu(A2))

# ╔═╡ 351cbc56-2f75-11eb-33d1-3f0ce34bf1aa
md"""
#### Solution steps with sparse direct solvers
1. Pre-ordering
  -  Decrease amount of non-zero elements generated by fill-in    by re-ordering of the matrix
  -  Several, graph theory based heuristic algorithms exist
2. Symbolic factorization
  - If pivoting is ignored, the indices of the non-zero elements are calculated and stored
  -  Most expensive step wrt. computation time
3.  Numerical factorization
  - Calculation of the numerical values of the nonzero entries
  - Moderately expensive, once the symbolic factors are available
4. Upper/lower triangular system solution
  - Fairly quick in comparison to the other steps

"""

# ╔═╡ 5f3a460a-2f75-11eb-3553-f5fcf863bdad
md"""
-  Separation of steps 2 and 3 allows to save computational costs for problems where the sparsity structure remains unchanged, e.g. time dependent problems on fixed computational grids
-  With pivoting, steps 2 and 3 have to be performed together, and pivoting can increase fill-in
-  Instead of pivoting, *iterative refinement* may be used in order to maintain accuracy of the solution

"""

# ╔═╡ d61e2c52-2fcf-11eb-1a97-8f6f0fa1c76a
md"""
Influence of reordering
- Sparsity patterns for original matrix with three different orderings of unknowns
   - number of nonzero elements (of course) independent of ordering:
  $(Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/ReorderingAndFactorizationOfSparseMatricesExample_01.png",:width=>700))(mathworks.com)
- Sparsity patterns for corresponding LU factorizations
  - number of nonzero elements depend original ordering!
  $(Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/ReorderingAndFactorizationOfSparseMatricesExample_02.png",:width=>700))(mathworks.com)

"""

# ╔═╡ e56b2430-2fcf-11eb-32c2-8b119ca2de09
md"""
## Sparse direct solvers: Complexity estimate
- Complexity estimates depend on storage scheme, reordering etc.
- Sparse matrix - vector multiplication has complexity $O(N)$
- Some estimates can be given  from graph theory   for discretizations of heat equation  with $N=n^d$ unknowns  on close to cubic grids in space dimension $d$
- sparse LU factorization:

$\begin{array}{ccc}
         d & work & storage\\
         \hline
         1 & O(N) \;|\; O(n)             & O(N)\;|\;O(n)\\
         2 & O(N^{\frac32}) \;|\; O(n^3) & O(N\log N) \;|\; O(n^2\log n)\\
         3&  O(N^2)\;|\; O(n^6)         & O(N^{\frac43})\;|\; O(n^4)
\end{array}$

- triangular solve: work dominated by storage complexity

$\begin{array}{cc}
         d & work\\
         \hline
         1 & O(N)\;|\;O(n)\\
         2 & O(N\log N) \;|\; O(n^2\log n)\\
         3 & O(N^{\frac43})\;|\; O(n^4)
\end{array}$

(Source: J. Poulson, [PhD thesis](http://hdl.handle.net/2152/ETD-UT-2012-12-6622))

"""

# ╔═╡ e23ca8d0-2fd2-11eb-1d61-6f9dcdf4d3ed
md"""
#### Practical use
- `\` operator
"""

# ╔═╡ f9f4da2e-2fd2-11eb-33b8-41cc70601c30
Asparse_incr=sptri_incremental(a,b,c);

# ╔═╡ 0c0f842a-2fd3-11eb-03b5-6d48a781f289
Asparse_incr\ones(N1)

# ╔═╡ c562b344-2fd2-11eb-1854-69f499be5097
Asparse_ext=sptri_ext(a,b,c)

# ╔═╡ ce232f7c-2fd2-11eb-05b5-e90c7589b77e
Asparse_ext\ones(N1)

# ╔═╡ Cell order:
# ╠═7d87b6dc-036d-11eb-06ac-0f859f68fa10
# ╠═b51447ec-2fd1-11eb-2c6c-33105b64f825
# ╟─a4d0550c-036d-11eb-3f28-d7d519f48b7b
# ╟─d45a0e2c-2f70-11eb-1016-df98d0b81272
# ╟─a178503a-2f71-11eb-109c-65bfd10243b8
# ╟─4c50642e-2f71-11eb-01c0-7fcced661907
# ╟─46f0bb2e-2f72-11eb-292e-53fe136d97fd
# ╟─58387f84-2f72-11eb-2f43-6fd37ba8c9db
# ╟─f10923ca-2f73-11eb-3dc9-91376ebdd2f8
# ╟─45d57898-2f74-11eb-0f19-5b7ce2967002
# ╟─88ed88dc-2f7b-11eb-1fce-79d7d3ec1bf9
# ╠═b095159c-2f78-11eb-2d38-57093031eced
# ╟─1deedbba-2fd2-11eb-246f-633cefb8c3cb
# ╠═205244ea-2f79-11eb-0c6f-9dc090c847f9
# ╠═74f3b47c-2f79-11eb-1e66-892b89b8bf0a
# ╠═918e62b0-2f79-11eb-1d5d-d7d74104e0b5
# ╠═ad2f38b4-2f79-11eb-0520-cf9389099855
# ╠═b1a45438-2f79-11eb-31f2-51a4778c7610
# ╠═fc955622-2f79-11eb-18a9-8315a3c84757
# ╟─2af5e218-2fd2-11eb-1f16-8fd5bcd2e0db
# ╠═cf760af4-2f78-11eb-2692-294cd9596756
# ╠═f10c83c6-2f78-11eb-316e-f149cf82b738
# ╟─d8b0062c-2f78-11eb-30bf-833782edc9f2
# ╠═ee326bac-2f78-11eb-3086-b55ba8375f0c
# ╠═57ab5c18-2f7b-11eb-10ce-f15d877e6e6b
# ╟─9fc0eb9e-2f7b-11eb-285c-d95b12605942
# ╠═c60cec76-2f7b-11eb-1dd6-5f0c1f435c68
# ╠═af702546-2f7b-11eb-15d3-f98abbc44248
# ╠═d008f044-2f7b-11eb-0526-c17829299cc8
# ╠═d9988f8e-2f7b-11eb-29cc-857c7a32b2c0
# ╟─191b8832-2f7c-11eb-1abd-41cecfd0bce9
# ╠═e1528374-2f7b-11eb-0833-1f446ba84d24
# ╟─44b0ef9c-2fd0-11eb-0598-3f58c2b0521c
# ╠═be1efea2-2fd8-11eb-1501-254e7c26c175
# ╠═c735fe78-2fd8-11eb-01f0-5962d860a731
# ╠═cdd60f5c-2fd8-11eb-262d-ed7d6055122d
# ╠═40068618-2f7c-11eb-1c6d-811ebd42a449
# ╟─5e4cc17e-2fd0-11eb-0e5a-c5bd1e9c5586
# ╠═fec84866-2f7c-11eb-0cae-93c3dea56e54
# ╟─728b6940-2fd0-11eb-0d68-77c7a856171b
# ╠═f2c0f61e-2f7f-11eb-283d-814a026b5d25
# ╠═fe72f8c4-2f7f-11eb-3843-5f8446790b04
# ╠═4993ecc0-2f81-11eb-3abe-e53badac5af6
# ╠═a6941e3e-2f81-11eb-3135-edc74bbaa307
# ╠═d893e272-2f81-11eb-18f1-b39e880601c4
# ╠═f04222c6-2f81-11eb-01a1-27fdaa9116a5
# ╟─c995519e-2fd0-11eb-266a-05b500df55c5
# ╟─cf1acb64-2f74-11eb-0018-91e006653364
# ╠═63cc776c-2fd1-11eb-0144-b32b3055ae9c
# ╠═65a29588-2fd1-11eb-25df-83a535446473
# ╠═7dbd7a52-2fd1-11eb-1ac7-3fb35845f75a
# ╠═84d11178-2fd1-11eb-2f60-73ff907ffad4
# ╟─351cbc56-2f75-11eb-33d1-3f0ce34bf1aa
# ╟─5f3a460a-2f75-11eb-3553-f5fcf863bdad
# ╟─d61e2c52-2fcf-11eb-1a97-8f6f0fa1c76a
# ╟─e56b2430-2fcf-11eb-32c2-8b119ca2de09
# ╟─e23ca8d0-2fd2-11eb-1d61-6f9dcdf4d3ed
# ╠═f9f4da2e-2fd2-11eb-33b8-41cc70601c30
# ╠═0c0f842a-2fd3-11eb-03b5-6d48a781f289
# ╠═c562b344-2fd2-11eb-1854-69f499be5097
# ╠═ce232f7c-2fd2-11eb-05b5-e90c7589b77e

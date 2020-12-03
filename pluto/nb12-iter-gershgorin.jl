### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin 
	using Pkg
	Pkg.activate(mktempdir())
	Pkg.add("PyPlot")
	Pkg.add("PlutoUI")
	Pkg.add("GraphPlot"); 
	Pkg.add("LightGraphs"); 
	Pkg.add("Colors")

	using PlutoUI
	using PyPlot
	using LinearAlgebra
	using SparseArrays
	
	using GraphPlot, LightGraphs,Colors

	function pyplot(f;width=3,height=3)
		clf()
		f()
		fig=gcf()
		fig.set_size_inches(width,height)
		fig
	end

	
end

# ╔═╡ f30f2b30-34fd-11eb-3f4e-6349444d781b
md"""
# Eigenvalue analysis for more general matrices

For 1D heat conduction we had a very special regular structure of the matrix
which allowed exact eigenvalue calculations.

We need a generalization to varying coefficients, nonsymmetric problems, unstructured grids $\dots$\\

$\Rightarrow$ what can be done for general matrices ?

"""

# ╔═╡ c73748bc-34f3-11eb-2e80-8d8fcaf6e360
md"""
## The Gershgorin Circle Theorem

  __Theorem__ (Varga, Th. 1.11) Let $A$ be an $n\times n$ (real or complex) matrix. Let
  $\Lambda_i$ be the sum of the absolute values of the $i$-th row's off-diagonal entries:

$\Lambda_i=\sum_{\substack{j=1\dots n\\j\neq i}} |a_{ij}|$

If $\lambda$ is an eigenvalue of $A$, then there exists $r$,
  $1\leq r\leq n$ such that $\lambda$ lies on the disk defined by the circle of radius $\Lambda_r$ around
  $a_{rr}$:
  
$|\lambda - a_{rr}|\leq \Lambda_r$
"""

# ╔═╡ d2a6b6c4-34f3-11eb-08aa-79ae41051c52
md"""
__Proof__: Assume $\lambda$ is an eigenvalue, $\vec x=(x_1\dots x_n)$ is a corresponding
  eigenvector.
  Assume $\vec x$ is normalized such that

$\max_{i=1\dots n} |x_i|=|x_r|=1.$

  From $A\vec x=\lambda \vec x$ it follows that
 
$\begin{aligned}
    \lambda x_i&=\sum_{j=1\dots n} a_{ij} x_j\\
    (\lambda - a_{ii})x_i&=\sum_{\substack{j=1\dots n\\j\neq i}} a_{ij} x_j\\
    |\lambda - a_{rr}|&=\big|\sum_{\substack{j=1\dots n\\j\neq r}} a_{rj} x_j\big|  
    \leq\sum_{\substack{j=1\dots n\\j\neq r}} |a_{rj}| |x_j|
    \leq\sum_{\substack{j=1\dots n\\j\neq r}} |a_{rj}|=\Lambda_r\\
\end{aligned}$ $\square$
"""

# ╔═╡ e125ff72-34f6-11eb-2452-c19ad4764372
md"""
 __Corollary__ Any eigenvalue $\lambda \in \sigma(A)$ lies in the union of the
  disks defined by the Gershgorin circles
  
$\begin{aligned}
  \lambda \in \bigcup_{i=1\dots n} \{\mu\in\mathbb C: |\mu - a_{ii}|\leq \Lambda_i\}
\end{aligned}$

__Corollary__ The Gershgorin circle theorem allows to estimate the spectral radius $\rho(A)$:

$\begin{aligned}
    \rho(A) \leq \max_{i=1\dots n} \sum_{j=1}^n |a_{ij}| = ||A||_\infty,\\
    \rho(A) \leq \max_{j=1\dots n} \sum_{i=1}^n |a_{ij}| = ||A||_1.
	\end{aligned}$

  __Proof__:

$\begin{aligned}
 |\mu - a_{ii} |\leq \Lambda_i\quad \Rightarrow \quad |\mu| \leq \Lambda_i+ |a_{ii}|=\sum_{j=1}^n |a_{ij}|
	\end{aligned}$

Furthermore, $\sigma(A)= \sigma(A^T)$.

$\square$

"""

# ╔═╡ efabb49a-34ee-11eb-0990-e310f2557948
md"""
This appears to be very easy to use, so let us try:
"""

# ╔═╡ 0ded215e-34f0-11eb-13a9-49010795133a
function gershgorin_circles(A)
	t=0:0.01*π:2π
	
	# α is the trasnparency value.
	circle(x,y,r;α=0.3)=fill(x.+r.*cos.(t),y.+r.*sin.(t),alpha=α)	
	
	n=size(A,1)
	for i=1:n
		Λ=0
		for j=1:n
			if j!=i
				Λ+=abs(A[i,j])
			end
		end
		circle(real(A[i,i]),imag(A[i,i]),Λ,α=0.5/n)
	end

	σ=eigvals(Matrix(A))
	scatter(real(σ),imag(σ),sizes=10*ones(n),color=:red)
end

# ╔═╡ 289402f6-34f1-11eb-3b4a-f5bbeaf61426
n1=5

# ╔═╡ 239724b8-34f1-11eb-251a-17c7e258c9ec
A1=rand(n1,n1)+0.1*rand(n1,n1)*1im

# ╔═╡ 37e32e88-34f1-11eb-0f86-859bafcb6003
eigvals(A1)

# ╔═╡ 33201ef0-34ed-11eb-3325-99a0c8c9290d
pyplot(width=5, height=5) do
	gershgorin_circles(A1)
	xlabel("Re")
	ylabel("Im")
	PyPlot.grid(color=:gray)
end

# ╔═╡ c52e79ce-358a-11eb-2d6a-97e2617cb782
md"""
So this is kind of cool!  Let us try this out with our heat example and
the Jacobi iteration matrix: $B=I-D^{-1}A$ 
"""

# ╔═╡ f7f9144a-34f4-11eb-03f5-b7e5d285520a
function heatmatrix1d(N;α=100)
	A=zeros(N,N)
	h=1/(N-1)
	A[1,1]=1/h+α
	for i=2:N-1
		A[i,i]=2/h	
	end
	for i=1:N-1
		A[i,i+1]=-1/h
	end
	for i=2:N
		A[i,i-1]=-1/h
	end
	A[N,N]=1/h+α
	A
end

# ╔═╡ 9bbf3466-34f7-11eb-0dfa-bb462f114d6c
jacobi_iteration_matrix(A)=I-inv(Diagonal(A))*A

# ╔═╡ ac88d208-34f6-11eb-109b-eb62fe6166d6
N=10

# ╔═╡ 19008d1a-34f5-11eb-3cd3-73a7fcac9dd4
A2=Tridiagonal(heatmatrix1d(N))

# ╔═╡ 3512363e-34f5-11eb-369c-6f181afdad8e
B2=jacobi_iteration_matrix(A2)

# ╔═╡ 2066fbae-34f6-11eb-38a4-ebf10b38f6a9
ρ2=maximum(abs.(eigvals(Matrix(B2))))

# ╔═╡ d7ade3ec-3591-11eb-1667-0be149f44d3c
md"""
 
We have $b_{ii}=0$, $\Lambda_i=
  \begin{cases}
    \frac{1}{1+αh},& i=1,n\\
    1& i=2\dots n-1
\end{cases}$ 

We see two circles around 0: one with radius 1 and one with radius $\frac1{1+αh}$

 $\Rightarrow$ estimate $|\lambda_i|\leq 1$


"""

# ╔═╡ ab813022-34f5-11eb-09aa-89b1396994e4
md"""
We can also caculate the value from the estimate: Gershgorin circles of $B2$  are centered in the origin, and the spectral radius estimate just consists in the maximum of the sum of the absolute values of the row entries.
"""

# ╔═╡ 3b93fe56-34f6-11eb-05d2-c16a9fe80018
ρ2_gershgorin=maximum([sum( abs.(B2[i,:])) for i=1:size(B2,1)])

# ╔═╡ dfeddf74-34f5-11eb-0e6d-29ec13b73d1a
pyplot(width=5, height=5) do
	gershgorin_circles(B2)
		xlabel("Re")
	ylabel("Im")

	PyPlot.grid(color=:gray)
end

# ╔═╡ 30a5cf58-34f9-11eb-267c-034ab805597e
md"""
So the estimate from the Gershgorin Circle theorem is very pessimistic...
Can we improve this ?


## Matrices and Graphs
"""

# ╔═╡ 523f62ac-34f9-11eb-1001-49e912bb41c0
md"""
-    Permutation matrices are matrices which have exactly one non-zero entry in each row
    and each column which has value $1$.
    
- There is a one-to-one correspondence permutations $\pi$ of the the numbers $1\dots n$
    and  $n\times n$ permutation matrices $P=(p_{ij})$ such that
$\begin{aligned}
      p_{ij}=
      \begin{cases}
        1, & \pi(i)=j\\
        0, &\text{else}
\end{cases}
\end{aligned}$
- Permutation matrices are orthogonal, and we have $P^{-1}=P^T$
- $ A \rightarrow  PA$ permutes the rows of $A$ 
- $ A \rightarrow AP^T$ permutes the columns of $A$ 
 
"""

# ╔═╡ 6849ab64-34f9-11eb-3e1d-63c14c1ada95
md"""
Define a directed graph from the nonzero entries of a matrix $A=(a_{ik})$:
- Nodes: $\mathcal N= \{N_i\}_{i=1\dots n}$
- Directed edges: $\mathcal E= \{ \overrightarrow{N_k N_l}| a_{kl}\neq 0\}$
- Matrix entries  $\equiv$  weights of directed edges 
- 1:1 equivalence between matrices and weighted directed graphs
"""

# ╔═╡ d20cf9ce-34fa-11eb-3751-81edd95c2538
md"""
Create a bidirectional graph (digraph) from a matrix in Julia. Create edge labels from off-diagonal entries and node labels combined from diagonal entries and node indices.
"""

# ╔═╡ c30ad798-34fa-11eb-2247-05c7d352f335
function create_graph(matrix)
	@assert size(matrix,1)==size(matrix,2) 
	n=size(matrix,1)
	g=LightGraphs.SimpleDiGraph(n)
	elabel=[]
	nlabel=Any[]
    for i in 1:n 
		push!(nlabel,"""$(i) \n $(matrix[i,i])""")
    	for j in 1:n
	    	if i!=j && matrix[i,j]>0
		    	add_edge!(g,i,j)
				push!(elabel,matrix[i,j])
		    end
	    end
     end
	g,nlabel,elabel
end

# ╔═╡ e7c40ece-34fa-11eb-00e3-25dd0e9282a4
# sparse random matrix with entries with limited numbers decimal values
rndmatrix(n,p)=rand(0:0.01:1,n,n).*Matrix(sprand(Bool,n,n,p))

# ╔═╡ 0403538a-34fb-11eb-38f3-29208e82cf8f
A3=rndmatrix(5,0.3)

# ╔═╡ 3c7a296c-34fb-11eb-16fc-834cc4887d99
graph3,nlabel3,elabel3=create_graph(A3)

# ╔═╡ d8a080ce-34fc-11eb-2d52-fd2674725c7e
GraphPlot.gplot(graph3,
	nodelabel=nlabel3,
	edgelabel=elabel3,
	nodefillc=RGB(1.0,0.6,0.5),
	EDGELABELSIZE=6.0,
	NODESIZE=0.1,
	EDGELINEWIDTH=1
)

# ╔═╡ 60eebc2e-34fb-11eb-2bb5-c3f952b201d7
md"""
- Matrix graph of $A3$ is strongly connected: __$(is_strongly_connected(graph3))__
- Matrix graph of $A3$ is weakly connected: __$(is_weakly_connected(graph3))__
"""

# ╔═╡ 8ff2e5d4-34fb-11eb-1f07-4d0b975f7053
md"""
__Definition__ A square matrix $A$ is _reducible_ if there exists a
  permutation matrix $P$ such that

  $\begin{aligned}
    PAP^T
    =\begin{pmatrix}
      A_{11} & A_{12}\\
      0      & A_{22}
    \end{pmatrix}
	\end{aligned}$

  $A$ is _irreducible_ if it is not reducible.


  __Theorem__ (Varga, Th. 1.17):
  $A$ is irreducible $\Leftrightarrow$ the matrix graph is strongly connected,
  i.e. for each _ordered_ pair $(N_i,N_j)$ there is a path consisting
  of directed edges, connecting them.

  Equivalently, for each $i,j$ there is a sequence of consecutive nonzero matrix
  entries $a_{ik_1}, a_{k_1k_2}, a_{k_2k_3} \dots, a_{k_{r-1}k_r} a_{k_rj}$.

"""

# ╔═╡ 918bc776-3500-11eb-31a7-23e5ce51123b
md"""
## The Taussky theorem
"""

# ╔═╡ dd9c8236-34fb-11eb-132e-79a9260a25cb
md"""
  __Theorem__ (Varga, Th. 1.18) Let $A$ be irreducible. Assume that the eigenvalue
  $\lambda$ is a boundary point of the union of all the disks

$\begin{aligned}
    \lambda \in \partial \bigcup_{i=1\dots n} \{\mu\in\mathbb C: |\mu - a_{ii} |\leq \Lambda_i\}
\end{aligned}$

  Then, all $n$ Gershgorin circles pass through $\lambda$, i.e. for
  $i=1\dots n$,

$\begin{aligned}
    |\lambda - a_{ii}| = \Lambda_i
\end{aligned}$


"""

# ╔═╡ f7695ea0-34fb-11eb-3982-577982e0476a
md"""
  __Proof__ Assume $\lambda$ is eigenvalue, $\vec x$ a corresponding
  eigenvector, normalized such that $\max_{i=1\dots n} |x_i|=|x_r|=1$.
  From $A\vec x=\lambda \vec x$ it follows that

$\begin{aligned}
   (\lambda -a_{rr})x_r &=\sum_{\substack{j=1\dots n\\ j\neq r}} a_{rj} x_j\\ 
   |\lambda - a_{rr}|& \leq \sum_{\substack{j=1\dots n \\ j\neq r}} |a_{rj}|\cdot |x_j|\\
   &\leq\sum_{\substack{j=1\dots n\\ j\neq r}} |a_{rj}|=\Lambda_r \quad \text{(*)}
\end{aligned}$

 $\lambda$ is  boundary point $\Rightarrow$ $|\lambda - a_{rr}|=\sum\limits_{\substack{j=1\dots n \\ j\neq r}} |a_{rj}|\cdot |x_j| =\Lambda_r$

  $\Rightarrow$ For all $p\neq r$ with $a_{rp}\neq 0$, $|x_p|=1$.

  Due to irreducibility there is at least one  $p$ with $a_{rp}\neq 0$. For this $p$, $|x_p|=1$ and
  equation (*) is valid (with $p$ in place of $r$)  $\Rightarrow$
  $|\lambda - a_{pp}|=\Lambda_p$

  Due to irreducibility, this is true for all $p=1\dots n$. $\square$

"""

# ╔═╡ 35c9dc40-34fc-11eb-2c9b-2917c215d6f9
md"""
Apply this to the Jacobi iteration matrix for the heat conduction problem:
We know that  $|\lambda_i|\leq 1$, and we can see that the matrix graph is
strongly connected.
  
Assume $|\lambda_i|=1$.  Then $\lambda_i$  lies on  the boundary of the  union of
the Gershgorin circles.  But then it must lie on  the boundary of both
circles with radius $\frac1{1+αh}$ and $1$ around 0. 

  
  Contradiction! $\Rightarrow$ $|\lambda_i|<1$,  $\rho(B)<1$!
"""

# ╔═╡ 2a331200-358e-11eb-29b4-11afe1340f58
α=1

# ╔═╡ 364a408e-358e-11eb-2116-ed3028d7d065
N4=5

# ╔═╡ 2419c88a-358e-11eb-39a2-9fda83c15c81
A4=Tridiagonal(heatmatrix1d(N4,α=α))

# ╔═╡ 42181466-358e-11eb-051a-3f2d8bb812ad
B4=jacobi_iteration_matrix(A4)

# ╔═╡ 87020020-358e-11eb-27b4-8f4895e673a9
ρ4=maximum(abs.(eigvals(Matrix(B4))))

# ╔═╡ c800a018-358e-11eb-2846-01fe6489faed
ρ4_gershgorin=maximum([sum( abs.(B4[i,:])) for i=1:size(B4,1)])

# ╔═╡ 00891e8e-34fd-11eb-1747-f302509e263f
graph4,nlabel4,elabel4=create_graph(B4)

# ╔═╡ 1790aca0-34fd-11eb-0a65-6950bfa9d54e
GraphPlot.gplot(graph4,
	# rand(n),rand(n),
	nodelabel=nlabel4,
	edgelabel=elabel4,
	nodefillc=RGB(1.0,0.6,0.5),
	EDGELABELSIZE=6.0,
	NODESIZE=0.1,
	EDGELINEWIDTH=1
)

# ╔═╡ 260202c0-34fd-11eb-1a71-69854dbe8caf
md"""
- Matrix graph is strongly connected: __$(is_strongly_connected(graph4))__
- Matrix graph is weakly connected: __$(is_weakly_connected(graph4))__
"""

# ╔═╡ 9c0f79ca-358e-11eb-256d-ebcb87991857
pyplot(width=5, height=5) do
	gershgorin_circles(B4)
		xlabel("Re")
	ylabel("Im")

	PyPlot.grid(color=:gray)
end

# ╔═╡ 4996ea08-3592-11eb-2f6b-c91981e73f8b
md"""
- Unfortunately, we don't get a quantitative estimate here.
- Advantage: we don't need to assume symmetry of $A$ or spectral equivalence estimates
"""

# ╔═╡ Cell order:
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╟─f30f2b30-34fd-11eb-3f4e-6349444d781b
# ╟─c73748bc-34f3-11eb-2e80-8d8fcaf6e360
# ╟─d2a6b6c4-34f3-11eb-08aa-79ae41051c52
# ╟─e125ff72-34f6-11eb-2452-c19ad4764372
# ╟─efabb49a-34ee-11eb-0990-e310f2557948
# ╠═0ded215e-34f0-11eb-13a9-49010795133a
# ╠═289402f6-34f1-11eb-3b4a-f5bbeaf61426
# ╠═239724b8-34f1-11eb-251a-17c7e258c9ec
# ╠═37e32e88-34f1-11eb-0f86-859bafcb6003
# ╠═33201ef0-34ed-11eb-3325-99a0c8c9290d
# ╟─c52e79ce-358a-11eb-2d6a-97e2617cb782
# ╠═f7f9144a-34f4-11eb-03f5-b7e5d285520a
# ╠═9bbf3466-34f7-11eb-0dfa-bb462f114d6c
# ╠═ac88d208-34f6-11eb-109b-eb62fe6166d6
# ╠═19008d1a-34f5-11eb-3cd3-73a7fcac9dd4
# ╠═3512363e-34f5-11eb-369c-6f181afdad8e
# ╠═2066fbae-34f6-11eb-38a4-ebf10b38f6a9
# ╟─d7ade3ec-3591-11eb-1667-0be149f44d3c
# ╟─ab813022-34f5-11eb-09aa-89b1396994e4
# ╠═3b93fe56-34f6-11eb-05d2-c16a9fe80018
# ╠═dfeddf74-34f5-11eb-0e6d-29ec13b73d1a
# ╟─30a5cf58-34f9-11eb-267c-034ab805597e
# ╟─523f62ac-34f9-11eb-1001-49e912bb41c0
# ╟─6849ab64-34f9-11eb-3e1d-63c14c1ada95
# ╟─d20cf9ce-34fa-11eb-3751-81edd95c2538
# ╠═c30ad798-34fa-11eb-2247-05c7d352f335
# ╠═e7c40ece-34fa-11eb-00e3-25dd0e9282a4
# ╠═0403538a-34fb-11eb-38f3-29208e82cf8f
# ╠═3c7a296c-34fb-11eb-16fc-834cc4887d99
# ╠═d8a080ce-34fc-11eb-2d52-fd2674725c7e
# ╟─60eebc2e-34fb-11eb-2bb5-c3f952b201d7
# ╟─8ff2e5d4-34fb-11eb-1f07-4d0b975f7053
# ╟─918bc776-3500-11eb-31a7-23e5ce51123b
# ╟─dd9c8236-34fb-11eb-132e-79a9260a25cb
# ╟─f7695ea0-34fb-11eb-3982-577982e0476a
# ╟─35c9dc40-34fc-11eb-2c9b-2917c215d6f9
# ╠═2a331200-358e-11eb-29b4-11afe1340f58
# ╠═364a408e-358e-11eb-2116-ed3028d7d065
# ╠═2419c88a-358e-11eb-39a2-9fda83c15c81
# ╠═42181466-358e-11eb-051a-3f2d8bb812ad
# ╠═87020020-358e-11eb-27b4-8f4895e673a9
# ╠═c800a018-358e-11eb-2846-01fe6489faed
# ╠═00891e8e-34fd-11eb-1747-f302509e263f
# ╠═1790aca0-34fd-11eb-0a65-6950bfa9d54e
# ╟─260202c0-34fd-11eb-1a71-69854dbe8caf
# ╠═9c0f79ca-358e-11eb-256d-ebcb87991857
# ╟─4996ea08-3592-11eb-2f6b-c91981e73f8b

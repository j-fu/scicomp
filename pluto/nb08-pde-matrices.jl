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
	Pkg.add("DataFrames")
	using PlutoUI
	using PyPlot
	using DataFrames
end

# ╔═╡ 7777d59c-2a5f-11eb-1c6c-d511e92fed48
md"""
# Matrices from partial differential equations

As we focus in this course on partial differential equations, we need discuss matrices which evolve from the discretization of PDEs.

- Are there any structural or numerical patterns in these matrices we can take advantage of with regard to memory and time complexity when solving linear systems ?


In this lecture we introduce a relatively simple "drosophila" problem which we will use do discuss these issues.

For the start we use simple structured disceretization grids and a finite difference approach to the discretization. Later, this will be generalized to more general grids
and to finite element and finite volume discretization methods.

"""

# ╔═╡ a9179006-2a5f-11eb-35c8-7d7d4b62edf4
md"""
## Heat conduction in a one-dimensional rod

- Heat source ``f(x)``
- ``v_L, v_R``: ambient temperatures
- ``\alpha``: boundary heat transfer coefficient
- Second order boundary value problem in ``\Omega=[0,1]``:

$$\begin{cases}
      -u''(x)&=f(x)\;\text{in}\; \Omega\\
      -u'(0) + \alpha (u(0) - v_L)&=0\\
      u'(1) + \alpha (u(1) - v_R)&=0
\end{cases}$$

- The solution  ``u`` describes the equilibrium temperature distribution. Behind the second derivative is Fouriers law and the continuity equation

- In math, the boundary conditions are called "Robin" or "third kind". They describe a heat in/outflux proportional to the difference between rod end temperature and ambient temperature

- Fix a number of discretization points N
- Let $h=\frac1{N-1}$
- Let $x_i=(i-1)h\;$ $i=1\dots N$ be discretization points
"""

# ╔═╡ 0348f494-2a6e-11eb-3a39-3f41ae34e50c
N=11

# ╔═╡ 8ec37d5e-2a6f-11eb-2209-afc4b31b596f
md"""
### Finite difference approximation

We can approximate continuous functions $f$ by piecewise linear functions defined
by the values $f_i=f(x_i)$. Using more points yields a better approximation:
"""

# ╔═╡ 13567f00-2a6e-11eb-330d-654d8680aa85
md"""
- Let
    $u_i$ approximations for $u(x_i)$ and $f_i=f(x_i)$
- We can use a finite difference approximation to approximate $u'(x_{i+\frac12})\approx \frac{u_{i+1}-u_{i}}{h}$
- Same approach for second derivative: ``u''(x_i)=\frac{u'(x_{i+\frac12})-u'(x_{i-\frac12})}{h}`` 
- Finite difference approximation of the PDE:
$$\begin{aligned}
      -u'(0) +\alpha (u(0) - v_L) &\approx \frac{1}{2h}(u_{0}-u_2) + \alpha (u_1 - v_L)=0\\
      -u''(x_i)-f(x_i) &\approx \frac{-u_{i+1}+2u_i- u_{i-1}}{h^2}-f_i=0& (i=1\dots N) \;(\ast)\\
      u'(1) + \alpha (u(1) - v_R) &\approx \frac{1}{2h}(u_{N+1}-u_{N-1})+ \alpha (u_N - v_R)=0\\
\end{aligned}$$

"""

# ╔═╡ 021630cc-2aa6-11eb-3b1c-cb9dabe71393
md"""
- Here, we introduced "mirror values" $u_0$ and $u_{N+1}$ in order to approximate the boundary conditions accurately, such that the finite difference formulas used to approximate $u'(0)$ or $u'(1)$ are centered around these values. 

- After rearranging, these values can be expressed via the boundary conditions:
$$\begin{aligned}
u_0&=u_2+2h\alpha(u_1-v_L)\\
u_{N+1}&=u_{N-1}+2h\alpha(u_N-v_L)
\end{aligned}$$

- Finally, they can be replaced in $$(*)$$
"""

# ╔═╡ 55af75de-2a85-11eb-0a77-d3c2246ad6e6
md"""
Then, the system after multiplying by $h$ is reduced to:

$$\begin{aligned}
      \frac{1}{h}((1+h\alpha)u_1 -u_2)=& \frac{h}{2}f_1 + \alpha v_L\\
      \frac{1}{h}(-u_{i+1}+2u_i- u_{i-1})&=hf_i& (i=2\dots N-1)\\
      \frac{1}{h}((1+h\alpha)u_N- u_{N-1})&=\frac{h}{2}f_N + αv_R\\
\end{aligned}$$
"""

# ╔═╡ e2fa2296-2a70-11eb-1756-957d0fe73414
md"""
The resulting discretization matrix is

$$A=\left(
\begin{matrix}
\alpha+\frac1h & -\frac1h &  &  & \\
     -\frac1h  & \frac2h  & -\frac1h & &\\
              & -\frac1h  & \frac2h  & -\frac1h &\\
         &    \ddots & \ddots & \ddots & \ddots\\
         &   & -\frac1h  & \frac2h  & -\frac1h & \\
         &  & & -\frac1h  & \frac2h  & -\frac1h \\
         &  && & -\frac1h  & \frac1h + \alpha  
\end{matrix}
\right)$$

Outside of the three diagonals,  the entries are zero.
"""

# ╔═╡ 5fa7e9d4-2a82-11eb-34a2-01c9b82b8411
md"""
The right hand side is:

$$\left(
\begin{matrix}
 \frac{h}{2}f_1+ \alpha v_L \\ hf_2 \\ hf_3 \\\vdots \\ hf_{N-2} \\ hf_{N-1} \\ \frac{h}{2}f_N+ \alpha v_R
\end{matrix}
\right)$$
"""

# ╔═╡ 7812857e-2aa7-11eb-223d-4199279a754d
md"""
Let us define functions assembling these:
"""

# ╔═╡ 409aa224-2a71-11eb-336b-dde58e49eb6b
function heatmatrix1d(N;α=1)
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

# ╔═╡ c2da97fe-2a82-11eb-3766-c392f4039517
function heatrhs1d(N;vl=0,vr=0,func=x->0,α=1)
	h=1/(N-1)
	F=zeros(N)
	F[1]=h/2*func(0)+α*vl
	for i=2:N-1
		F[i]=h*func((i-1)*h)
	end
	F[N]=h/2*func(1)+α*vr
	F
end

# ╔═╡ d294adee-2a87-11eb-207a-3d6cd354c303
α=100

# ╔═╡ 129afeec-2a87-11eb-3544-c962264fec7a
N1=10000

# ╔═╡ b71002f8-2a71-11eb-38f6-c7368a26824d
A=heatmatrix1d(N1,α=α)

# ╔═╡ 50626a82-2a82-11eb-11a1-91721276b989
b=heatrhs1d(N1,func=x->1,α=α)

# ╔═╡ 9af56ec4-2aa7-11eb-3f79-794f26c5695e
u=A\b

# ╔═╡ 2eb25530-2a87-11eb-1eb5-09296e960b61
begin
	clf()
	plot(collect(0:1/(N1-1):1),u)
	grid()
	gcf()
end

# ╔═╡ d0947fda-2a88-11eb-0979-99b94a0a7feb
md"""
For this example, we created an $N\times N$ matrix where all entries outside of the main diagonal and the two adjacent ones are zero:
- Fraction of nonzero entries: $(sum(A.!=0.0)/length(A))
- Ratio  of nonzero entries to number of unknowns: $(sum(A.!=0.0)/size(A,1))
- In fact, this matrix has $O(N)$ nonzero entries.
"""

# ╔═╡ fbaf1cda-2a8c-11eb-334f-618fb981b0b0
md"""
## 2D heat conduction
"""

# ╔═╡ 02ea5840-2a8d-11eb-127f-ab6bb7ea9d27
md"""
Just pose the heat problem in a 2D domain $\Omega=(0,1)\times (0,1)$:

$$\begin{cases}
      -\frac{\partial^2u}{\partial x^2}-\frac{\partial^2u}{\partial y^2}&=f(x,y)\;\text{in}\; \Omega\\
\frac{\partial u}{\partial n}+ \alpha (u -v) &=0 \;\text{on}\;\partial\Omega
\end{cases}$$

We use 2D regular discretization $n\times n$ grid with grid points $x_{ij}=((i-1)h, (j-1)h)$. The finite difference approximation yields:

$$\frac{ -u_{i-1,j} - u_{i,j-1} + 4u_{ij} - u_{i+1,j} - u_{i,j+1}}{h^2}= f_{ij}$$
This just comes from summing up the 1D finite difference formula for the $x$ and $y$ directions.

We do not discuss the boundary conditions here.

The $n\times n$ grid leads to an $n^2\times n^2$ matrix!
"""

# ╔═╡ fc6c37fe-2aa8-11eb-2b94-abc9c2d6d14d
md"""
Matrix and right hand side assembly inspired by the finite volume method which will be covered later in the course. The result is the same as for the finite difference method with the mirror trick for the boundary condition.
"""

# ╔═╡ 582c619a-2a8b-11eb-3ea2-97eeeb1377fa
function heatmatrix2d(n;α=1)
    function update_pair(A,v,i,j)
		A[i,j]+=-v
		A[j,i]+=-v
		A[i,i]+=v
		A[j,j]+=v
    end
	N=n^2
	h=1.0/(n-1)
	A=zeros(N,N)
    l=1
        for j=1:n
            for i=1:n
                if i<n
                    update_pair(A,1.0,l,l+1)
                end
                if i==1|| i==n
                    A[l,l]+=α
                end
                if j<n
                    update_pair(A,1,l,l+n)
                end
                if j==1|| j==n
                    A[l,l]+=α
                end
                l=l+1
            end
        end
    A
end


# ╔═╡ d9ebab82-2a8e-11eb-133a-65451fb696b1
function heatrhs2d(n; rhs=(x,y)->0,bc=(x,y)->0,α=1.0) 
	h=1.0/(n-1)
	x=collect(0:h:1)
	y=collect(0:h:1)
	N=n^2
	f=zeros(N)
	for i=1:n-1
		for j=1:n-1
			ij=(j-1)*n+i
			f[ij]+=h^2/4*rhs(x[i],y[j])
			f[ij+1]+=h^2/4*rhs(x[i+1],y[j])
			f[ij+n]+=h^2/4*rhs(x[i],y[j+1])
			f[ij+n+1]+=h^2/4*rhs(x[i+1],y[j+1])
		end
	end
	
	for i=1:n
		ij=i
		fac=h
		if i==1 || i==n 
			fac=h/2
		end
		f[ij]+=fac*α*bc(x[i],0)
		ij=i+(n-1)*n
		f[ij]+=fac*α*bc(x[i],1)
	end
	for j=1:n
		fac=h
		if j==1 || j==n 
			fac=h/2
		end
		ij=1+(j-1)*n
		f[ij]+=fac*α*bc(0,y[j])
		ij=n+(j-1)*n
		f[ij]+=fac*α*bc(1,y[j])
	end
	f
end

# ╔═╡ fdf796ae-2a8f-11eb-2e78-3b99bcebd09b
n=5

# ╔═╡ dd1c740e-2a8f-11eb-3f71-7b2222a26b8f
b2=heatrhs2d(n,rhs=(x,y)->sin(3*π*x)*sin(3*π*y),α=α)

# ╔═╡ 0fcb5374-2a8c-11eb-0655-b3b85c775b44
A2=heatmatrix2d(n,α=α)

# ╔═╡ cc946efa-2a8c-11eb-3c82-e51c53b8f171
md"""
In order to inspect the matrix, we can turn it into a DataFrame,
which can be browsed.
"""

# ╔═╡ e2fca0e0-2a8c-11eb-1937-71af17abc1a8
DataFrame(A2)

# ╔═╡ ae5b9844-2aa7-11eb-2d4f-8f6aa8cc28c6
u2=A2\b2

# ╔═╡ d6243e3a-2a8e-11eb-082b-49e4d034c8d8
begin
	clf()
	h=1.0/(n-1)
	x=collect(0:h:1)
	y=collect(0:h:1)
	
	contourf(x,y,reshape(u2,n,n),cmap="hot")
	fig=gcf()
	fig.set_size_inches(5,5)
	fig
end

# ╔═╡ ae2c717a-2a63-11eb-34ac-65d6195fd4c4
function plotgrid(N;func=nothing,mirror=false)
	clf()
    ax=PyPlot.axes(aspect=0.5)
 	plot([0,1],[0,0],linewidth=3,color="k")
	h=1/(N-1)
	x=collect(0:h:1)
	plot([0,0],[-0.05,0.05],color=:black)
	plot([1,1],[-0.05,0.05],color=:black)
 	for i=1:N
		plot([x[i],x[i]],[-0.025,0.025],linewidth=1,color=:black)
        ax.text(x[i],-0.1,"\$x_{$(i)}\$",fontsize=10,color=:blue)
	end
	if mirror
		plot([-h,-h],[-0.025,0.025],color=:gray)
   	    plot([-h,0],[0,0],linewidth=3,color=:gray)
        ax.text(-h,-0.1,"\$x_{0}\$",fontsize=10,color=:gray)
		plot([1+h,1+h],[-0.025,0.025],color=:gray)
   	    plot([1,1+h],[0,0],linewidth=3,color=:gray)
        ax.text(1+h,-0.1,"\$x_{$(N+1)}\$",fontsize=10,color=:gray)
	end
	if func!=nothing
		plot(x,func.(x),linewidth=1,color="r")
    end
    PyPlot.axis("off")
    ax.get_xaxis().set_visible(false)
    ax.axes.get_yaxis().set_visible(false)
	fig=PyPlot.gcf()
	fig.set_size_inches(10,2)
	fig
end

# ╔═╡ 5a85ac74-2a6f-11eb-3380-612a44cec722
plotgrid(N)

# ╔═╡ 94277d3c-2a6e-11eb-25bc-a50dc192865b
plotgrid(N,func=x->0.5*sin(8*x)^2)

# ╔═╡ 0ce2666a-2aa6-11eb-0e51-a54abf22f9fc
plotgrid(N,mirror=true)

# ╔═╡ 353f1562-2a89-11eb-015a-736acb3b7f26
function plotgrid2d(N;text=true, func=nothing)
	clf()
    ax=PyPlot.axes(aspect=1)
 	x=[(i-1)/(N-1) for i=1:N]
	y=[(i-1)/(N-1) for i=1:N]
	
 	for i=1:N
		plot([x[i],x[i]],[0,1],linewidth=1,color="k")
 		plot([0,1],[y[i],y[i]],linewidth=1,color="k")
 	end
	if func!=nothing
		f=[func(x[i],y[j]) for i=1:N, j=1:N]
		contourf(x,y,f,cmap="hot")
	end
	if text
	  ij=1
	  for j=1:N
		for i=1:N
		  ax.text(x[i],y[j]-0.035,"\$x_{$(ij)}\$",fontsize=10,color=:blue)
			ij=ij+1
	 	end
 	  end
	end
	fig=PyPlot.gcf()
	fig.set_size_inches(5,5)
	fig
end

# ╔═╡ 83af18f0-2a89-11eb-3b6c-e1f87e4ba3da
plotgrid2d(5)

# ╔═╡ dcb0a9e6-2a90-11eb-0ec6-27ea830788eb
md"""
In order to achieve this, we stored a matrix which has only five nonzero diagonals
as a full $N \times N$ matrix, where $N=n^2$:

- Fraction of nonzero entries: $(sum(A2.!=0.0)/length(A2))
- Ratio  of nonzero entries to number of unknowns: $(sum(A2.!=0.0)/size(A2,1))
- In fact, this matrix has $O(N)$ nonzero entries.

__... there must be a better way!__
"""

# ╔═╡ Cell order:
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╟─7777d59c-2a5f-11eb-1c6c-d511e92fed48
# ╟─a9179006-2a5f-11eb-35c8-7d7d4b62edf4
# ╠═0348f494-2a6e-11eb-3a39-3f41ae34e50c
# ╟─ae2c717a-2a63-11eb-34ac-65d6195fd4c4
# ╠═5a85ac74-2a6f-11eb-3380-612a44cec722
# ╟─8ec37d5e-2a6f-11eb-2209-afc4b31b596f
# ╠═94277d3c-2a6e-11eb-25bc-a50dc192865b
# ╟─13567f00-2a6e-11eb-330d-654d8680aa85
# ╠═0ce2666a-2aa6-11eb-0e51-a54abf22f9fc
# ╟─021630cc-2aa6-11eb-3b1c-cb9dabe71393
# ╟─55af75de-2a85-11eb-0a77-d3c2246ad6e6
# ╟─e2fa2296-2a70-11eb-1756-957d0fe73414
# ╟─5fa7e9d4-2a82-11eb-34a2-01c9b82b8411
# ╟─7812857e-2aa7-11eb-223d-4199279a754d
# ╠═409aa224-2a71-11eb-336b-dde58e49eb6b
# ╠═c2da97fe-2a82-11eb-3766-c392f4039517
# ╠═d294adee-2a87-11eb-207a-3d6cd354c303
# ╠═129afeec-2a87-11eb-3544-c962264fec7a
# ╠═b71002f8-2a71-11eb-38f6-c7368a26824d
# ╠═50626a82-2a82-11eb-11a1-91721276b989
# ╠═9af56ec4-2aa7-11eb-3f79-794f26c5695e
# ╠═2eb25530-2a87-11eb-1eb5-09296e960b61
# ╟─d0947fda-2a88-11eb-0979-99b94a0a7feb
# ╟─fbaf1cda-2a8c-11eb-334f-618fb981b0b0
# ╟─02ea5840-2a8d-11eb-127f-ab6bb7ea9d27
# ╠═353f1562-2a89-11eb-015a-736acb3b7f26
# ╠═83af18f0-2a89-11eb-3b6c-e1f87e4ba3da
# ╟─fc6c37fe-2aa8-11eb-2b94-abc9c2d6d14d
# ╠═582c619a-2a8b-11eb-3ea2-97eeeb1377fa
# ╠═d9ebab82-2a8e-11eb-133a-65451fb696b1
# ╠═fdf796ae-2a8f-11eb-2e78-3b99bcebd09b
# ╠═dd1c740e-2a8f-11eb-3f71-7b2222a26b8f
# ╠═0fcb5374-2a8c-11eb-0655-b3b85c775b44
# ╟─cc946efa-2a8c-11eb-3c82-e51c53b8f171
# ╠═e2fca0e0-2a8c-11eb-1937-71af17abc1a8
# ╠═ae5b9844-2aa7-11eb-2d4f-8f6aa8cc28c6
# ╠═d6243e3a-2a8e-11eb-082b-49e4d034c8d8
# ╟─dcb0a9e6-2a90-11eb-0ec6-27ea830788eb

### A Pluto.jl notebook ###
# v0.12.9

using Markdown
using InteractiveUtils

# ╔═╡ baf88246-01d1-11eb-3d35-1393445b1476
using Pkg; Pkg.activate(mktempdir()); Pkg.add("PlutoUI"); using PlutoUI

# ╔═╡ 204dfcb6-029a-11eb-19b8-bd6beebf9291
Pkg.add("PyCall"); using PyCall

# ╔═╡ d76c2038-0292-11eb-1fe0-e50fc2a4fc0f
md"""
# Code structuring and interaction with other languages

### Julia workflows
When working with Julia, we can choose between a number of workflows.

##### Pluto notebook
This ist what you see in action here. After calling pluto, you can start with an empty
notebook and add cells.

##### Jupyter notebook
With the help of the package `IJulia.jl` it is possible to work with Jupyter notebooks in the browser. The Jupyter system is very complex and Pluto hopefully will be able to replace it. 

##### Classical workflow
Use a classical code editor (emacs, vi or whatever you prefer) in a separate window and edit files, when saved to disk run code in a console window.
With Julia, this workflow has the disadvantage that everytime Julia is started, the JIT needs to recompile the packages involved. So the idea is to not leave Julia, but to start a permanent Julia session, and include the code after each change.

The __`Revise.jl`__ package allows to keep track of changed files used in a Julia session if they have been included via `includet` (`t` for "tracked"). In orde to make this work, one should add 
````
if isinteractive()
    try
        @eval using Revise
        Revise.async_steal_repl_backend()
    catch err
        @warn "Could not load Revise."
    end
end
````
to the startup file  `~/.julia/config/startup.jl` and to run Julia via `julia -i`.

`Revise.jl` also keeps track of packages loaded. It also can be used with Pluto.

##### Modern workflow
Use an IDE (integrated development environment). Currently the best one for Julia is Visual Studio Code with corresponding extensions.
"""

# ╔═╡ 10121276-0293-11eb-082c-cda9b008c183
md"""
# Structuring code: modules, files and packages

 - Complex code is split up into several files which can be included 
 - Need to avoid name clashes for code from different places
### Modules
 Modules allow to encapsulate implementation into different namespaces
"""

# ╔═╡ 8730ec36-0295-11eb-2174-0b010e72b224
module TestModule
  function mtest(x)
      return "mtest: x=$(x)"
  end
  export mtest
end

# ╔═╡ 7e607edc-245a-11eb-108a-2bd010c087c6
TestModule.mtest(3)

# ╔═╡ 06a3282e-0298-11eb-39cc-a1e604624b9e
md"""
### Packages
 - Packages are modules searched for in a number of standard places
 - Each package is a directory named `Package` with a subdirectory `src`
 - The file `Package/src/Package.jl` defines a module named `Package`
 - More structures in a package:
    - Documentation build recipes
    - Test code
    - Metadada: Dependency description, UUID (Universal unique identifier)...
 - Default packages (e.g. the package manager Pkg) are always found in the `.julia` subdirectory of your home directory
 - The package manager allows to add packages by finding them via the registry and downloading them.
"""

# ╔═╡ a0e563b4-245a-11eb-22a0-3b7cc6e509d0
readdir("/home/fuhrmann/.julia/packages/")

# ╔═╡ eeeee3fa-245a-11eb-1343-09b5fe9ba7dd
readdir("/home/fuhrmann/.julia/packages/AbstractTrees/")

# ╔═╡ 227fba08-0298-11eb-22e7-2b9ebc0f57c8
md"""
## Calling code from other languages
### C

 - C language code has a well defined binary interface
   - `int` $\leftrightarrow\quad$    `Int32`
   - `float` $\leftrightarrow\quad$   `Float32`
   - `double` $\leftrightarrow\quad$    `Float64`
   - C arrays  as pointers


- Create a C source file:
"""

# ╔═╡ 61177d0a-0298-11eb-0877-e1b1ac0ed644
cadd_source="""
double cadd(double x, double y) 
{ 
   return x+y; 
}
"""

# ╔═╡ 7f745912-0298-11eb-1cd0-9d6ad07ebd2d
open("cadd.c", "w") do io
    write(io,cadd_source)
end;

# ╔═╡ 7467dd68-0299-11eb-1c75-332ea70f8386
md"""
Compile to a shared object (aka "dll" on windows) using the gcc compiler:
"""

# ╔═╡ 8efd157c-0298-11eb-340c-27c71e90bb80
run(`gcc --shared  cadd.c -o libcadd.so`)

# ╔═╡ ec15c2ba-0298-11eb-1e2c-05cd2baeedf8
md"""
 - Define wrapper function `cadd` using the Julia `ccall` method
   - `(:cadd, "libcadd")`: call cadd from `libcadd.so`
   - First `Float64`: return type
   - Tuple `(Float64,Float64,)`: parameter types
   - `x,y`: actual data passed
 - At its first call it will load `libcadd.so` into Julia
 - Direct call of compiled  C function `cadd()`, no intermediate wrapper code

"""

# ╔═╡ a3edac0a-0299-11eb-1492-2d42211731e7
cadd(x,y)=ccall((:cadd, "libcadd"), Float64, (Float64,Float64,),x,y)

# ╔═╡ a29023ee-0299-11eb-36ce-5fd80778566a
cadd(1.5,2.4)

# ╔═╡ fafc91f2-0299-11eb-3547-9bed631a26ad
md"""
- Julia and many of its packages use this method to access a number of highly optimized linear algebra and other libraries

"""

# ╔═╡ e961fef8-0299-11eb-21a9-83346148ad85
md"""
### Python

 - Both Julia and Python are homoiconic language, featuring _reflection_
 - They can parse the elements of their own data structures $\Rightarrow$ possibility to automatically build proxies for python objects in Julia 

The PyCall package provides the corresponding interface:
"""

# ╔═╡ 7e3ccea0-245b-11eb-0a16-7181dc6865cf
md"""
Create a python source file:
"""

# ╔═╡ 36e3ccee-029a-11eb-205d-398851e27483
pyadd_source="""
def add(x,y):
    return x+y
"""

# ╔═╡ 4d3cefa0-029a-11eb-3fdf-b98daa8a7e3d
open("pyadd.py", "w") do io
    write(io,pyadd_source)
end;

# ╔═╡ 6013f5d2-029a-11eb-3460-21e727082c09
pyadd=pyimport("pyadd")

# ╔═╡ 69572680-029a-11eb-31bf-cb2ffab1254d
pyadd.add(3.5,6.6)

# ╔═╡ 7b63d468-029a-11eb-1b57-75899ee7e700
md"""
 - Julia allows to call almost any python package
 - E.g. matplotlib  graphics - this is the python package behind PyPlot (there are more graphics options in Julia)
 - There is also a [pyjulia](https://github.com/JuliaPy/pyjulia) package
   allowing to call Julia from python

"""

# ╔═╡ 8db4d482-029a-11eb-2ec3-49e42af2d678
md"""
### Other languages
- There are ways to interact with C++, R and other langugas
- Interaction with Fortran via `ccall`
"""

# ╔═╡ Cell order:
# ╠═baf88246-01d1-11eb-3d35-1393445b1476
# ╟─d76c2038-0292-11eb-1fe0-e50fc2a4fc0f
# ╟─10121276-0293-11eb-082c-cda9b008c183
# ╠═8730ec36-0295-11eb-2174-0b010e72b224
# ╠═7e607edc-245a-11eb-108a-2bd010c087c6
# ╟─06a3282e-0298-11eb-39cc-a1e604624b9e
# ╠═a0e563b4-245a-11eb-22a0-3b7cc6e509d0
# ╠═eeeee3fa-245a-11eb-1343-09b5fe9ba7dd
# ╟─227fba08-0298-11eb-22e7-2b9ebc0f57c8
# ╠═61177d0a-0298-11eb-0877-e1b1ac0ed644
# ╠═7f745912-0298-11eb-1cd0-9d6ad07ebd2d
# ╟─7467dd68-0299-11eb-1c75-332ea70f8386
# ╠═8efd157c-0298-11eb-340c-27c71e90bb80
# ╟─ec15c2ba-0298-11eb-1e2c-05cd2baeedf8
# ╠═a3edac0a-0299-11eb-1492-2d42211731e7
# ╠═a29023ee-0299-11eb-36ce-5fd80778566a
# ╟─fafc91f2-0299-11eb-3547-9bed631a26ad
# ╟─e961fef8-0299-11eb-21a9-83346148ad85
# ╠═204dfcb6-029a-11eb-19b8-bd6beebf9291
# ╟─7e3ccea0-245b-11eb-0a16-7181dc6865cf
# ╠═36e3ccee-029a-11eb-205d-398851e27483
# ╠═4d3cefa0-029a-11eb-3fdf-b98daa8a7e3d
# ╠═6013f5d2-029a-11eb-3460-21e727082c09
# ╠═69572680-029a-11eb-31bf-cb2ffab1254d
# ╟─7b63d468-029a-11eb-1b57-75899ee7e700
# ╟─8db4d482-029a-11eb-2ec3-49e42af2d678

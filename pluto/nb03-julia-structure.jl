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

# ╔═╡ d312a490-0296-11eb-32c3-2f0866c93a1a
push!(LOAD_PATH, pwd())

# ╔═╡ baf88246-01d1-11eb-3d35-1393445b1476
using Pkg; Pkg.activate(mktempdir()); Pkg.add("PlutoUI"); using PlutoUI

# ╔═╡ 204dfcb6-029a-11eb-19b8-bd6beebf9291
Pkg.add("PyCall"); using PyCall

# ╔═╡ 6b8c3cfe-0297-11eb-15a6-b91ce15dbece
begin
	include("TestModule1.jl")
    TestModule1.mtest(23)
end

# ╔═╡ 0434bba0-01d2-11eb-124f-ef216f314163
md"""Hide package status: $(@bind hide_pkg_status CheckBox(false))"""

# ╔═╡ fccd863a-01d1-11eb-126c-f5a20a339413
if !hide_pkg_status 
	with_terminal(Pkg.status)
end



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

##### Modern workflow
Use an IDE (integrated development environment). Currently the best one for Julia is Visual Studio Code with corresponding extensions.
"""

# ╔═╡ 10121276-0293-11eb-082c-cda9b008c183
md"""
# Structuring your code: modules, files and packages

 - Complex code is split up into several files which can be included
 - Need to avoid name clashes for code from different places
 - Organize the way to use third party code
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

# ╔═╡ cd77f9a0-0295-11eb-1494-6390a7c630d4
TestModule.mtest(3)

# ╔═╡ 3d522e80-0296-11eb-33d7-63e1445b8d8b
md"""
`using TestModule` would allow to use exported functions without the need to qualify their name by prepending `TestModule`.
"""

# ╔═╡ c646ab26-0296-11eb-3699-f533655566bf
md"""
### ??? Finding modules
 - Put single file modules having the same name as the module
   into a directory which in on the `LOAD_PATH`
 - Call "using" or "import" with the module
 - You can modify your `LOAD_PATH` by adding e.g. the actual directory

Does not work from Pluto notebooks.
"""

# ╔═╡ e8672140-0296-11eb-08ab-e9b2833c82b7
testmodule1_source="""
module TestModule1
   mtest(x)="testmodule1: x=\$(x)"
   export mtest
end
"""

# ╔═╡ 3e01bb60-0297-11eb-2c16-c9b4d5a8fd5b
open("TestModule1.jl", "w") do io
    write(io,testmodule1_source)
end;

# ╔═╡ 06a3282e-0298-11eb-39cc-a1e604624b9e
md"""
### ??? Packages
 - Packages are found via the same mechanism
 - Part of the load path are the  directory with downloaded packages
   and the directory with packages under development
 - Each package is a directory named `Package` with a subdirectory `src`
 - The file `Package/src/Package.jl` defines a module named `Package`
 - More structures in a package:
    - Documentation build recipes
    - Test code
    - Dependency description
    - UUID (Universal unique identifier)
 - Default packages (e.g. the package manager Pkg) are always available
 - Use the package manager to checkout a new package via the registry
"""

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
end

# ╔═╡ 7467dd68-0299-11eb-1c75-332ea70f8386
md"""
Compile using the gcc compiler:
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
- Julia uses this method to access a number of highly optimized linear algebra and other libraries

"""

# ╔═╡ e961fef8-0299-11eb-21a9-83346148ad85
md"""
### Python

 - Both Julia and Python are homoiconic language, featuring _reflection_
 - They can parse the elements of their own data structures $\Rightarrow$ possibility to automatically build proxies for python objects in Julia 

The PyCall package provides the corresponding interface:
"""

# ╔═╡ 36e3ccee-029a-11eb-205d-398851e27483
pyadd_source="""
def pyadd(x,y):
    return x+y
"""

# ╔═╡ 4d3cefa0-029a-11eb-3fdf-b98daa8a7e3d
open("pyadd.py", "w") do io
    write(io,pyadd_source)
end

# ╔═╡ 6013f5d2-029a-11eb-3460-21e727082c09
pyadd=pyimport("pyadd")

# ╔═╡ 69572680-029a-11eb-31bf-cb2ffab1254d
pyadd.pyadd(3.5,6.5)

# ╔═╡ 7b63d468-029a-11eb-1b57-75899ee7e700
md"""
 - Julia allows to call almost any python package
 - E.g. matplotlib  graphics
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
# ╟─baf88246-01d1-11eb-3d35-1393445b1476
# ╟─0434bba0-01d2-11eb-124f-ef216f314163
# ╟─fccd863a-01d1-11eb-126c-f5a20a339413
# ╠═d76c2038-0292-11eb-1fe0-e50fc2a4fc0f
# ╠═10121276-0293-11eb-082c-cda9b008c183
# ╠═8730ec36-0295-11eb-2174-0b010e72b224
# ╠═cd77f9a0-0295-11eb-1494-6390a7c630d4
# ╠═3d522e80-0296-11eb-33d7-63e1445b8d8b
# ╠═c646ab26-0296-11eb-3699-f533655566bf
# ╠═d312a490-0296-11eb-32c3-2f0866c93a1a
# ╠═e8672140-0296-11eb-08ab-e9b2833c82b7
# ╠═3e01bb60-0297-11eb-2c16-c9b4d5a8fd5b
# ╠═6b8c3cfe-0297-11eb-15a6-b91ce15dbece
# ╠═06a3282e-0298-11eb-39cc-a1e604624b9e
# ╠═227fba08-0298-11eb-22e7-2b9ebc0f57c8
# ╠═61177d0a-0298-11eb-0877-e1b1ac0ed644
# ╠═7f745912-0298-11eb-1cd0-9d6ad07ebd2d
# ╠═7467dd68-0299-11eb-1c75-332ea70f8386
# ╠═8efd157c-0298-11eb-340c-27c71e90bb80
# ╠═ec15c2ba-0298-11eb-1e2c-05cd2baeedf8
# ╠═a3edac0a-0299-11eb-1492-2d42211731e7
# ╠═a29023ee-0299-11eb-36ce-5fd80778566a
# ╠═fafc91f2-0299-11eb-3547-9bed631a26ad
# ╠═e961fef8-0299-11eb-21a9-83346148ad85
# ╠═204dfcb6-029a-11eb-19b8-bd6beebf9291
# ╠═36e3ccee-029a-11eb-205d-398851e27483
# ╠═4d3cefa0-029a-11eb-3fdf-b98daa8a7e3d
# ╠═6013f5d2-029a-11eb-3460-21e727082c09
# ╠═69572680-029a-11eb-31bf-cb2ffab1254d
# ╠═7b63d468-029a-11eb-1b57-75899ee7e700
# ╠═8db4d482-029a-11eb-2ec3-49e42af2d678

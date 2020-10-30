### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 484d33d8-0a42-11eb-30b2-717160db3d47
using PlutoUI

# ╔═╡ 639862fe-fca5-11ea-2ada-4fa5fe9fcd09
using LinearAlgebra

# ╔═╡ 0f9d8036-fc5e-11ea-153f-23658d19c45f
md"""
# Julia - first contact

### Resources
 - [Homepage](https://julialang.org)
 - [Documentation](https://docs.julialang.org/en/v1/)
 - [Cheat Sheet](https://juliadocs.github.io/Julia-Cheat-Sheet/)
 - [WikiBook](https://en.wikibooks.org/wiki/Introducing_Julia)
 - [7 Julia Gotchas and How to Handle Them](https://www.stochasticlifestyle.com/7-julia-gotchas-handle/)
### Hint for starting
 Use the [Cheat Sheet](https://juliadocs.github.io/Julia-Cheat-Sheet/) to see
 a compact and rather comprehensive list of basic things Julia. This notebook
 tries to discuss some concepts behind Julia.
"""

# ╔═╡ 94a382fa-fc5e-11ea-03e1-55306eb5e74c
md"""
 ## [Open Source](https://opensource.org/)
 - Julia is an Open Source project started at MIT
 - Julia itself is distributed under an [MIT license](https://github.com/JuliaLang/julia/blob/master/LICENSE.md)
      - packages often  have   different licenses
 - Development takes place on [github](https://github.com/JuliaLang/julia)
 - As of October 2020, mor than 1000 contributors to the code
 - The Open Source paradigm corresponds well to the fundamental requirement that scientific research should be [transparent and reproducible](https://doi.org/10.5281/zenodo.1172988)

"""

# ╔═╡ c1670268-fc5e-11ea-3dd4-178a332e7839
md"""
## How to install and  run Julia
- Installation:
  - [Download](https://julialang.org/downloads/) from julialang.org (recommended by Julia creators)
  - Installation via system package manager  (yast, apt-get, homebrew)
- Running:
  - Access in command line mode - edit source code in any editor
  - Access via JUNO plugin of Visual Studio code editor
  - Pluto notebooks in the browser
  - Jupyter notebooks in the browser
"""

# ╔═╡ 79146452-fc5f-11ea-0761-51d3d1195257
md"""
 ## REPL: Read-Evaluation-Print-Loop

 Start REPL by calling `julia` in terminal

 ### REPL modes:
 - **Default mode:** `julia>` prompt.  Type backspace in other modes to enter default mode.
 - **Help mode:**  `help?>` prompt.    Type `?` to enter help mode. Search via `?search_term`
 - **Shell mode:** `shell>` prompt.    Type `;` to enter shell mode.
 - **Package mode:** `Pkg>` prompt.    Type `]` to enter package mode.

 ### Helpful commands in REPL 
 - `quit()` or `Ctrl+D`: exit Julia.
 - `Ctrl+C`: interrupt execution.
 - `Ctrl+L`: clear screen.
 - Append `;` to suppress displaying output from a command
 - `include("filename.jl")`: source a Julia code file.

"""

# ╔═╡ c6b02eb2-fc5f-11ea-23fc-09fdeaf53a70
md"""
 ## Package management
 - Julia has an evolving package ecosystem developed by a growing community
 - Packages provide functionality  which is not part of the core Julia installation
 - Each package is a git repository
    - Mostly on github as `Package.jl`, e.g. [AbstractTrees](https://github.com/Keno/AbstractTrees.jl)
    - Packages can be added to and removed from Julia installation
    - Any packages can be installed via a git URL
  - Packages can be registered in package registries which are themselves git repositories containing metadata of registered packages.
    - By default, the  [General Registry](https://github.com/JuliaRegistries/General) is used
    - Registered packages are added by name
"""

# ╔═╡ f50aa9ae-fc5f-11ea-2889-2d4f586ea58a
md"""
##### Importing the package manager

In order to install(add) or remove a package, Julia has a package manager which itself is a package installed by default. We nee to import it in order to use it. The import statement makes all functions from the package available via qualified names, i.e. the function names need to be prefixed with the package name like `Pkg.activate`.
"""

# ╔═╡ 4410991a-0a42-11eb-0e62-4748173329c5
import Pkg

# ╔═╡ 5bd1cf88-0a42-11eb-3df3-23a1ec89fc29
md"""
##### Environments
list of packages currently used is stored in a *package environment*. A particular directory can be activated by the package manager as the current package environment. The file `Project.toml` in that directory contains the list of packages installed, and the file `Manifest.toml` contains the particular versions ot the installed packages and those installed additionally as dependencies.

Here, we activate a temporary directory as package environment:
"""

# ╔═╡ 3bc30a3a-0a43-11eb-3295-25270a3c164c
Pkg.activate(mktempdir())

# ╔═╡ 4b28f462-0a43-11eb-2e60-0de35bde96b7
md"""
- If we skip this step, a global environment stored in `.julia/environments/vX.Y` under the user home directory will be used. All packages from that global environment will be visible in the activated local evironments.
- Environments allow to separate lists of packages used in different projects
- The pluto notebooks provided during the course always will use this type of temporary environment as created above.
"""

# ╔═╡ bed2320c-0a43-11eb-0702-77308108418a
md"""
##### Adding and using packages

Now, we can add packages, possibly downloading them if necessary:
"""

# ╔═╡ 0707ae90-fc60-11ea-2702-afc82e07459a
 Pkg.add("PlutoUI")

# ╔═╡ cb872c00-0a43-11eb-2144-0b37e7d99fb2
md"""
The `using` statements makes all exported functions from the package available with out need to prefix their names with the name of the package:
"""

# ╔═╡ 1f99a6de-fc60-11ea-0226-c35cf524d558
md"""
 Add another package: `AbstractTrees`
"""

# ╔═╡ 2d82b7fe-fc60-11ea-3acf-31c5a9fe5cd0
with_terminal() do
	Pkg.add("AbstractTrees")
end

# ╔═╡ 43d5205a-fc60-11ea-306e-a707ff4b94d1
md"""
List installed packages:
"""

# ╔═╡ a12b50da-fc60-11ea-3340-8d85841fa088
with_terminal() do
	Pkg.status()
end

# ╔═╡ b3a3a872-fc60-11ea-068c-d1395a440387
md"""
Remove package:
"""

# ╔═╡ bc9a48f8-fc60-11ea-104d-5599c7bbad6c
with_terminal() do
	Pkg.rm("AbstractTrees")
end

# ╔═╡ 6d96d7ce-0a45-11eb-1ce6-21d0a0a9fad2
md"""
##### Updating packages

Packages can be updated to their newest version:
"""

# ╔═╡ 898bdcd6-0a45-11eb-0d54-214aa82543f8
with_terminal() do
	Pkg.update()
end

# ╔═╡ ae060544-0a45-11eb-0e01-d791db6ef0f5
md"""
##### Pinning (fixing) package versions

Sometimes, it is a good idea to fix the version of a package installed. This can be achieved by specifying its version during `Pkg.add()`
"""

# ╔═╡ c3790734-0a45-11eb-2cc4-b3b6eb53ff0f
Pkg.add(name="AbstractTrees",version="0.3.2")

# ╔═╡ 3b0b284c-fc61-11ea-115d-5dd90f144926
md"""
 ##### Local copies of packages
 - Upon installation, local copies of the package source code is downloaded  from  git repository
 - By default located in `.julia/packages` subdirectory of your home folder
"""

# ╔═╡ 926aed66-fc61-11ea-23a8-91a37455bc77
md"""
## Standard number types
- Julia is a strongly typed language, so any variable has a type.
- Standard number types allow fast execution because they are supported in the instruction set of the processors
- Default types are autodected from expression 
- The `typeof` function allows to detect the type of a variable
"""

# ╔═╡ b8cd918e-fc61-11ea-25d0-6dd5ca9e4e32
md"""
__Integers__
"""

# ╔═╡ c4f4da76-fc61-11ea-2539-210bf0fb65d0
i=1

# ╔═╡ c86b061c-fc61-11ea-01e2-170bcf486410
typeof(i)

# ╔═╡ da3d7de8-fc61-11ea-093d-0d91a09bae65
md"""
__Floating point__
"""

# ╔═╡ e838e7b6-fc61-11ea-183b-e73a022fe43b
x=10.0

# ╔═╡ ed6ed4f2-fc61-11ea-0750-b9247ad258ca
typeof(x)

# ╔═╡ 05371d6a-fc62-11ea-20ea-376ecd786950
md"""
__Rational__
"""

# ╔═╡ 15c3ef00-fc62-11ea-1f1f-b3a5258df8fa
r=3//7

# ╔═╡ 1bb8c336-fc62-11ea-3f4b-45d3b1ec2b0a
typeof(r)

# ╔═╡ 4481ddd4-fc62-11ea-3fa9-594b973362b0
md"""
__Irrational__
"""

# ╔═╡ 287536f4-fc62-11ea-3e93-7158d175a9ae
p=π

# ╔═╡ 2de65460-fc62-11ea-0da1-77d0a5e3e4ce
typeof(p)

# ╔═╡ 67b01d02-fc62-11ea-3509-db6f73066d57
md"""
__Complex__
"""

# ╔═╡ 6ec302da-fc62-11ea-074a-a70d5942ce1e
z=17.5+3im

# ╔═╡ 96246026-fc62-11ea-0485-cfee9eae67ee
typeof(z)

# ╔═╡ d97630b6-fc62-11ea-2639-d568abe02da8
md"""
## Vectors
- Elements of a given type stored contiguously in memory
- Vectors and 1-dimensional arrays are the same
- Vectors can be created for any element type
- Element type can be determined by `eltype` method

"""

# ╔═╡ 0320b878-fc63-11ea-1957-af76f00942ab
md"""
- Construction by explicit list of elements:
"""

# ╔═╡ 139daba2-fc63-11ea-1842-53bebb3b04a2
v1=[1,2,3,4,]

# ╔═╡ 2c2f20e2-fc63-11ea-18ad-719e1f7662b9
eltype(v1)

# ╔═╡ 3ede343a-fc63-11ea-0792-a1eda50163d6
md"""
- If one element in the initializer is float, the vector becomes float:
"""

# ╔═╡ 3d900dd0-fc63-11ea-2be1-719e5a80498f
v2=[1.0,2,3,4,]

# ╔═╡ 6c9048e6-fc63-11ea-185c-b7f5413babfb
md"""
- Create vector of zeros for given type:
"""

# ╔═╡ 88f7964c-fc63-11ea-2698-1dd4b9f1a5b0
v3=zeros(Float32,5)

# ╔═╡ a1ea4f46-fc63-11ea-3f7b-8b1f0f71e465
md"""
- Fill vector with constant data:
"""

# ╔═╡ a916c498-fc63-11ea-1a59-4382ec08e8a5
fill!(v3,17)

# ╔═╡ d51cc876-fc63-11ea-1d28-41228d93dca4
md"""
### Ranges
- Ranges describe sequences of numbers and can be used in loops, array constructors  etc.
- They contain the recipe for the sequences, not the full data.
"""

# ╔═╡ eab4920c-fc63-11ea-0b43-5997af80fb16
r1=1:10

# ╔═╡ f9fcd834-fc63-11ea-198c-c9eee1433010
typeof(r1)

# ╔═╡ 7fc6853c-fc64-11ea-2bb8-2dc3ab97bf97
md"""
- We can collect the sequence from a range into a vector:
"""

# ╔═╡ 3f4a1296-fc64-11ea-11c6-7d911c11a0da
w1=collect(r1)

# ╔═╡ 4ca13404-fc64-11ea-3c3d-ede925be6d75
typeof(w1)

# ╔═╡ 7ccb1e06-fc64-11ea-24ba-9f888b9ea744
md"""
- We can add a step size to a range:
"""

# ╔═╡ 6d3b4d08-fc64-11ea-0894-2fe57067bab5
r2=1:0.8:10

# ╔═╡ 73b55016-fc64-11ea-0cff-afde17ebcbec
typeof(r2)

# ╔═╡ bc4b191e-fc64-11ea-1fd7-7d32d39de0af
md"""
- Create a vector from a list comprehension containing a range:
"""

# ╔═╡ df35a944-fc64-11ea-3e37-e7d4c974c54c
v4=[sin(i) for i=1:5]

# ╔═╡ e9684e00-fca3-11ea-3aea-b501ece9b724


# ╔═╡ f531a8fa-fca3-11ea-0954-97cf8873aeef
v5=rand(10)

# ╔═╡ fd2ded8a-fc64-11ea-1a97-75afa0e4d911
md"""
### Vector dimensions
"""

# ╔═╡ 15ea0d7a-fc65-11ea-25ea-31df67d466da
v6=collect(1:2:10)

# ╔═╡ 40c421ae-fc65-11ea-1ce4-a596c4563c73
md"""
- `size` is a tuple of dimensions
"""

# ╔═╡ 2a760444-fc65-11ea-130d-132b57aeb979
size(v6)

# ╔═╡ 5b82f63c-fc65-11ea-1324-c1a7e5b81884
md"""
- `length` describes the overall length:
"""

# ╔═╡ 3b92d630-fc65-11ea-1460-699ff383ae3a
length(v5)

# ╔═╡ 542d95e0-fc65-11ea-12e1-2f32db5d29bb
md"""
### Subarrays

- Copies of parts of arrays:
"""

# ╔═╡ 96e1203e-fc65-11ea-2d51-2b33a046b228
v7=collect(1:10)

# ╔═╡ caf6c854-fc65-11ea-1bdb-d13462ac0c67
subv7=v7[2:4]

# ╔═╡ db927bae-fc65-11ea-06b2-85ad344e1962
subv7[1]=17;v7

# ╔═╡ 1693f2d2-fc66-11ea-1081-2f07b862c599
v6

# ╔═╡ 2b897dba-fc66-11ea-09a6-a34789dcf783
md"""
- Views:
"""

# ╔═╡ 4284fcc4-fc66-11ea-2f76-5d5b84e30428
v8=collect(1:10)

# ╔═╡ 4cd76d56-fc66-11ea-0d62-ab6690d88b44
subv8=view(v8,2:4)

# ╔═╡ 5b6e6978-fc66-11ea-15c8-7d5097151f78
subv8[1]=19;v7

# ╔═╡ bd642672-fc66-11ea-0cf5-9591ec8f558c
md"""
- The `@views` macro can turn a copy statement into a view
"""

# ╔═╡ d5b616e0-fc66-11ea-1b16-a5fddbfe9284
v9=collect(1:10)

# ╔═╡ de83d776-fc66-11ea-361c-4f8185b96dd8
@views subv9=v9[2:4]

# ╔═╡ f01278c6-fc66-11ea-3eef-114c154b64d0
subv9[1]=29; v9

# ╔═╡ 13b86ba8-fc67-11ea-3d85-0d660241d6e5
md"""
### Dot operations
- element-wise operations on arrays
"""

# ╔═╡ 2998b1be-fc67-11ea-2b8d-dd02eb85c5a4
v10=collect(0:0.1π:2π)

# ╔═╡ 4763ed6c-fc67-11ea-3228-83f22def7e3a
sin.(v10)

# ╔═╡ 5122b374-fc67-11ea-1ee1-3d3bededbba7
v10.+100

# ╔═╡ d1e9795c-fc67-11ea-0ca8-010d0a930843
md"""
## Matrices
- Elements of a given type stored contiguously in memory, with   two-dimensional access
- Matrices and 2-dimensional arrays are the same
"""

# ╔═╡ 0d38d48c-fc68-11ea-3937-07f53c08c639
md"""
- Zero initialization:
"""

# ╔═╡ ebc2c266-fc67-11ea-11d1-43bf444a4e09
m1=zeros(5,6)

# ╔═╡ 18cbf39a-fc68-11ea-180b-0d816fb6c4a8
md"""
- `undef` initialization:
"""

# ╔═╡ f61f32be-fc67-11ea-2b5b-0f9fcf5be91f
m2=Matrix{Float64}(undef,3,3)

# ╔═╡ 2c9eb056-fc68-11ea-3d82-29cf71b501be
md"""
- list comprehension:
"""

# ╔═╡ 33e11e62-fc68-11ea-090c-990f946471e2
m3=[cos(x)*exp(y) for x=0:2:10, y=-1:0.5:1]

# ╔═╡ b9f3c388-fc68-11ea-3e20-a1af86c2737b
md"""
- Size, length:
"""

# ╔═╡ 6398076a-fc68-11ea-32ab-7b4f7e3e8d9d
size(m3)

# ╔═╡ c7a37712-fc68-11ea-2b9e-099a1f862820
length(m3)

# ╔═╡ 339eb580-fca5-11ea-2122-a94ab940dbce
md"""
### Linear Algebra
"""

# ╔═╡ d4df19f0-fca5-11ea-0b18-f938cac6a69f
n=100

# ╔═╡ 3c5487d6-fca5-11ea-0594-817ff71d752d
w=rand(n)

# ╔═╡ 5cb711e2-fca5-11ea-30a1-db0c76932800
u=rand(n)

# ╔═╡ f1bd229a-fca5-11ea-0756-79bda98c82cd
A=rand(n,n)

# ╔═╡ 7004a28c-fca5-11ea-3c01-7b1736208c6e
md"""
- Mean square norm  $||u||_2=\sqrt{\sum_{i=1}^n u_i^2}$
"""

# ╔═╡ 69544c8a-fca5-11ea-0d08-3963bc2ce5ae
norm(u)

# ╔═╡ 835fec92-fca5-11ea-3016-0307f9df5008
md"""
- Dot product: $(u,w)=\sum_{i=1}^n u_i w_i$
"""

# ╔═╡ b9b420c4-fca5-11ea-1dba-a15336997ea8
dot(u,w)

# ╔═╡ 03686b74-fca6-11ea-0c2e-d128682a034b
md"""
- Matrix vector product 
"""

# ╔═╡ 0f4fb01e-fca6-11ea-01e5-efe4df95e12a
A*u

# ╔═╡ 255c27cc-fca6-11ea-1d43-7f9dc8f810f4
md"""
- Trace (sum of main diagonal elements), determinant, inverse
"""

# ╔═╡ 46d69e46-fca6-11ea-3b5a-e576cb61a836
tr(A),det(A), inv(A)

# ╔═╡ 57e8fd46-fca6-11ea-1b50-7f42c9b23eb5
md"""
### Control structures
"""

# ╔═╡ da913876-fca6-11ea-363a-15f8dfce3135
md"""
- Conditional execution
"""

# ╔═╡ a3ec3744-fca6-11ea-2884-757ea1c647fd
cond1=false

# ╔═╡ 46909158-fca6-11ea-0d1e-0f3850ca0d6b
cond2=true

# ╔═╡ ad5c7bc2-fca6-11ea-1d5b-95245c695f86
if cond1
    "cond1"
elseif cond2
    "cond2"
else
    "nothing"
end

# ╔═╡ b2dd2c74-fca7-11ea-08e6-2daed042beb6
md"""
- ? operator for writing shorter code (borrowed from C)
"""

# ╔═╡ baa557dc-fca7-11ea-1597-09a4199ffdda
cond1 ? "cond1" : "nothing"

# ╔═╡ d76de50e-fca6-11ea-3524-6dd4c9e28740
md"""
- for loop
"""

# ╔═╡ e8534988-fca6-11ea-1700-6b576c80c02f
with_terminal() do
	for i in 1:5
		println(i)
	end
end

# ╔═╡ 882eb9b8-fca7-11ea-347b-a74062ea0762
md"""
- Preliminary exit of loop
"""

# ╔═╡ 91aeb4d4-fca7-11ea-389c-b5d7ce98aa23
with_terminal() do
	for i in 1:10
		println(i)
		if i>5 
			break
		end
	end
end
	

# ╔═╡ e80de4c6-fca7-11ea-3703-5710fab4386b
md"""
- Skipping iterations
"""

# ╔═╡ f5361ea2-fca7-11ea-228e-4d13abcf24db
with_terminal() do
	for i in 1:10
      if i==5
        continue
      end
      println(i)
	end
end

# ╔═╡ 31e17b8a-fca8-11ea-15f0-117f6f4fb195
md"""
## Functions
 - All arguments to functions are passed by reference
 - Function name ending with ! indicates that the function mutates at least one argument, typically the first
 - Function objects can be assigned to variables

Structure of function definition
````
 function func(req1, req2; key1=dflt1, key2=dflt2)
    # do stuff
     return out1, out2, out3
 end
````
- Required arguments are separated with a comma and use the positional notation
- Optional arguments need a default value in the signature
- Return statement is optional, by default, the result of the last statement is returned
- Multiple outputs can be returned as a tuple, e.g., return out1, out2, out3.

"""

# ╔═╡ f148e4e0-fca8-11ea-380e-a9e0f9597c2c
function func0(x; y=0)
    x+2*y
end

# ╔═╡ 017dca6a-fca9-11ea-2ff6-7d0f2fc61ee4
func0(1)

# ╔═╡ 063be8a2-fca9-11ea-302a-e12134da79ca
func0(1,y=100)

# ╔═╡ 526b1e8c-fca9-11ea-1695-8361d5799673
md"""
- One line function definition
"""

# ╔═╡ 5e244382-fca9-11ea-3f39-fd074d14bb36
g(x)=exp(sin(x))

# ╔═╡ 74566664-fca9-11ea-3d45-57d987dc423b
g(3)

# ╔═╡ 09e5c110-fcab-11ea-21cb-73ab92584128
md"""
- Nested function definitions
"""

# ╔═╡ 107607d8-fcab-11ea-16d3-2fc1d36c9c77
function outerfunction(n)
    function innerfunction(i)
        println(i)
    end
    for i=1:n
        innerfunction(i)
    end
end

# ╔═╡ 155da530-fcab-11ea-08ff-63b073db65a5
with_terminal() do
	outerfunction(13)
end

# ╔═╡ 2ecae066-fca9-11ea-2452-e97f8f952cff
md"""
- Functions are variables, too
"""

# ╔═╡ 35db8914-fca9-11ea-1a0f-111b45911227
h=g; h(3)

# ╔═╡ 8ece29aa-fca9-11ea-28d7-9d0f02bc1b38
md"""
- Functions as function parameters
"""

# ╔═╡ 99280d9e-fca9-11ea-368e-bdf64e7881b6
F(f,x)= f(x)

# ╔═╡ a80a1dfc-fca9-11ea-20b6-d7d0c9bc9eae
F(g,3)

# ╔═╡ b0b14f70-fca9-11ea-38d3-39761a3e4a28
md"""
- Anonymous functions (convenient in function parameters):
"""

# ╔═╡ ba903308-fca9-11ea-34d7-59618140f205
F(x -> sin(x),3)

# ╔═╡ 3bc22f66-fcab-11ea-36be-95318e3e2b68
md"""
- Do-block syntax: the body of first parameter is in the `do ... end` block:
"""

# ╔═╡ 46ccc5c4-fcab-11ea-3748-d59e661d702c
F(3) do x
	exp(sin(x))
end

# ╔═╡ 6f956df6-fcaa-11ea-1eb4-dd1ce7c483ab
md"""
### Functions and vectors
- Dot syntax can be used to make any  function work on vectors
"""

# ╔═╡ 9c2b40dc-fcaa-11ea-1982-9b5c15855f9e
v11=collect(0:0.1:1)

# ╔═╡ 77b2a20e-fcaa-11ea-3fec-61048c2e5dc2
h.(v11)

# ╔═╡ cbb3dd64-fcaa-11ea-1dc1-abbd95c3f1f7
md"""
- map function on vector 
"""

# ╔═╡ d4daa584-fcab-11ea-1d50-bf3a063cf0cc
map(h,v11)

# ╔═╡ ee5d3ca6-fcab-11ea-2511-15d6e0d1c17e
md"""
- mapreduce: apply operator to each element
"""

# ╔═╡ 37d5c2cc-fcac-11ea-2c9c-d379a3cb738c
mapreduce(x->x,*,v11)

# ╔═╡ 52cac3ca-fcac-11ea-1820-bfbc3a2bf578
mapreduce(x->x,+,v11)

# ╔═╡ 61890b6c-fcac-11ea-0d03-e9ba6a0590fe
sum(v11)

# ╔═╡ 4dd72724-0a46-11eb-3d02-9944f805070e
md"""
## Macros

Julia allows to define macros which allow to modify Julia statements before they are compiled and executed. This capability is similar to the preprocessor in C or C++. 
Macro names start with `@`.  Occasionally we will use predefined macros, e.g. `@elapsed` for returning the time used by some statement.
"""

# ╔═╡ b062277e-0a46-11eb-1e45-d9bf4ad361cf
@elapsed inv(rand(100,100))

# ╔═╡ Cell order:
# ╟─0f9d8036-fc5e-11ea-153f-23658d19c45f
# ╠═94a382fa-fc5e-11ea-03e1-55306eb5e74c
# ╠═c1670268-fc5e-11ea-3dd4-178a332e7839
# ╠═79146452-fc5f-11ea-0761-51d3d1195257
# ╠═c6b02eb2-fc5f-11ea-23fc-09fdeaf53a70
# ╠═f50aa9ae-fc5f-11ea-2889-2d4f586ea58a
# ╠═4410991a-0a42-11eb-0e62-4748173329c5
# ╠═5bd1cf88-0a42-11eb-3df3-23a1ec89fc29
# ╠═3bc30a3a-0a43-11eb-3295-25270a3c164c
# ╠═4b28f462-0a43-11eb-2e60-0de35bde96b7
# ╠═bed2320c-0a43-11eb-0702-77308108418a
# ╠═0707ae90-fc60-11ea-2702-afc82e07459a
# ╠═cb872c00-0a43-11eb-2144-0b37e7d99fb2
# ╠═484d33d8-0a42-11eb-30b2-717160db3d47
# ╠═1f99a6de-fc60-11ea-0226-c35cf524d558
# ╠═2d82b7fe-fc60-11ea-3acf-31c5a9fe5cd0
# ╠═43d5205a-fc60-11ea-306e-a707ff4b94d1
# ╠═a12b50da-fc60-11ea-3340-8d85841fa088
# ╠═b3a3a872-fc60-11ea-068c-d1395a440387
# ╠═bc9a48f8-fc60-11ea-104d-5599c7bbad6c
# ╠═6d96d7ce-0a45-11eb-1ce6-21d0a0a9fad2
# ╠═898bdcd6-0a45-11eb-0d54-214aa82543f8
# ╠═ae060544-0a45-11eb-0e01-d791db6ef0f5
# ╠═c3790734-0a45-11eb-2cc4-b3b6eb53ff0f
# ╠═3b0b284c-fc61-11ea-115d-5dd90f144926
# ╠═926aed66-fc61-11ea-23a8-91a37455bc77
# ╠═b8cd918e-fc61-11ea-25d0-6dd5ca9e4e32
# ╠═c4f4da76-fc61-11ea-2539-210bf0fb65d0
# ╠═c86b061c-fc61-11ea-01e2-170bcf486410
# ╠═da3d7de8-fc61-11ea-093d-0d91a09bae65
# ╠═e838e7b6-fc61-11ea-183b-e73a022fe43b
# ╠═ed6ed4f2-fc61-11ea-0750-b9247ad258ca
# ╠═05371d6a-fc62-11ea-20ea-376ecd786950
# ╠═15c3ef00-fc62-11ea-1f1f-b3a5258df8fa
# ╠═1bb8c336-fc62-11ea-3f4b-45d3b1ec2b0a
# ╠═4481ddd4-fc62-11ea-3fa9-594b973362b0
# ╠═287536f4-fc62-11ea-3e93-7158d175a9ae
# ╠═2de65460-fc62-11ea-0da1-77d0a5e3e4ce
# ╠═67b01d02-fc62-11ea-3509-db6f73066d57
# ╠═6ec302da-fc62-11ea-074a-a70d5942ce1e
# ╠═96246026-fc62-11ea-0485-cfee9eae67ee
# ╠═d97630b6-fc62-11ea-2639-d568abe02da8
# ╠═0320b878-fc63-11ea-1957-af76f00942ab
# ╠═139daba2-fc63-11ea-1842-53bebb3b04a2
# ╠═2c2f20e2-fc63-11ea-18ad-719e1f7662b9
# ╠═3ede343a-fc63-11ea-0792-a1eda50163d6
# ╠═3d900dd0-fc63-11ea-2be1-719e5a80498f
# ╠═6c9048e6-fc63-11ea-185c-b7f5413babfb
# ╠═88f7964c-fc63-11ea-2698-1dd4b9f1a5b0
# ╠═a1ea4f46-fc63-11ea-3f7b-8b1f0f71e465
# ╠═a916c498-fc63-11ea-1a59-4382ec08e8a5
# ╠═d51cc876-fc63-11ea-1d28-41228d93dca4
# ╠═eab4920c-fc63-11ea-0b43-5997af80fb16
# ╠═f9fcd834-fc63-11ea-198c-c9eee1433010
# ╠═7fc6853c-fc64-11ea-2bb8-2dc3ab97bf97
# ╠═3f4a1296-fc64-11ea-11c6-7d911c11a0da
# ╠═4ca13404-fc64-11ea-3c3d-ede925be6d75
# ╠═7ccb1e06-fc64-11ea-24ba-9f888b9ea744
# ╠═6d3b4d08-fc64-11ea-0894-2fe57067bab5
# ╠═73b55016-fc64-11ea-0cff-afde17ebcbec
# ╠═bc4b191e-fc64-11ea-1fd7-7d32d39de0af
# ╠═df35a944-fc64-11ea-3e37-e7d4c974c54c
# ╠═e9684e00-fca3-11ea-3aea-b501ece9b724
# ╠═f531a8fa-fca3-11ea-0954-97cf8873aeef
# ╠═fd2ded8a-fc64-11ea-1a97-75afa0e4d911
# ╠═15ea0d7a-fc65-11ea-25ea-31df67d466da
# ╠═40c421ae-fc65-11ea-1ce4-a596c4563c73
# ╠═2a760444-fc65-11ea-130d-132b57aeb979
# ╠═5b82f63c-fc65-11ea-1324-c1a7e5b81884
# ╠═3b92d630-fc65-11ea-1460-699ff383ae3a
# ╠═542d95e0-fc65-11ea-12e1-2f32db5d29bb
# ╠═96e1203e-fc65-11ea-2d51-2b33a046b228
# ╠═caf6c854-fc65-11ea-1bdb-d13462ac0c67
# ╠═db927bae-fc65-11ea-06b2-85ad344e1962
# ╠═1693f2d2-fc66-11ea-1081-2f07b862c599
# ╠═2b897dba-fc66-11ea-09a6-a34789dcf783
# ╠═4284fcc4-fc66-11ea-2f76-5d5b84e30428
# ╠═4cd76d56-fc66-11ea-0d62-ab6690d88b44
# ╠═5b6e6978-fc66-11ea-15c8-7d5097151f78
# ╠═bd642672-fc66-11ea-0cf5-9591ec8f558c
# ╠═d5b616e0-fc66-11ea-1b16-a5fddbfe9284
# ╠═de83d776-fc66-11ea-361c-4f8185b96dd8
# ╠═f01278c6-fc66-11ea-3eef-114c154b64d0
# ╠═13b86ba8-fc67-11ea-3d85-0d660241d6e5
# ╠═2998b1be-fc67-11ea-2b8d-dd02eb85c5a4
# ╠═4763ed6c-fc67-11ea-3228-83f22def7e3a
# ╠═5122b374-fc67-11ea-1ee1-3d3bededbba7
# ╠═d1e9795c-fc67-11ea-0ca8-010d0a930843
# ╠═0d38d48c-fc68-11ea-3937-07f53c08c639
# ╠═ebc2c266-fc67-11ea-11d1-43bf444a4e09
# ╠═18cbf39a-fc68-11ea-180b-0d816fb6c4a8
# ╠═f61f32be-fc67-11ea-2b5b-0f9fcf5be91f
# ╠═2c9eb056-fc68-11ea-3d82-29cf71b501be
# ╠═33e11e62-fc68-11ea-090c-990f946471e2
# ╠═b9f3c388-fc68-11ea-3e20-a1af86c2737b
# ╠═6398076a-fc68-11ea-32ab-7b4f7e3e8d9d
# ╠═c7a37712-fc68-11ea-2b9e-099a1f862820
# ╠═339eb580-fca5-11ea-2122-a94ab940dbce
# ╠═639862fe-fca5-11ea-2ada-4fa5fe9fcd09
# ╠═d4df19f0-fca5-11ea-0b18-f938cac6a69f
# ╠═3c5487d6-fca5-11ea-0594-817ff71d752d
# ╠═5cb711e2-fca5-11ea-30a1-db0c76932800
# ╠═f1bd229a-fca5-11ea-0756-79bda98c82cd
# ╠═7004a28c-fca5-11ea-3c01-7b1736208c6e
# ╠═69544c8a-fca5-11ea-0d08-3963bc2ce5ae
# ╠═835fec92-fca5-11ea-3016-0307f9df5008
# ╠═b9b420c4-fca5-11ea-1dba-a15336997ea8
# ╠═03686b74-fca6-11ea-0c2e-d128682a034b
# ╠═0f4fb01e-fca6-11ea-01e5-efe4df95e12a
# ╠═255c27cc-fca6-11ea-1d43-7f9dc8f810f4
# ╠═46d69e46-fca6-11ea-3b5a-e576cb61a836
# ╠═57e8fd46-fca6-11ea-1b50-7f42c9b23eb5
# ╠═da913876-fca6-11ea-363a-15f8dfce3135
# ╠═a3ec3744-fca6-11ea-2884-757ea1c647fd
# ╠═46909158-fca6-11ea-0d1e-0f3850ca0d6b
# ╠═ad5c7bc2-fca6-11ea-1d5b-95245c695f86
# ╠═b2dd2c74-fca7-11ea-08e6-2daed042beb6
# ╠═baa557dc-fca7-11ea-1597-09a4199ffdda
# ╠═d76de50e-fca6-11ea-3524-6dd4c9e28740
# ╠═e8534988-fca6-11ea-1700-6b576c80c02f
# ╠═882eb9b8-fca7-11ea-347b-a74062ea0762
# ╠═91aeb4d4-fca7-11ea-389c-b5d7ce98aa23
# ╠═e80de4c6-fca7-11ea-3703-5710fab4386b
# ╠═f5361ea2-fca7-11ea-228e-4d13abcf24db
# ╠═31e17b8a-fca8-11ea-15f0-117f6f4fb195
# ╠═f148e4e0-fca8-11ea-380e-a9e0f9597c2c
# ╠═017dca6a-fca9-11ea-2ff6-7d0f2fc61ee4
# ╠═063be8a2-fca9-11ea-302a-e12134da79ca
# ╠═526b1e8c-fca9-11ea-1695-8361d5799673
# ╠═5e244382-fca9-11ea-3f39-fd074d14bb36
# ╠═74566664-fca9-11ea-3d45-57d987dc423b
# ╠═09e5c110-fcab-11ea-21cb-73ab92584128
# ╠═107607d8-fcab-11ea-16d3-2fc1d36c9c77
# ╠═155da530-fcab-11ea-08ff-63b073db65a5
# ╠═2ecae066-fca9-11ea-2452-e97f8f952cff
# ╠═35db8914-fca9-11ea-1a0f-111b45911227
# ╠═8ece29aa-fca9-11ea-28d7-9d0f02bc1b38
# ╠═99280d9e-fca9-11ea-368e-bdf64e7881b6
# ╠═a80a1dfc-fca9-11ea-20b6-d7d0c9bc9eae
# ╠═b0b14f70-fca9-11ea-38d3-39761a3e4a28
# ╠═ba903308-fca9-11ea-34d7-59618140f205
# ╠═3bc22f66-fcab-11ea-36be-95318e3e2b68
# ╠═46ccc5c4-fcab-11ea-3748-d59e661d702c
# ╠═6f956df6-fcaa-11ea-1eb4-dd1ce7c483ab
# ╠═9c2b40dc-fcaa-11ea-1982-9b5c15855f9e
# ╠═77b2a20e-fcaa-11ea-3fec-61048c2e5dc2
# ╠═cbb3dd64-fcaa-11ea-1dc1-abbd95c3f1f7
# ╠═d4daa584-fcab-11ea-1d50-bf3a063cf0cc
# ╠═ee5d3ca6-fcab-11ea-2511-15d6e0d1c17e
# ╠═37d5c2cc-fcac-11ea-2c9c-d379a3cb738c
# ╠═52cac3ca-fcac-11ea-1820-bfbc3a2bf578
# ╠═61890b6c-fcac-11ea-0d03-e9ba6a0590fe
# ╠═4dd72724-0a46-11eb-3d02-9944f805070e
# ╠═b062277e-0a46-11eb-1e45-d9bf4ad361cf

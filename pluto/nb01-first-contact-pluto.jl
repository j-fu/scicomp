### A Pluto.jl notebook ###
# v0.12.11

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

# ╔═╡ 41b70dc6-1b01-11eb-138e-9db71f12f98b
using PlutoUI

# ╔═╡ 01a6905c-f433-11ea-3b49-2fd602014456
md"""
## Julia: First Contact - Basic Pluto

#### What is Pluto ?

Pluto is a browser based notebook interface for the Julia language. It allows to
present Julia code and computational results in a tightly linked fashion.

- __For those familiar with spreadsheets:__ 
  Pluto is like Google Sheets or Excel but with Julia code in its cells. 
  Pluto cells are arranged in one broad column. Communication of data between cells works via variables defined in the cells instead of cell references like `A5` etc. With Excel and other spreadsheets, Pluto shares the idea of *reactivity*: If a variable value is changed in the cell where it is defined, the code in all dependent cells aka cells using this variable is executed.

- __For those familiar with Jupyter notebooks:__  
  Pluto is like Jupyter for Julia, but without the hidden state created by the unlimited possibility to execute  cells in arbitrary sequence. Instead, it enhances the notebook concept by *reactivity*. 

Pluto is implemented in a combination of Julia and javascript, and can be installed like any other Julia package. 

During this course, Pluto notebooks will be used to present numerical methods implemented in Julia.

#### Pluto resources:
- [Pluto repository at Github](https://github.com/fonsp/pluto.jl)
- [How to Install Pluto](https://www.youtube.com/watch?v=OOjKEgbt8AI) (straight from the main author Fons van der Plas)
- Sample notebooks are available via the index page after starting Pluto.

#### Pluto structure
Pluto notebooks consist of a sequence of cells which contain valid Julia code. The result of execution
of the code in a cell is its return value which is displayed on top of the cell.
"""

# ╔═╡ f12cfb18-f433-11ea-3432-b32419390eda
md"""
#### Text cells and cell visibility

Cells can consist of a  string with text in [Markdown](https://www.markdownguide.org/) format. This single text string is valid Julia code and thus returned, formatted and shown as text.
"""

# ╔═╡ e8ac49c6-f433-11ea-147c-11e010039620
md"""
Cells can be visible... 
"""

# ╔═╡ 43ce634a-f434-11ea-049a-ff8e01fb6745
md"""
... or hidden, but their return value is visible nevertheless.Visibility can be toggled via the eye symbol on the top left of the cell.  We will use markdown cells for displaying text and explanatory information, and keep them hidden.
"""

# ╔═╡ 52027ee4-f435-11ea-3065-833f23254a74
md"""
##### LaTeX
Cells can contain $\LaTeX$ math code: $\int_0^1 sin(π ξ) dξ$. Just surround
it by \$ symbols as in usual $\LaTeX$ texts or by double backtics: ``\int_0^1 sin(π ξ) dξ``.
The later method is safer as it does not collide with string interpolation (explained below).
"""

# ╔═╡ 9c226b88-fc58-11ea-0370-41b85e92cf36
md"""
#### Code cells
Code cells are cells which just contain "normal" Julia code. Running the code in the cell is triggered by the `Shift-Enter` keyboard combination or clicking on the triangle symbol on the right below the cell.
"""

# ╔═╡ c565be16-f433-11ea-2c48-e131e91f789c
md"""
#### Variables and reactivity 
We can define a variable in a cell.The assignment has a return value like any other Julia statement which is shown on top of the cell.
"""

# ╔═╡ 642b40f2-f434-11ea-177b-1ba7f11802a2
x=5

# ╔═╡ 6bf8dc22-f434-11ea-1ccf-95d9f39cde2f
md"""
A variable defined in one cell can be used in another cell. Moreover, if the value is changed, the other cell reacts and the code contained in that cell is executed with the new value of the variable. This *reactive* behaviour typical for a spreadsheet.
"""

# ╔═╡ 6a1ef03c-f434-11ea-2def-e369c93f0941
x+1

# ╔═╡ 1116dc44-09bc-11eb-290a-9b243ee60404
md"""
One can return several results by stating them  separated by `,` . The returned value then is a tuple.
"""

# ╔═╡ 252a8404-09bc-11eb-0b08-33082623a2bd
x+1,x+2,x+3

# ╔═╡ f3f0868e-0a39-11eb-0a53-dd91137a9f04
md"""
Display of the return value can be suppressed by ending the last statement with `;`
""";

# ╔═╡ fd4cccd2-f435-11ea-1445-6135ffb575cd
md"""
#### Only one statement per cell

Each cell can contain only exactly one Julia statement.  If multiple expressions are desired, they can made into one by surrounding them by `begin` and `end`.  The return value will be the return value of the last expression in the statement.
"""

# ╔═╡ cacb33f0-09bb-11eb-09c6-219aa5521fdd
md"""
An alternative way to have all statements on one line, separated by `;`:
"""

# ╔═╡ d8304f86-0a39-11eb-392a-ddfe6bb15407
md"""
However, in this situation the better structural decision would be to combine the statements into a function defined in one cell and to call it in another cell.
"""

# ╔═╡ 1847c644-0a3a-11eb-1480-192677ceafe4
function f(x,v)
	z=x+v
	cos(z)
end;

# ╔═╡ d147bd98-f434-11ea-24ea-4d7d74ea4ad6
md"""
#### Interactivity

We can bind interactive HTML elements to variables:
"""

# ╔═╡ cdfce4ae-f434-11ea-3919-67326f3cd259
@bind v html"<input type=range>"

# ╔═╡ 7b5cff5a-f436-11ea-3ede-59183061a433
begin
	z=x+v
	sin(z)
end

# ╔═╡ e6105c1e-09bb-11eb-1368-fd2151e7ba79
z1=x+v; cos(z1)

# ╔═╡ 251d1036-0a3a-11eb-1db0-9fd46b886027
f(x,v)

# ╔═╡ b3a9aad0-f435-11ea-39cf-e3a514257dab
md"""v=$(v)  (This uses _string interpolation_ to print the value of v into the Markdown string)"""

# ╔═╡ 5d600b34-09bc-11eb-0d22-b5916513b971
md"""
This example also shows that the dependency of one cell from another is defined via the involved variables and not by the sequence in the notebook: the value `v` in the cells above is defined by the slider.

In order to achieve this, Pluto makes extensive use of the possibility to inspect the variables defined in a running Julia instance using Julia itself.
"""

# ╔═╡ 9dcd57b0-f438-11ea-32b3-093908389ac1
md""" 
#### Deactivating code

We occasionally will use the possibility to deactivate cells before running their code. This can be useful for preventing long runnig code to start immediately after loading the notebook or for pedagogical reasons.

The preferred pattern for this uses a checkbox bound to a logical variable.

__Run next cell__: $(@bind allow_run html"<input type=checkbox>")
"""

# ╔═╡ 10fc80ac-f43a-11ea-3234-0f301d8b05c0
if allow_run
	using LinearAlgebra
	a=rand(2000,2000)
	eigvals(inv(a))
end

# ╔═╡ 43493d8a-fc59-11ea-00d5-d188ed8a56b3
md"""
### Accessing text output

Normally text output from statements in a cell is shown in the console window where Pluto was started, and not in the notebook, as Pluto focuses on the presentation of the results. Sometimes it is however desirable to inspect this output instead of the result returned. For this purpose, we use the Julia package `PlutoUI.jl` which defines the function `with_terminal`:
"""

# ╔═╡ c0e32bd4-fc59-11ea-1538-e928da52b4df
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add("PlutoUI")
end

# ╔═╡ ea5322e4-fc59-11ea-036a-073625d78246
with_terminal() do
	for i=1:30
		println(i)
	end
end

# ╔═╡ 0b867b9e-09bd-11eb-2785-13dd948f53e8
md"""
#### Live docs

The live docs pane in the lower right bottom allows to quickly obtain help information about documented Julia functions etc.
"""

# ╔═╡ Cell order:
# ╟─01a6905c-f433-11ea-3b49-2fd602014456
# ╟─f12cfb18-f433-11ea-3432-b32419390eda
# ╠═e8ac49c6-f433-11ea-147c-11e010039620
# ╟─43ce634a-f434-11ea-049a-ff8e01fb6745
# ╠═52027ee4-f435-11ea-3065-833f23254a74
# ╟─9c226b88-fc58-11ea-0370-41b85e92cf36
# ╟─c565be16-f433-11ea-2c48-e131e91f789c
# ╠═642b40f2-f434-11ea-177b-1ba7f11802a2
# ╟─6bf8dc22-f434-11ea-1ccf-95d9f39cde2f
# ╠═6a1ef03c-f434-11ea-2def-e369c93f0941
# ╟─1116dc44-09bc-11eb-290a-9b243ee60404
# ╠═252a8404-09bc-11eb-0b08-33082623a2bd
# ╠═f3f0868e-0a39-11eb-0a53-dd91137a9f04
# ╟─fd4cccd2-f435-11ea-1445-6135ffb575cd
# ╠═7b5cff5a-f436-11ea-3ede-59183061a433
# ╟─cacb33f0-09bb-11eb-09c6-219aa5521fdd
# ╠═e6105c1e-09bb-11eb-1368-fd2151e7ba79
# ╟─d8304f86-0a39-11eb-392a-ddfe6bb15407
# ╠═1847c644-0a3a-11eb-1480-192677ceafe4
# ╠═251d1036-0a3a-11eb-1db0-9fd46b886027
# ╟─d147bd98-f434-11ea-24ea-4d7d74ea4ad6
# ╟─cdfce4ae-f434-11ea-3919-67326f3cd259
# ╠═b3a9aad0-f435-11ea-39cf-e3a514257dab
# ╟─5d600b34-09bc-11eb-0d22-b5916513b971
# ╟─9dcd57b0-f438-11ea-32b3-093908389ac1
# ╠═10fc80ac-f43a-11ea-3234-0f301d8b05c0
# ╟─43493d8a-fc59-11ea-00d5-d188ed8a56b3
# ╠═c0e32bd4-fc59-11ea-1538-e928da52b4df
# ╠═41b70dc6-1b01-11eb-138e-9db71f12f98b
# ╠═ea5322e4-fc59-11ea-036a-073625d78246
# ╟─0b867b9e-09bd-11eb-2785-13dd948f53e8

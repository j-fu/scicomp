### A Pluto.jl notebook ###
# v0.12.13

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

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin 
	using Pkg
	Pkg.activate(mktempdir())
	Pkg.add("PyPlot")
	Pkg.add("PlutoUI")
	using PlutoUI
	using PyPlot
end

# ╔═╡ fac77c3a-3037-11eb-21a4-9f56d2a0e444
md"""
 # Plotting & visualization

 __Human perception is much better adapted to visual representation than to numbers__

 Purposes of plotting:
 - Visualization of research results for publications & presentations
 - Debugging + developing algorithms
 - "In-situ visualization" of evolving computations
 - Investigation of data
 - 1D, 2D, 3D, 4D data
 - Similar tasks in CAD, Gaming, Virtual Reality $\dots$
 """

# ╔═╡ 0dba22b6-3038-11eb-3904-d9dbb31208d9
md"""
 ## Processing steps in visualization
 ### High level tasks:

 - Representation of data using elementary primitives: points,lines, triangles $\dots$
 - Very different depending on purpose

 ### Low level tasks
 - Coordinate transformation from "world coordinates" of a particular model to screen coordinates
 - Transformation 3D $\to$ 2D, visibility computation
 - Coloring, lighting, transparency
 - Rasterization: turn smooth data into pixels

"""

# ╔═╡ 1b506df4-3038-11eb-30db-7394441b243d
md"""
 ### Software implementation of low level tasks

 - Software: rendering libraries, e.g.  Cairo, AGG
 - Software for vector based graphics formats, e.g. PDF, postscript, svg
 - Typically performed on CPU

"""

# ╔═╡ 250f9d42-3038-11eb-2921-53ca6912091b
md"""
 ### Hardware for   low level tasks
 - Low level tasks are characterized by huge number of very similar operations 
 - Well adaped to parallelism "Single Instruction, Multiple Data" (SIMD)
 - Dedicated hardware: *Graphics Processing Unit* (GPU) can free CPU  from these taks
 - Multiple parallel pipelines, fast memory for intermediate results

$(Resource("https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/NVIDIA-GTX-1070-FoundersEdition-FL.jpg/1024px-NVIDIA-GTX-1070-FoundersEdition-FL.jpg", :width=> 300))
(wikimedia)
"""

# ╔═╡ 3bf94078-3038-11eb-2605-03ee12a5cf33
md"""
 ### GPU Programming
 - Typically, GPUs are processing units which are connected via bus interface to CPU
 - GPU Programming:
   - Prepare low level data for GPU
   - Send data to GPU
   - Process data in rendering pipeline(s)
 - Modern visualization programs have a CPU part and GPU parts a.k.a. *shaders*
   - Shaders allow to program details of data processing on GPU
   - Compiled on CPU, sent along with data to GPU
 - Modern libraries: Vulkan, modern OpenGL/WebGL, DirectX
 - Possibility to "mis-use" GPU for numerical computations
"""

# ╔═╡ e3f9476c-3038-11eb-1b1b-1ff373f37b7f
md"""
 ### GPU Programming in the "old days"
 - "Fixed function pipeline"  in OpenGL 1.1 fixed one particular set of shaders
 - Easy to program
 
````
 glClear()
 glBegin(GL_TRIANGLES)
 glVertex3d(1,2,3)
 glVertex3d(1,5,4)
 glVertex3d(3,9,15)
 glEnd()
 glSwapBuffers()
````
 - Not anymore: now everything works through shaders leading to highly complex programs

"""

# ╔═╡ fe40fb42-3038-11eb-29d0-f712decfc5e3
md"""
### Library interfaces to GPU useful for Scientific Visualization

- [vtk](https://vtk.org) (backend of [Paraview](https://paraview.org))
- [three.js](https://threejs.org) (for WebGL in the browser)
- Alternatively, work directly with OpenGL...
- very few $\dots$
  - Money seems to be in gaming, battlefield rendering $\dots$
  - Problem regadless of julia, python, C++, $\dots$
- Common approach:
  - Write data into "vtk" files, use paraview for visualization.
"""

# ╔═╡ 2a5ed97c-3039-11eb-32d4-69d4b272af15
md"""
## Graphics in Julia

- [Plots.jl](https://github.com/JuliaPlots/Plots.jl) General purpose plotting package with different backends
  - GPU support via default `gr` backend (based on "old" OpenGL)
- [Plotly.jl](https://github.com/plotly/Plotly.jl) Interface to javascript library plotly.js 
  - plots in the browser or electron window
  - also as backend for Plots.jl
  - some WebGL functionality
- [Makie.jl](https://github.com/JuliaPlots/Makie.jl) 
   - GPU based plotting using modern OpenGL
   - good plot performance, some precompilation time
   - essentially still under development
- [WGLMakie.jl](https://github.com/JuliaPlots/Makie.jl) maps Makie API to three.js, can be used from the browser
- [WriteVTK.jl](https://github.com/jipolanco/WriteVTK.jl) vtk file writer for files to be used with paraview - so this is not a plotting library.
- [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl): Interface to [python/matplotlib](https://matplotlib.org/)
  - realization via PyCall.jl 
  - also as backend for Plots.jl
"""

# ╔═╡ 421bf420-3039-11eb-2374-55685b6b81b7
md"""
### PyPlot
During this course we will use PyPlot, but feel free to try some of the other packages.
- It has all the functionality we need (including plots on triangular meshes not available in Plots.jl)
- Python users instantly will recognize the interfaces
- Knowledge obtained here can also be used in python
- Low precompilation time (as opposed to e.g. Makie)
Drawback: Plotting performance - it does not use the  GPU, large parts of the logic are in python
"""

# ╔═╡ 9ed404cc-3044-11eb-3782-432d0082aaf4
md"""
PyPlot resources:
- [Julia package](https://github.com/JuliaPy/PyPlot.jl)
- [Julia examples](https://gist.github.com/gizmaa/7214002)
- [Matplotlib documentation](https://gist.github.com/gizmaa/7214002)
"""

# ╔═╡ 8cc478a4-303f-11eb-0494-af9cd5ce0486
md"""
We can choose the way the plot is created: in the browser it can make sense to create it as a vector graphic in svg format. The alternatice is png, a pixel based format.
"""

# ╔═╡ 32526c26-303f-11eb-1430-377a25f1fa21
PyPlot.svg(true)

# ╔═╡ ae5f9802-3094-11eb-3ed9-c111678d8ec4
md"""
How to create a plot ?
"""

# ╔═╡ 45b7f8cc-3039-11eb-3e73-e724169282c1
let 
    X=collect(0:0.01:10)
	PyPlot.clf() # Clear the figure
	PyPlot.plot(X,sin.(exp.(X/3))) # call the plot function
	figure=PyPlot.gcf() # return figure to Pluto
end

# ╔═╡ c6fe4f30-3040-11eb-0b60-99f7f78ae7c1
md"""
Instead of a `begin/end` block we used a `let` block. In a let block, all new variables are local and don't interfer with other pluto cells.
"""

# ╔═╡ ba6e398c-303f-11eb-19b4-4959e002eeac
md"""
This plot is not nice. It lacks:
- orientation lines ("grid")
- title
- axis labels
- label of the plot
- size adjustment
"""

# ╔═╡ e70b1bf4-303f-11eb-3e0c-2534c60c72ac
let 
	X=collect(0:0.01:10)
	PyPlot.clf() 
	PyPlot.plot(X,sin.(exp.(X/3)),
		label="\$\\sin(e^{x/3})\$", color=:red) # Plot with label
	PyPlot.plot(X,exp.(sin.(X/3)),
		label="\$e^{\\sin x/3}\$",color=(0.2,0.2,0.7)) # Plot with label
	PyPlot.legend(loc="lower left") # legend placement
	PyPlot.title("A better plot") # The plot title
	PyPlot.grid() # add grid lines to the plot
	PyPlot.xlabel("x") # x axis label
	PyPlot.ylabel("y") # y axis label
	figure=PyPlot.gcf()
	figure.set_size_inches(8,3) # adjust size
	PyPlot.savefig("myplot.png") # save figure to disk
	figure # return figure
end

# ╔═╡ 7cd839e0-3041-11eb-0c0e-d9b54a0493cb
md"""
We can use $\LaTeX$ math strings in plot labels here, we just need to escape the `$` symbols with `\` !
"""

# ╔═╡ 6d2f9168-3042-11eb-1ee9-7ba01d644c1e
let 
	X=collect(0:0.01:10)
	PyPlot.clf() 
    PyPlot.suptitle("Two plots in one") # Title of compound plot

	PyPlot.subplot(211) # Subplot: 2 rows, 1 column, 1st plot
	PyPlot.plot(X,sin.(exp.(X/3)),
		label="\$\\sin(e^x)\$", color=:red)
	PyPlot.grid()
	PyPlot.xlabel("x")
	PyPlot.ylabel("y")
	PyPlot.legend(loc="lower left")

	PyPlot.subplot(212) # Subplot: 2 rows, 1 column, 2nd plot
	PyPlot.plot(X,exp.(sin.(X/3)),
		label="\$e^{\\sin x}\$",color=(0.2,0.2,0.7))
	PyPlot.legend(loc="lower center")
	PyPlot.grid()
	PyPlot.xlabel("x")
	PyPlot.ylabel("y")

	figure=PyPlot.gcf()
	figure.set_size_inches(8,3)
	figure
end

# ╔═╡ 055f4170-3095-11eb-08e2-dd3410e6ef53
md"""
#### Plotting 2D data
"""

# ╔═╡ 40fe9cc6-3045-11eb-2e96-35c4e9d25eb4
md"""
k: $(@bind k PlutoUI.Slider(0.1:0.05:1, default=0.3))
l: $(@bind l PlutoUI.Slider(0.1:0.05:1, default=0.2))
"""

# ╔═╡ 193d61ae-3045-11eb-0cf4-c703723386f6
let
	clf()
	X=collect(0:0.05:10)
	Y=X
	suptitle("Filled contours aka heatmap: k=$(k) l=$(l)")
	F=[sin(k*π*X[i])*sin(l*π*Y[j]) for i=1:length(X), j=1:length(Y)]
	contourf(X,Y,F) # plot filled contours
	xlabel("x")
	ylabel("y")
	figure=gcf()
	figure.set_size_inches(5,5)
	figure
end

# ╔═╡ 1e7fa2c6-3047-11eb-22f1-9b18dff72eff
let
	clf()
	X=collect(0:0.05:10)
	Y=X
	suptitle("Contour plot: k=$(k) l=$(l)")
	F=[sin(k*π*X[i])*sin(l*π*Y[j]) for i=1:length(X), j=1:length(Y)]
	contour(X,Y,F,colors=:black)
	xlabel("x")
	ylabel("y")
	gcf()
end

# ╔═╡ 2e321702-304b-11eb-18f4-47dcf69f4af9
md"""
Remove the moire in the plot: $(@bind fix_moire CheckBox(default=false))

This occurs in `contourf` when we use many colors to make a smooth impression.
"""

# ╔═╡ dfddb186-3047-11eb-2708-b764b16052f9
let
	clf()
	X=collect(0:0.05:10)
	Y=X
	suptitle("Contour + filled contours: k=$(k) l=$(l)")
	F=[sin(k*π*X[i])*sin(l*π*Y[j]) for i=1:length(X), j=1:length(Y)]
    fmin=minimum(F)
	fmax=maximum(F)
	number_of_isolines=10
	isolines=collect(fmin:(fmax-fmin)/number_of_isolines:fmax)
	cnt=contourf(X,Y,F,cmap="hot",levels=100)
	if fix_moire
		for c in cnt.collections
           c.set_edgecolor("face")
        end
	end
    axes=gca()
	axes.set_aspect(1)
	colorbar(ticks=isolines)
	contour(X,Y,F,colors=:black,linewidths=0.75,levels=isolines)
	xlabel("x")
	ylabel("y")
	gcf()
end

# ╔═╡ 7ff775e4-304a-11eb-3628-4bf273a4072f
md"""
α: $(@bind α PlutoUI.Slider(0:1:90,default=30))
β: $(@bind β PlutoUI.Slider(0:1:180,default=30))
"""

# ╔═╡ 45ddb246-3049-11eb-0fe3-b53512d75c5d
let
	clf()
	X=collect(0:0.05:10)
	Y=X
	suptitle("Surface plot: k=$(k) l=$(l)")
	F=[sin(k*π*X[i])*sin(l*π*Y[j]) for i=1:length(X), j=1:length(Y)]

	surf(X,Y,F,cmap=:summer) # 3D surface plot
	ax=gca(projection="3d")  # Obtain 3D plot axes
	ax.view_init(α,β) # Adjust viewing angles

	
	xlabel("x")
	ylabel("y")
	gcf()
end

# ╔═╡ fec36298-304a-11eb-380d-bbd351078bae
md"""
... all movements could be much faster if we would use the GPU...
"""

# ╔═╡ 2136a952-3049-11eb-3510-9df471b5e26e
md"""
There are analogues for `contour` `contourf` and `surf` on triangular meshes which will be discussed once we get there in the course.
"""

# ╔═╡ 47336856-3095-11eb-2bce-2b63604b3b7f
md"""
Feel free watch my [vizcon2 talk](https://www.youtube.com/watch?v=DmueA_Lvigs) about using vtk from Julia - just to show what could be possible. Unfortunately, these things currently work only on Linux...
"""

# ╔═╡ Cell order:
# ╟─60941eaa-1aea-11eb-1277-97b991548781
# ╟─fac77c3a-3037-11eb-21a4-9f56d2a0e444
# ╟─0dba22b6-3038-11eb-3904-d9dbb31208d9
# ╟─1b506df4-3038-11eb-30db-7394441b243d
# ╟─250f9d42-3038-11eb-2921-53ca6912091b
# ╟─3bf94078-3038-11eb-2605-03ee12a5cf33
# ╟─e3f9476c-3038-11eb-1b1b-1ff373f37b7f
# ╟─fe40fb42-3038-11eb-29d0-f712decfc5e3
# ╟─2a5ed97c-3039-11eb-32d4-69d4b272af15
# ╟─421bf420-3039-11eb-2374-55685b6b81b7
# ╟─9ed404cc-3044-11eb-3782-432d0082aaf4
# ╟─8cc478a4-303f-11eb-0494-af9cd5ce0486
# ╠═32526c26-303f-11eb-1430-377a25f1fa21
# ╟─ae5f9802-3094-11eb-3ed9-c111678d8ec4
# ╠═45b7f8cc-3039-11eb-3e73-e724169282c1
# ╟─c6fe4f30-3040-11eb-0b60-99f7f78ae7c1
# ╟─ba6e398c-303f-11eb-19b4-4959e002eeac
# ╠═e70b1bf4-303f-11eb-3e0c-2534c60c72ac
# ╟─7cd839e0-3041-11eb-0c0e-d9b54a0493cb
# ╠═6d2f9168-3042-11eb-1ee9-7ba01d644c1e
# ╟─055f4170-3095-11eb-08e2-dd3410e6ef53
# ╟─40fe9cc6-3045-11eb-2e96-35c4e9d25eb4
# ╠═193d61ae-3045-11eb-0cf4-c703723386f6
# ╠═1e7fa2c6-3047-11eb-22f1-9b18dff72eff
# ╠═dfddb186-3047-11eb-2708-b764b16052f9
# ╟─2e321702-304b-11eb-18f4-47dcf69f4af9
# ╟─7ff775e4-304a-11eb-3628-4bf273a4072f
# ╠═45ddb246-3049-11eb-0fe3-b53512d75c5d
# ╟─fec36298-304a-11eb-380d-bbd351078bae
# ╟─2136a952-3049-11eb-3510-9df471b5e26e
# ╟─47336856-3095-11eb-2bce-2b63604b3b7f

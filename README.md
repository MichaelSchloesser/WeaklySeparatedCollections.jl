# WeaklySeparatedCollections

[![CI](https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl/actions/workflows/ci.yml)

In its core, this package implements the combinatorics of weakly separated collections.
It also provides optional tools for plotting as well an intuitive graphical user interface.

---

## Table of Contents
0. [Introduction](https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl)<br>
1. [Installation](#installation)<br>
1.1. [Base Package](#base-package)<br>
1.2. [Extensions](#extensions)<br>
3. [Documentation](#documentaion)<br>
4. [Showcase](#showcase)<br>

---

## Installation
This package is divided into severaral parts. The base package implements only the combinatorics while several optional extensions can be loaded to enable additional features such as plotting.

### Base package

To install the package execute the following in the Julia REPL:

```julia
import Pkg;
Pkg.add(url="https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl")
```

The package may then be used as usual via

```julia
using WeaklySeparatedCollections
```

### Extensions
To enable extensions Julia v1.9 or newer, as well as some additional packages need to be installed.

#### Plotting
To use this feature, [Luxor](https://github.com/JuliaGraphics/Luxor.jl) needs to be installed. In the Julia REPL simply execute:

```julia
import Pkg;
Pkg.add("Luxor")
```

Now load both WeaklySeparatedCollections and Luxor to activate the plotting extension:

```julia
using WeaklySeparatedCollections
using Luxor 
```

#### GUI
To use the graphical user interface, [Luxor](https://github.com/JuliaGraphics/Luxor.jl) and [Mousetrap](https://github.com/Clemapfel/Mousetrap.jl) are required.
Installing Luxor is explained in the previous section. To install Mousetrap run:

```julia
import Pkg;
Pkg.add(url="https://github.com/clemapfel/mousetrap.jl")
```

Now loading all of WeaklySeparatedCollections, Luxor and Mousetrap will activate the gui extension.

```julia
using WeaklySeparatedCollections
using Luxor
using Mousetrap
```

---

## Documentaion

A full Documentaion is available [here](https://michaelschloesser.github.io/WeaklySeparatedCollections.jl/stable/). This includes a brief introduction to the required mathematical background, as well as a description of all functions and types.

---

## Showcase

TODO

  



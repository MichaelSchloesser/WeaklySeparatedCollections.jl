# WeaklySeparatedCollections

In its core, this package implements the combinatorics of weakly separated collections.
It also provides optional tools for plotting as well an intuitive graphical user interface.

## How to install

This package is divided into severaral parts. The base package implements only the combinatorics while several optional extensions can be loaded to enable additional features such as plotting.

To install the package execute the following in the Julia REPL:

```julia
import Pkg;
Pkg.add(url="https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl")
```

The package may then be used as usual via

```julia
using WeaklySeparatedCollections
```

## Extensions

To enable extensions Julia v1.9 or newer, as well as some additional packages need to be installed.

### Plotting
To use this feature, [Luxor](https://github.com/JuliaGraphics/Luxor.jl) needs to be installed. In the Julia REPL simply execute:

```julia
import Pkg;
Pkg.add("Luxor")
```

Now load both WeaklySeparatedCollections and Luxor to activate the plotting extension:

```julia
using WeaklySeparatedCollections
import Luxor 
```

### GUI
To use the graphical user interface, [Luxor](https://github.com/JuliaGraphics/Luxor.jl) and [Mousetrap](https://github.com/Clemapfel/Mousetrap.jl) are required.
Installing Luxor is explained in the previous section. To install Mousetrap run:

```julia
import Pkg;
Pkg.add(url="https://github.com/clemapfel/mousetrap.jl")
```

Now loading all of WeaklySeparatedCollections, Luxor and Mousetrap will activate the gui extension.

```julia
using WeaklySeparatedCollections
import Luxor
import Mousetrap
```

### Oscar
We extend some functionality of [Oscar](https://github.com/oscar-system/Oscar.jl) and add methods to handle the A-cluster mutation of Seeds coming from weakly separated collections as well as the associated newton-okounkov-bodies.

This extension is only supported for Linux users (although Windows users may use Linux from Windows via [wsl](https://learn.microsoft.com/en-us/windows/wsl/)).
We refer to the official [Oscar website](https://www.oscar-system.org/install/) for details on the installation.

Afterward using the loading the extension is as simple as typing

```julia
using WeaklySeparatedCollections
using Oscar
```
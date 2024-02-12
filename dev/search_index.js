var documenterSearchIndex = {"docs":
[{"location":"usage/#User-guide","page":"User guide","title":"User guide","text":"","category":"section"},{"location":"usage/#Introduction","page":"User guide","title":"Introduction","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"We start off by giving some mathematical background, or rather by defining the needed language.","category":"page"},{"location":"usage/#Weakly-separated-Collections","page":"User guide","title":"Weakly separated Collections","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"For any integer n geq 1 we use the notation n= { 1 2 ldots n } and denote by textPot(kn) the set of k-subsets of n.","category":"page"},{"location":"usage/#Definition-(weak-separation)","page":"User guide","title":"Definition (weak separation)","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"Let I J be k-subsets of n, then we call I and J textbfweakly separated if we cannot find elements a c in I setminus J and b d in J setminus I such that  (a b c d) is strictly cyclically ordered. In this case we write I parallel J. ","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"Intuitively two k-subsets are weakly separated if after can arranging I setminus J and J setminus I clockwise on a circle, they can be separated by a line.","category":"page"},{"location":"usage/#Definition-(weakly-separated-collection)","page":"User guide","title":"Definition (weakly separated collection)","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"A subset mathcalC subseteq textPot(kn) is called a textbfweakly separated collection (abbreviated by WSC) if its elements are pairwise weakly separated.  We often referr to elements of a WSC as labels.","category":"page"},{"location":"usage/#Definition-(mutation)","page":"User guide","title":"Definition (mutation)","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"If mathcalC is a WSC that includes sets of the form Iab Ibc Icd Iad and Iac, where (abcd) is strictly cyclically ordered.  Then mathcalC = (mathcalC setminus Iac) cup Ibd is also a weakly separated collection, and we call the exchange of Iac by Ibd a textbfmutation.","category":"page"},{"location":"usage/#Plabic-Tilings","page":"User guide","title":"Plabic Tilings","text":"","category":"section"},{"location":"usage/#Definition-(plabic-tiling)","page":"User guide","title":"Definition (plabic tiling)","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"Any WSC can be given the structure of an abstract 2-dimensional cell complex, which in turn may be embedded into the plane. This construction will be called an (abstract) textbfplabic tiling, and we referr to  TODO for the mathematical details.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"Intuitively a plabic tiling is a tiling of a convex n-gon into convex polygons, colored either black or white, and with vertices labelled by the elements of the underlying WSC. Plabic tilings are in bijective correspondance with WSC's that are maximal with respect to inclusion.","category":"page"},{"location":"usage/#Plabic-Graphs","page":"User guide","title":"Plabic Graphs","text":"","category":"section"},{"location":"usage/#Definition-(plabic-graph)","page":"User guide","title":"Definition (plabic graph)","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"A textbfplabic graph is a finite simple connected plane graph G whose interior is bounded by a vertex disjoint cycle containing n textbfboundary vertices  b_1 ldots b_n. Here the labelling is chosen in clockwise order.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"We only consider textbfreduced plabic graphs which can be also seen to be in one to one correspondance to WSC's that are maximal with respect to inclusion.  For more details we referr to TODO.","category":"page"},{"location":"usage/#Weakly-separated-collections","page":"User guide","title":"Weakly separated collections","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"In this section we will learn how to create and use a WSC.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"compat: Vectors instead of sets\nIn this package we use vecors in place of sets, although WSC's are by definition sets of k-sets.  We always assume such vectors to be increasingly ordered and not contain double elements.  None of the below methods check these properties and unforseen behavior may arise if they are not fulfilled.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"The data type for WSC's or rather (abstract) plabic tilings is given by WSCollection.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"WSCollection","category":"page"},{"location":"usage/#WeaklySeparatedCollections.WSCollection","page":"User guide","title":"WeaklySeparatedCollections.WSCollection","text":"WSCollection\n\nAn abstract 2-dimensional cell complex living inside the matriod of k-sets in {1, ..., n}.  Its vertices are labelled by elements of labels while quiver encodes adjacencies  between the vertices.  The 2-cells are colored black or white and contained in blackCliques and whiteCliques.\n\nOptionally the 2-cells can be set to missing, to save memory.\n\nAttributes\n\nk::Int\nn::Int\nlabels::Vector{Vector{Int}}\nquiver::SimpleDiGraph{Int}\nwhiteCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} }}\nblackCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} }}\n\nConstructors\n\nWSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)\nWSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, \n                                                          computeCliques::Bool = true)\n\nExamples\n\njulia> labels = rectangle_labels(4, 9)\njulia> WSCollection(4, 9, labels);\n\n\n\n\n\n","category":"type"},{"location":"usage/","page":"User guide","title":"User guide","text":"WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}; computeCliques::Bool = true)","category":"page"},{"location":"usage/#WeaklySeparatedCollections.WSCollection-Tuple{Int64, Int64, Vector{Vector{Int64}}}","page":"User guide","title":"WeaklySeparatedCollections.WSCollection","text":"WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)\n\nConstructor of WSCollection. Adjacencies between its vertices as well as 2-cells are  computed using only a set of vertex labels.\n\nIf computeCliques is set to false, the 2-cells will be set to missing.\n\n\n\n\n\n","category":"method"},{"location":"usage/","page":"User guide","title":"User guide","text":"WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}; computeCliques::Bool = true)","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"To see if two or more k-subsets are weakly separated, we use the function is_weakly_separated.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"is_weakly_separated","category":"page"},{"location":"usage/#WeaklySeparatedCollections.is_weakly_separated","page":"User guide","title":"WeaklySeparatedCollections.is_weakly_separated","text":"is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int})\n\nTest if two vectors v and w viewed as subsets of {1 , ..., n } are weakly separated.\n\nExamples\n\njulia> v = [1,2,3,5,6,9]\njulia> w = [1,2,4,5,7,8]\njulia> is_weakly_separated(9, v, w)\ntrue\n\njulia> v = [1,2,3,5,6,9]\njulia> w = [1,2,3,5,7,8]\njulia> is_weakly_separated(9, v, w)\nfalse\n\n\n\n\n\nis_weakly_separated(n::Int, labels::Vector{Vector{Int}})\n\nTest if the vectors contained in labels are pairwise weakly separated.\n\nExamples\n\njulia> u = [1,2,3,4,5,6]\njulia> v = [1,2,3,5,6,9]\njulia> w = [1,2,3,5,7,8]\njulia> is_weakly_separated(9, [u, v, w])\ntrue\n\n\n\n\n\n","category":"function"},{"location":"usage/#predefined-collections","page":"User guide","title":"predefined collections","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"The labels of some known weakly separated collections are available via","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"rectangle_labels\ncheckboard_labels\ndual_rectangle_labels\ndual_checkboard_labels","category":"page"},{"location":"usage/#WeaklySeparatedCollections.rectangle_labels","page":"User guide","title":"WeaklySeparatedCollections.rectangle_labels","text":"rectangle_labels(k::Int, n::Int)\n\nReturn the labels of the rectangle graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.checkboard_labels","page":"User guide","title":"WeaklySeparatedCollections.checkboard_labels","text":"checkboard_labels(k::Int, n::Int)\n\nReturn the labels of the checkboard graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.dual_rectangle_labels","page":"User guide","title":"WeaklySeparatedCollections.dual_rectangle_labels","text":"dual_rectangle_labels(k::Int, n::Int)\n\nReturn the labels of the dual-rectangle graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.dual_checkboard_labels","page":"User guide","title":"WeaklySeparatedCollections.dual_checkboard_labels","text":"dual_checkboard_labels(k::Int, n::Int)\n\nReturn the labels of the dual-checkboard graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"The above predefined sets of labels give rise to weakly separated collections which are available via","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"checkboard_collection\nrectangle_collection\ndual_checkboard_collection\ndual_rectangle_collection","category":"page"},{"location":"usage/#WeaklySeparatedCollections.checkboard_collection","page":"User guide","title":"WeaklySeparatedCollections.checkboard_collection","text":"checkboard_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the checkboard graph.\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.rectangle_collection","page":"User guide","title":"WeaklySeparatedCollections.rectangle_collection","text":"rectangle_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the rectangle graph.\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.dual_checkboard_collection","page":"User guide","title":"WeaklySeparatedCollections.dual_checkboard_collection","text":"dual_checkboard_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the dual-checkboard graph.\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.dual_rectangle_collection","page":"User guide","title":"WeaklySeparatedCollections.dual_rectangle_collection","text":"dual_rectangle_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the dual-rectangle graph.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"Two WSC's are considered equal if their underlying labels are equal as sets. ","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"Base.:(==)","category":"page"},{"location":"usage/#Base.:==","page":"User guide","title":"Base.:==","text":"(==)(collection1::WSCollection, collection2::WSCollection)\n\nReturn true if the vertices of collection1 and collection2 share the same labels. The order of labels in each collection does not matter.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"WSC's usually contain frozen elements that never change. On the other hand some elements may be modified via mutation and are called mutable. To figure out which elemnents of a WSC are frozen or mutable use the functions is_frozen or is_mutable.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"is_frozen\nis_mutable","category":"page"},{"location":"usage/#WeaklySeparatedCollections.is_frozen","page":"User guide","title":"WeaklySeparatedCollections.is_frozen","text":"is_frozen(collection::WSCollection, i::Int)\n\nReturn true if the vertex i of collection is frozen.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> is_frozen(H, 5)\ntrue\n\njulia> is_frozen(H, 11)\nfalse\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.is_mutable","page":"User guide","title":"WeaklySeparatedCollections.is_mutable","text":"is_mutable(collection::WSCollection, i::Int)\n\nReturn true if the vertex i of collection is mutable. This is the case if it is not frozen and is of degree 4.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> is_mutable(H, 11)\nfalse\n\njulia> is_frozen(H, 10)\ntrue\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"To mutate a WSC, the functions mutateand mutate! are available.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"mutate!\nmutate","category":"page"},{"location":"usage/#WeaklySeparatedCollections.mutate!","page":"User guide","title":"WeaklySeparatedCollections.mutate!","text":"mutate!(collection::WSCollection, i::Int, mutateCliques::Bool = true)\n\nMutate the collection in direction i if i is a mutable vertex of collection.\n\nIf mutateCliques is set to false, the 2-cells are set to missing.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> mutate!(H, 10)\n\n\n\n\n\nmutate!(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)\n\nMutate the collection by addressing a vertex with its label.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> H.labels[10]\n4-element Vector{Int64}:\n 2\n 7\n 8\n 9\n\njulia> mutate!(H, [2,7,8,9])\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.mutate","page":"User guide","title":"WeaklySeparatedCollections.mutate","text":"mutate(collection::WSCollection, i::Int, mutateCliques::Bool = true)\n\nVersion of mutate! that does not modify its arguments.\n\n\n\n\n\nmutate(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)\n\nMutate the collection by addressing a vertex with its label, without modifying arguments.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"Apart from mutation, several other transformations of WSC's are available:","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"rotate!\nrotate","category":"page"},{"location":"usage/#WeaklySeparatedCollections.rotate!","page":"User guide","title":"WeaklySeparatedCollections.rotate!","text":"rotate!(collection::WSCollection, amount::Int)\n\nRotate collection by amount, where a positive amount indicates a clockwise rotation.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> rotate!(H, 2)\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.rotate","page":"User guide","title":"WeaklySeparatedCollections.rotate","text":"rotate(collection::WSCollection, amount::Int)\n\nVersion of rotate! that does not modify its argument. \n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"reflect!\nreflect","category":"page"},{"location":"usage/#WeaklySeparatedCollections.reflect!","page":"User guide","title":"WeaklySeparatedCollections.reflect!","text":"reflect!(collection::WSCollection, axis::Int = 1)\n\nReflect collection by letting the permutation x ↦ 2*axis -x interpreted modulo  n = collection.n act on the labels of collection.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> reflect!(H, 1)\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.reflect","page":"User guide","title":"WeaklySeparatedCollections.reflect","text":"reflect(collection::WSCollection, axis::Int = 1)\n\nVersion of reflect! that does not modify its argument.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"complement!\ncomplement","category":"page"},{"location":"usage/#WeaklySeparatedCollections.complement!","page":"User guide","title":"WeaklySeparatedCollections.complement!","text":"complement!(collection::WSCollection)\n\nReturn the collection whose labels are complementary to those of collection.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> complement!(H)\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.complement","page":"User guide","title":"WeaklySeparatedCollections.complement","text":"complement(collection::WSCollection)\n\nVersion of complement! that does not modify its argument.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"swap_colors!\nswap_colors","category":"page"},{"location":"usage/#WeaklySeparatedCollections.swap_colors!","page":"User guide","title":"WeaklySeparatedCollections.swap_colors!","text":"swap_colors!(collection::WSCollection)\n\nReturn the weakly separated collection whose corresponding plabic graph is obtained from the one of collection by swapping the colors black and white.\n\nThis is the same as taking complements and rotating by collection.k.\n\nExamples\n\njulia> H = rectangle_collection(4, 9)\njulia> swap_colors!(H)\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.swap_colors","page":"User guide","title":"WeaklySeparatedCollections.swap_colors","text":"swap_colors(collection::WSCollection)\n\nVersion of swap_colors! that does not modify its argument.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"We often want to deal with maximal WSC's instead of their subsets. To extend a given WSC to a maximal one, the following functions may be used:","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"extend_weakly_separated!\nextend_to_collection","category":"page"},{"location":"usage/#WeaklySeparatedCollections.extend_weakly_separated!","page":"User guide","title":"WeaklySeparatedCollections.extend_weakly_separated!","text":"extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{Int}})\n\nExtend labels to contain the labels of a maximal weakly separated collection.\n\nExamples\n\njulia> labels = [[1,3,5,7], [1,3,5,9]]\njulia> extend_weakly_separated!(4, 9, labels)\n\n\n\n\n\nextend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{Int}}, \n                                         labels2::Vector{Vector{Int}})\n\nExtend labels1 to contain the labels of a maximal weakly separated collection. Use elements of labels2 if possible.\n\nExamples\n\njulia> labels1 = [[1,3,5,7], [1,3,5,9]]\njulia> labels2 = checkboard_labels(4, 9)\njulia> extend_weakly_separated!(4, 9, labels1, labels2)\n\n\n\n\n\nextend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)\n\nExtend labels to contain the labels of a maximal weakly separated collection. Use labels of collection if possible.\n\nExamples\n\njulia> labels = [[1,3,5,7], [1,3,5,9]]\njulia> H = checkboard_collection(4, 9)\njulia> extend_weakly_separated!(labels, H)\n\n\n\n\n\n","category":"function"},{"location":"usage/#WeaklySeparatedCollections.extend_to_collection","page":"User guide","title":"WeaklySeparatedCollections.extend_to_collection","text":"extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})\n\nReturn a maximal weakly separated collection containing all elements of labels.\n\nExamples\n\njulia> labels = [[1,3,5,7], [1,3,5,9]]\njulia> extend_to_collection(4, 9, labels)\n\n\n\n\n\nextend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, \n                                     labels2::Vector{Vector{Int}})\n\nReturn a maximal weakly separated collection containing all elements of labels1. Use elements of labels2 if possible.\n\nExamples\n\njulia> labels1 = [[1,3,5,7], [1,3,5,9]]\njulia> labels2 = checkboard_labels(4, 9)\njulia> extend_to_collection(4, 9, labels1, labels2)\n\n\n\n\n\nextend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)\n\nReturn a maximal weakly separated collection containing all elements of labels. Use labels of collection if possible.\n\nExamples\n\njulia> labels = [[1,3,5,7], [1,3,5,9]]\njulia> H = checkboard_collection(4, 9)\njulia> extend_to_collection(labels, H)\n\n\n\n\n\n","category":"function"},{"location":"usage/#Plotting","page":"User guide","title":"Plotting","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"Plotting WSC's requires Luxor to be installed and loaded as detailed here.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"In the introduction we learned about plabic tilings as well as plabic graphs as objects living in the plane which are in one to one correspndance to maximal WSC's. Thus we can plot a maximal WSC using its corresponding plabic tiling or plabic graph. The functions to accomplish this are:","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"drawTiling","category":"page"},{"location":"usage/#WeaklySeparatedCollections.drawTiling","page":"User guide","title":"WeaklySeparatedCollections.drawTiling","text":"drawTiling(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)\n\nDraw the plabic tiling of the provided weakly separated collection and save it as an  image file of specified size.  Both the name as well as the resulting file type of the image are controlled via title.\n\nInside a Jupyter sheet drawing without saving an image is possible by omitting the title argument i.e. via drawTiling(collection::WSCollection, width::Int = 500, height::Int = 500).\n\nKeyword Arguments\n\ntopLabel = nothing\nbackgroundColor::Union{String, ColorTypes.Colorant} = \"\"\ndrawLabels::Bool = true\nhighlightMutables::Bool = true\nlabelDirection = \"left\"\n\ntoplabel controls the rotation of the drawing by drawing the specified label at the top. labelDirection controls whether the \"left\" (i.e. the usual ones) or \"right\" (complements) labels are drawn.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"drawPLG","category":"page"},{"location":"usage/#WeaklySeparatedCollections.drawPLG","page":"User guide","title":"WeaklySeparatedCollections.drawPLG","text":"drawPLG(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)\n\nDraw the plabic graph of the provided weakly separated collection and save it as an  image file of specified size. Both the name as well as the resulting file type of the image are controlled via title.\n\nInside a Jupyter sheet drawing without saving an image is possible by omitting the title argument i.e. via drawPLG(collection::WSCollection, width::Int = 500, height::Int = 500). \n\nKeyword Arguments\n\ntopLabel = nothing\ndrawmode::String = \"straight\"\nbackgroundColor::Union{String, ColorTypes.Colorant} = \"\"\ndrawLabels::Bool = true\nhighlightMutables::Bool = false\nlabelDirection = \"left\"\n\ntoplabel controls the rotation of the drawing by drawing the specified label at the top. drawmode controls how edges are drawn and may be choosen as \"straight\", \"smooth\" or \"polygonal\". labelDirection controls whether the \"left\" (i.e. the usual ones) or \"right\" (complements) labels  are drawn.\n\n\n\n\n\n","category":"function"},{"location":"usage/#Graphical-user-interface","page":"User guide","title":"Graphical user interface","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"This section is work in progress.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"The graphical user interface requires both an installation of Luxor as well as Mousetrap. See here for details.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"While plotting WSC's enables us to visualize them, the resulting images lack interactivity. This is where the built in gui application comes in handy. To start it we use","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"visualizer!","category":"page"},{"location":"usage/#WeaklySeparatedCollections.visualizer!","page":"User guide","title":"WeaklySeparatedCollections.visualizer!","text":"visualizer!(collection::WSCollection = rectangle_collection(4, 9))\n\nStart the graphical user interface to visualize the provided collection.\n\n\n\n\n\n","category":"function"},{"location":"usage/","page":"User guide","title":"User guide","text":"TODO:","category":"page"},{"location":"usage/#settings","page":"User guide","title":"settings","text":"","category":"section"},{"location":"usage/","page":"User guide","title":"User guide","text":"explain the non obvious options (or all) here.","category":"page"},{"location":"usage/","page":"User guide","title":"User guide","text":"adjust drawing angle: If checked, the embeddings of the plabic graph (and tiling) will be rotated such that the boundary vertex 1 is drawn at a more consistant position.","category":"page"},{"location":"usage/#file:-saving,-loading,-export","page":"User guide","title":"file: saving, loading, export","text":"","category":"section"},{"location":"usage/#edit","page":"User guide","title":"edit","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"TODO: insert references to literature here.","category":"page"},{"location":"#WeaklySeparatedCollections","page":"Home","title":"WeaklySeparatedCollections","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"In its core, this package implements the combinatorics of weakly separated collections. It also provides optional tools for plotting as well an intuitive graphical user interface.","category":"page"},{"location":"#How-to-install","page":"Home","title":"How to install","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is divided into severaral parts. The base package implements only the combinatorics while several optional extensions can be loaded to enable additional features such as plotting.","category":"page"},{"location":"","page":"Home","title":"Home","text":"To install the package execute the following in the Julia REPL:","category":"page"},{"location":"","page":"Home","title":"Home","text":"import Pkg;\nPkg.add(url=\"https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"The package may then be used as usual via","category":"page"},{"location":"","page":"Home","title":"Home","text":"using WeaklySeparatedCollections","category":"page"},{"location":"#Extensions","page":"Home","title":"Extensions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To enable extensions Julia v1.9 or newer, as well as some additional packages need to be installed.","category":"page"},{"location":"#Plotting","page":"Home","title":"Plotting","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To use this feature, Luxor needs to be installed. In the Julia REPL simply execute:","category":"page"},{"location":"","page":"Home","title":"Home","text":"import Pkg;\nPkg.add(\"Luxor\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Now load both WeaklySeparatedCollections and Luxor to activate the plotting extension:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using WeaklySeparatedCollections\nimport Luxor ","category":"page"},{"location":"#GUI","page":"Home","title":"GUI","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To use the graphical user interface, Luxor and Mousetrap are required. Installing Luxor is explained in the previous section. To install Mousetrap run:","category":"page"},{"location":"","page":"Home","title":"Home","text":"import Pkg;\nPkg.add(url=\"https://github.com/clemapfel/mousetrap.jl\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Now loading all of WeaklySeparatedCollections, Luxor and Mousetrap will activate the gui extension.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using WeaklySeparatedCollections\nimport Luxor\nimport Mousetrap","category":"page"}]
}

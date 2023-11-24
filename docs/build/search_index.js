var documenterSearchIndex = {"docs":
[{"location":"#WeaklySeparatedCollections.jl-Documentation","page":"Home","title":"WeaklySeparatedCollections.jl Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Hier könnte eine eloquente Einleitung stehen.","category":"page"},{"location":"","page":"Home","title":"Home","text":"is_weakly_separated","category":"page"},{"location":"#WeaklySeparatedCollections.is_weakly_separated","page":"Home","title":"WeaklySeparatedCollections.is_weakly_separated","text":"is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int})\n\nTest if two vectors v and w viewed as subsets of {1 , ..., n } are weakly separated.\n\n\n\n\n\nis_weakly_separated(n::Int, labels::Vector{Vector{Int}})\n\nTest if the vectors contained in labels are pairwise weakly separated.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"rectangle_labels\ncheckboard_labels\ndual_rectangle_labels\ndual_checkboard_labels","category":"page"},{"location":"#WeaklySeparatedCollections.rectangle_labels","page":"Home","title":"WeaklySeparatedCollections.rectangle_labels","text":"rectangle_labels(k::Int, n::Int)\n\nReturn the labels of the rectangle graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.checkboard_labels","page":"Home","title":"WeaklySeparatedCollections.checkboard_labels","text":"checkboard_labels(k::Int, n::Int)\n\nReturn the labels of the checkboard graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.dual_rectangle_labels","page":"Home","title":"WeaklySeparatedCollections.dual_rectangle_labels","text":"dual_rectangle_labels(k::Int, n::Int)\n\nReturn the labels of the dual-rectangle graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.dual_checkboard_labels","page":"Home","title":"WeaklySeparatedCollections.dual_checkboard_labels","text":"dual_checkboard_labels(k::Int, n::Int)\n\nReturn the labels of the dual-checkboard graph as a vector.  The frozen labels are in positions 1 to n.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"WSCollection","category":"page"},{"location":"#WeaklySeparatedCollections.WSCollection","page":"Home","title":"WeaklySeparatedCollections.WSCollection","text":"WSCollection\n\nAn abstract 2-dimensional cell complex living inside the matriod of k-sets in {1, ..., n}.  Its vertices are labelled by elements of labels while quiver encodes adjacencies  between the vertices.  The 2-cells are colored black or white and contained in blackCliques and whiteCliques.\n\nOptionally the 2-cells can be set to missing, to save memory.\n\nAttributes\n\nk::Int\nn::Int\nlabels::Vector{Vector{Int}}\nquiver::SimpleDiGraph{Int}\nwhiteCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }\nblackCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }\n\nConstructors\n\nWSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)\nWSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, computeCliques::Bool = true)\n\n\n\n\n\n","category":"type"},{"location":"","page":"Home","title":"Home","text":"isequal\nBase.:(==)","category":"page"},{"location":"#Base.isequal","page":"Home","title":"Base.isequal","text":"isequal(collection1::WSCollection, collection2::WSCollection)\n\nReturn true if the vertices of collection1 and collection2 share the same labels. The order of labels in each collection does not matter.\n\n\n\n\n\n","category":"function"},{"location":"#Base.:==","page":"Home","title":"Base.:==","text":"(==)(collection1::WSCollection, collection2::WSCollection)\n\nReturn true if the vertices of collection1 and collection2 share the same labels. The order of labels in each collection does not matter.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"is_frozen\nis_mutable","category":"page"},{"location":"#WeaklySeparatedCollections.is_frozen","page":"Home","title":"WeaklySeparatedCollections.is_frozen","text":"is_frozen(collection::WSCollection, i::Int)\n\nReturn true if the vertex i of collection is frozen.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.is_mutable","page":"Home","title":"WeaklySeparatedCollections.is_mutable","text":"is_mutable(collection::WSCollection, i::Int)\n\nReturn true if the vertex i of collection is mutable. This is the case if it is not frozen and is of degree 4.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"mutate!\nmutate","category":"page"},{"location":"#WeaklySeparatedCollections.mutate!","page":"Home","title":"WeaklySeparatedCollections.mutate!","text":"mutate!(collection::WSCollection, i::Int, mutateCliques::Bool = true)\n\nMutate the collection in direction i if i is a mutable vertex of collection.\n\nIf mutateCliques is set to false, the 2-cells are set to missing.\n\n\n\n\n\nmutate!(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)\n\nMutate the collection by addressing a vertex with its label.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.mutate","page":"Home","title":"WeaklySeparatedCollections.mutate","text":"mutate(collection::WSCollection, i::Int, mutateCliques::Bool = true)\n\nVersion of mutate! that does not modify its arguments.\n\n\n\n\n\nmutate(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)\n\nMutate the collection by addressing a vertex with its label, without modifying arguments.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"checkboard_collection\nrectangle_collection\ndual_checkboard_collection\ndual_rectangle_collection","category":"page"},{"location":"#WeaklySeparatedCollections.checkboard_collection","page":"Home","title":"WeaklySeparatedCollections.checkboard_collection","text":"checkboard_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the checkboard graph.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.rectangle_collection","page":"Home","title":"WeaklySeparatedCollections.rectangle_collection","text":"rectangle_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the rectangle graph.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.dual_checkboard_collection","page":"Home","title":"WeaklySeparatedCollections.dual_checkboard_collection","text":"dual_checkboard_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the dual-checkboard graph.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.dual_rectangle_collection","page":"Home","title":"WeaklySeparatedCollections.dual_rectangle_collection","text":"dual_rectangle_collection(k::Int, n::Int)\n\nReturn the weakly separated collection corresponding to the dual-rectangle graph.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"rotate_collection!\nrotate_collection","category":"page"},{"location":"#WeaklySeparatedCollections.rotate_collection!","page":"Home","title":"WeaklySeparatedCollections.rotate_collection!","text":"rotate_collection!(collection::WSCollection, amount::Int)\n\nRotate collection by amount, where a positive amount indicates a clockwise rotation. \n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.rotate_collection","page":"Home","title":"WeaklySeparatedCollections.rotate_collection","text":"rotate_collection(collection::WSCollection, amount::Int)\n\nVersion of rotate_collection! that does not modify its argument. \n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"reflect_collection!\nreflect_collection","category":"page"},{"location":"#WeaklySeparatedCollections.reflect_collection!","page":"Home","title":"WeaklySeparatedCollections.reflect_collection!","text":"reflect_collection!(collection::WSCollection, axis::Int = 1)\n\nReflect collection by letting the permutation x ↦ 2*axis -x interpreted modulo  n = collection.n act on the labels of collection. \n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.reflect_collection","page":"Home","title":"WeaklySeparatedCollections.reflect_collection","text":"reflect_collection(collection::WSCollection, axis::Int = 1)\n\nVersion of reflect_collection! that does not modify its argument.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"complement_collection!\ncomplement_collection","category":"page"},{"location":"#WeaklySeparatedCollections.complement_collection!","page":"Home","title":"WeaklySeparatedCollections.complement_collection!","text":"complement_collection!(collection::WSCollection)\n\nReturn the collection whose labels are complementary to those of collection.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.complement_collection","page":"Home","title":"WeaklySeparatedCollections.complement_collection","text":"complement_collection(collection::WSCollection)\n\nVersion of complement_collection! that does not modify its argument.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"swaped_colors_collection!\nswaped_colors_collection","category":"page"},{"location":"#WeaklySeparatedCollections.swaped_colors_collection!","page":"Home","title":"WeaklySeparatedCollections.swaped_colors_collection!","text":"swaped_colors_collection!(collection::WSCollection)\n\nReturn the weakly separated collection whose corresponding plabic graph is obtained from the one of collection by swapping the colors black and white.\n\nThis is the same as taking complements and rotating by collection.k.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.swaped_colors_collection","page":"Home","title":"WeaklySeparatedCollections.swaped_colors_collection","text":"swaped_colors_collection(collection::WSCollection)\n\nVersion of swaped_colors_collection! that does not modify its argument.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"extend_weakly_separated!\nextend_to_collection","category":"page"},{"location":"#WeaklySeparatedCollections.extend_weakly_separated!","page":"Home","title":"WeaklySeparatedCollections.extend_weakly_separated!","text":"extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{Int}})\n\nExtend labels to contain the labels of a maximal weakly separated collection.\n\n\n\n\n\nextend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})\n\nExtend labels1 to contain the labels of a maximal weakly separated collection. Use elements of labels2 if possible.\n\n\n\n\n\nextend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)\n\nExtend labels to contain the labels of a maximal weakly separated collection. Use labels of collection if possible.\n\n\n\n\n\n","category":"function"},{"location":"#WeaklySeparatedCollections.extend_to_collection","page":"Home","title":"WeaklySeparatedCollections.extend_to_collection","text":"extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})\n\nReturn a maximal weakly separated collection containing all elements of labels.\n\n\n\n\n\nextend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})\n\nReturn a maximal weakly separated collection containing all elements of labels1. Use elements of labels2 if possible.\n\n\n\n\n\nextend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)\n\nReturn a maximal weakly separated collection containing all elements of labels. Use labels of collection if possible.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"TODO","category":"page"},{"location":"","page":"Home","title":"Home","text":"computecliques, computeadjacencies, computeboundaries, superpotential_labels","category":"page"}]
}

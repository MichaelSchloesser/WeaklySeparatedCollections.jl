using WeaklySeparatedCollections
import WeaklySeparatedCollections as WSC
using Test


@testset "WeaklySeparatedCollections.jl" begin

    ######## temporary ########
        



    ######## Combinatorics ########
    
    @test begin
        "is_weakly_separated, false example"
        
        v = [1,2,3,5,6,9]
        w = [1,2,4,5,7,8]
        is_weakly_separated(9, v, w) == false
    end

    @test begin
        "is_weakly_separated, true example"

        v = [1,2,3,5,6,9]
        w = [1,2,3,5,7,8]
        is_weakly_separated(9, v, w) == true
    end

    
    @test begin
        "checkboard_labels return type"

        labels = checkboard_labels(4, 9)
        typeof(labels) == Vector{Vector{Int}}
    end

    
    @test begin
        "is_weakly_separated for rectangle_labels"

        labels = rectangle_labels(4, 9)
        is_weakly_separated(9, labels)
    end


    @test begin
        "is_weakly_separated for dual_checkboard_labels"

        labels = dual_checkboard_labels(4, 9)
        is_weakly_separated(9, labels)
    end


    @test begin
        "is_weakly_separated for dual_rectangle_labels"

        labels = dual_rectangle_labels(4, 9)
        is_weakly_separated(9, labels)
    end


    @test begin
        "is_weakly_separated for checkboard_labels"

        labels = checkboard_labels(4, 9)
        is_weakly_separated(9, labels)
    end

    
    @test begin
        "compute_cliques from labels"

        labels = checkboard_labels(4, 9)
        WeaklySeparatedCollections.compute_cliques(labels)
        true
    end

    
    @test begin
        "compute_adjacencies from labels"

        labels = checkboard_labels(4, 9)
        WeaklySeparatedCollections.compute_adjacencies(4, 9, labels)
        true
    end

    
    @test begin
        "compute_cliques using quiver"

        check = checkboard_collection(4, 9)
        labels = check.labels
        quiver = check.quiver
        W, B = WeaklySeparatedCollections.compute_cliques(labels, quiver)
        W2, B2 = WeaklySeparatedCollections.compute_cliques(labels)

        (W == W2) && (B == B2) 
    end

    
    @test begin
        "compute_boundaries"

        check = checkboard_collection(4, 9)
        labels = check.labels
        quiver = check.quiver

        W, B = WeaklySeparatedCollections.compute_boundaries(labels, quiver)
        _, W2, B2 = WeaklySeparatedCollections.compute_adjacencies(4, 9, labels)
        (W == W2) && (B == B2)
    end

    
    @test begin
        "WSCollection constructors from labels"

        labels = checkboard_labels(4, 9)
        WSCollection(4, 9, labels)
        WSCollection(4, 9, labels; computeCliques =  false)

        true
    end

    
    @test begin
        "WSCollection constructor using quiver"

        labels = checkboard_collection(4, 9).labels
        quiver = checkboard_collection(4, 9).quiver
        WSCollection(4, 9, labels, quiver)
        WSCollection(4, 9, labels, quiver; computeCliques =  false)

        true
    end

    
    @test begin
        "checkboard_collection"

        checkboard_collection(4, 9)
        true
    end

    
    @test begin
        "rectangle_collection"

        rectangle_collection(4, 9)
        true
    end

    
    @test begin
        "dual_rectangle_collection"
        
        drec1 = dual_rectangle_collection(4, 9)
        drec2 = complement(rectangle_collection(5, 9))

        drec1 == drec2
    end

    
    @test begin
        "dual_checkboard_collection"

        dcheck1 = dual_checkboard_collection(4, 9)
        dcheck2 = complement(checkboard_collection(5, 9))

        dcheck1 == dcheck2
    end

    
    @test begin
        "isequal, false example"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        isequal(check, rec) == false
    end
    

    @test begin
        "isequal, true example"

        check = checkboard_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = checkboard_collection(4, 9)

        isequal(check, check2) 
    end

    
    @test begin
        "overload Base.:(==) , false example"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        (check == rec) == false
    end


    @test begin
        "overload Base.:(==) , true example"

        check = checkboard_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = checkboard_collection(4, 9)

        check == check2
    end

    
    @test begin
        "overload Base.:(!=) , true example"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        check != rec
    end


    @test begin
        "overload Base.:(!=) , false example"

        check = checkboard_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = checkboard_collection(4, 9)

        (check != check2) == false
    end


    @test begin
        "getindex: collection"

        check = checkboard_collection(4, 9)
        check[10] == check.labels[10]
    end
    

    @test begin
        "setindex!: collection"

        check = checkboard_collection(4, 9)
        check[10] = check.labels[11]

        true
    end


    @test begin
        "label in collection, true example"

        check = checkboard_collection(4, 9)
        check[10] in check
    end


    @test begin
        "label in collection, false example"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)
        check[10] in rec
    end

    
    @test begin
        "length: collection"

        check = checkboard_collection(4, 9)
        length(check) == 21
    end


    @test begin
        "cliques missing, true example"

        check = WSCollection(checkboard_collection(4, 9), computeCliques = false)
        cliques_missing(check)
    end


    @test begin
        "cliques missing, false example"

        check = checkboard_collection(4, 9)
        !cliques_missing(check)
    end


    @test begin
        "intersect: collection"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)
        
        intersect(check, rec)
        true
    end


    @test begin
        "setdiff: collection"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)
        
        setdiff(check, rec)
        true
    end


    @test begin
        "union: collection"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)
        
        union(check, rec)
        true
    end


    @test begin
        "print, println"

        check = checkboard_collection(4, 9)
        print(check)
        println(check)
        print(check, full = true)
        println(check, full = true)

        true
    end


    @test begin
        "is_frozen"

        check = checkboard_collection(4, 9)
        is_frozen(check, 1) && is_frozen(check, 9) && !is_frozen(check, 10)
    end

    
    @test begin
        "is_mutable"

        rec = rectangle_collection(4, 9)
        !is_mutable(rec, 1) && is_mutable(rec, 10) && !is_mutable(rec, 11)
    end


    @test begin
        "get_mutables"

        check = checkboard_collection(4, 9)
        get_mutables(check) == check[10:end]
    end

    
    @test begin
        "mutate! and mutate"

        check = checkboard_collection(4, 9)
        mutate!(check, 10)
        mutate(check, 13)
        true
    end

    
    @test begin
        "rotate"

        rec = rectangle_collection(4, 9)
        rotate(rec, 1)
        rotate(rec, 5)
        true
    end

    
    @test begin
        "reflect"

        rec = rectangle_collection(4, 9)
        reflect(rec, 1)
        reflect(rec, 4)
        true
    end

    
    @test begin
        "complement"

        rec = rectangle_collection(4, 9)
        complement(rec)
        true
    end

    
    @test begin 
        "swap_colors"

        rec = rectangle_collection(4, 9)
        swap_colors(rec)
        true
    end


    @test begin 
        "extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{Int}})"

        label = [3,5,6]
        extend_weakly_separated!(3, 6, [label])
        true
    end


    @test begin 
        "extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})"

        label = [3,5,6]
        rec_labels = rectangle_labels(3, 6)
        extend_weakly_separated!(3, 6, [label], rec_labels)
        true
    end

    
    @test begin 
        "extend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)"

        label = [3,5,6]
        rec = rectangle_collection(3, 6)
        extend_weakly_separated!(3, 6, [label], rec)
        true
    end


    @test begin 
        "extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})"

        label = [3,5,6]
        extend_to_collection(3, 6, [label])
        true
    end


    @test begin 
        "extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})"

        label = [3,5,6]
        rec_labels = rectangle_labels(3, 6)
        extend_to_collection(3, 6, [label], rec_labels)
        true
    end


    @test begin 
        "extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})"

        label = [3,5,6]
        rec_labels = rectangle_labels(3, 6)
        extend_to_collection(3, 6, [label], rec_labels)
        true
    end
    

    @test begin 
        "extend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)"

        label = [3,5,6]
        rec = rectangle_collection(3, 6)
        extend_to_collection(3, 6, [label], rec)
        true
    end


    ######## Searching ########

    @test begin 
        "BFS"

        check = checkboard_collection(3, 6)
        rec = rectangle_collection(3, 6)
        BFS(check, rec)
        
        true
    end


    @test begin 
        "BFS with limited search space"

        check = checkboard_collection(3, 6)
        rec = rectangle_collection(3, 6)
        BFS(check, rec, limitSearchSpace = true)
        
        true
    end


    @test begin 
        "DFS"

        check = checkboard_collection(3, 6)
        rec = rectangle_collection(3, 6)
        DFS(check, rec)
        
        true
    end


    @test begin 
        "DFS with limited search space"

        check = checkboard_collection(3, 6)
        rec = rectangle_collection(3, 6)
        DFS(check, rec, limitSearchSpace = true)
        
        true
    end
    

    @test begin 
        "generalized_associahedron"

        check = checkboard_collection(3, 6)
        generalized_associahedron(check)
        generalized_associahedron(3, 6)
        
        true
    end


    @test begin 
        "diff_len"

        function old_diff_len(w, x)
            d = 0
    
            for a in w
                d = d + !(a in x)
            end

            return d
        end

        w = [24,625,3,21,76,34,76,2,1,8]
        x = [4,38,76,2,9,0,1,12,3,22,14]

        WSC.diff_len(w, x) == old_diff_len(w, x)
    end


    @test begin 
        "number_wrong_labels"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        number_wrong_labels(check, rec)
        true
    end


    @test begin 
        "min_label_dist(collection::WSCollection, target::WSCollection)"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        min_label_dist(check, rec)
        true
    end


    @test begin 
        "min_label_dist_experimental(collection::WSCollection, target::WSCollection)"

        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        min_label_dist_experimental(check, rec)
        true
    end


    @test begin 
        "Astar"

        check = checkboard_collection(3, 7)
        rec = rectangle_collection(3, 7)

        Astar(check, rec)
        true
    end


    @test begin 
        "find_label"

        check = checkboard_collection(4, 9)
        
        label = WSC.super_potential_label(4, 9, 3)

        find_label(check, rec)
        true
    end
    

    ######## Oscar ########

    using Oscar

    @test begin 
        "Seed: constructors"

        Q = rectangle_collection(4, 9).quiver 
        R, _ = polynomial_ring(ZZ, 21)
        S = fraction_field(R)
        Seed(9, gens(S), Q)
        
        Q = rectangle_collection(4, 9).quiver 
        Seed(21, 9, Q)
        
        Seed(rectangle_collection(4, 9)) 

        true
    end


    @test begin 
        "Seed: getindex"

        s = Seed(rectangle_collection(4, 9)) 
        s[10] == s.variables[10]
    end


    @test begin 
        "Seed: setindex!"

        s = Seed(rectangle_collection(4, 9)) 
        s[10] = s[11]

        s[10] == s[11]
    end


    @test begin 
        "Seed: is_frozen, true example"

        s = Seed(rectangle_collection(4, 9)) 
        is_frozen(s, 1)
    end


    @test begin 
        "Seed: is_frozen, false example"

        s = Seed(rectangle_collection(4, 9)) 
        !is_frozen(s, 11)
    end


    @test begin 
        "Seed: length"

        s = Seed(rectangle_collection(4, 9)) 
        length(s) == 21
    end


    @test begin 
        "grid_Seed"

        Q = rectangle_collection(4, 9).quiver
        grid_Seed(9, 5, 4, Q)
        grid_Seed(rectangle_collection(4, 9))
        grid_Seed(rectangle_collection(4, 9), 4, 5) 

        true
    end


    @test begin 
        "extended_checkboard_seed"

        extended_checkboard_seed(3, 6)
        true
    end


    @test begin 
        "extended_rectangle_seed"

        extended_rectangle_seed(3, 6)
        true
    end


    @test begin 
        "extended_rectangle_seed"

        get_superpotential_terms(checkboard_collection(3, 6))
        true
    end


    @test begin 
        "checkboard_potential_terms"

        T1 = get_superpotential_terms(checkboard_collection(3, 6))
        T2 = checkboard_potential_terms(3, 6)
        T1 == T2
    end


    @test begin 
        "newton_okounkov_inequalities"

        newton_okounkov_inequalities(checkboard_collection(3, 6))
        true
    end


    @test begin 
        "checkboard_inequalities"

        A1, b1 = newton_okounkov_inequalities(checkboard_collection(3, 6))
        A2, b2 = checkboard_inequalities(3, 6)

        (A1 == A2) && (b1 == b2)
    end


    @test begin 
        "newton_okounkov_body"

        newton_okounkov_body(checkboard_collection(3, 6))
        true
    end


    @test begin 
        "checkboard_body"

        N1 = newton_okounkov_body(checkboard_collection(3, 6))
        N2 = checkboard_body(3, 6)
        N1 == N2
    end

    ######## Action of D_n ########

    @test begin
        "dihedral_perm_group"

        dihedral_perm_group(5)
        true
    end


    @test begin
        "cyclic_perm_group"

        cyclic_perm_group(5)
        true
    end


    @test begin
        "Base.:^"

        s, t = gens(dihedral_perm_group(6))
        check = checkboard_collection(3, 6)

        (check^s)^t == check^(s*t)
    end

    @test begin
        "gset"

        D = dihedral_perm_group(6)
        check = checkboard_collection(3, 6)

        gset(D, [check])
        true
    end


    @test begin
        "orbit"

        D = dihedral_perm_group(6)
        check = checkboard_collection(3, 6)

        M = gset(D, [check])
        
        (orbit(M, check) == orbit(D, check) ) && (orbit(M, check) == orbit(check) )
    end


    @test begin
        "stabilizer"

        D = dihedral_perm_group(6)
        check = checkboard_collection(3, 6)

        (stabilizer(D, check) == stabilizer(check) )
    end

    ######## Plotting ########

    import Luxor
    
    @test begin # drawTiling
        G = checkboard_collection(4, 9)
        drawTiling(G, "test_1.png", 500, 500)
        true
    end

    
    @test begin # drawPLG_poly
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_2.png", 500, 500; drawmode = "polygonal")
        true
    end

    
    @test begin # drawPLG_straight
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_3.png", 500, 500; drawmode = "straight")
        true
    end

    
    @test begin # drawPLG_smooth
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_4.png", 500, 500; drawmode = "smooth")
        true
    end

    
    @test begin # backgroundColor via named colors
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_5.png", 500, 500; backgroundColor = "purple")
        true
    end

     
    using Colors 
    @test begin # backgroundColor via RGBA value. fails without using Colors
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_6.png", 500, 500; backgroundColor = RGBA(1.0, 1.0, 1.0, 0.4))
        true
    end

    ######## Gui ########

    # using Mousetrap

    # @test begin
    #     check = checkboard_collection(4, 9)
    #     visualizer!(check)
    #     true
    # end

end

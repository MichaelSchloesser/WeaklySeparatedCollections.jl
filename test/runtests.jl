using WeaklySeparatedCollections
import WeaklySeparatedCollections as WSC
using Test


@testset "WeaklySeparatedCollections.jl" begin

    ######## temporary ########
        
    label_to_string, label_to_array, label


    ######## Combinatorics ########
    
    @test begin
        "label"
        
        v = [1,2,3,5,6,9]
        label(v) == 311
    end

    @test begin
        "is_weakly_separated, false example"
        
        v = label([1,2,3,5,6,9])
        w = label([1,2,4,5,7,8])

        is_weakly_separated(v, w) == false
    end

    @test begin
        "is_weakly_separated, true example"

        v = label([1,2,3,5,6,9])
        w = label([1,2,3,5,7,8])
        is_weakly_separated(v, w) == true
    end


    @test begin
        "is_weakly_separated for rec_labels"

        labels = rec_labels(4, 9)
        is_weakly_separated(labels)
    end


    @test begin
        "is_weakly_separated for dcheck_labels"

        labels = dcheck_labels(4, 9)
        is_weakly_separated(labels)
    end


    @test begin
        "is_weakly_separated for drec_labels"

        labels = drec_labels(4, 9)
        is_weakly_separated(labels)
    end


    @test begin
        "is_weakly_separated for check_labels"

        labels = check_labels(4, 9)
        is_weakly_separated(labels)
    end

    
    @test begin
        "compute_cliques from labels"

        labels = check_labels(4, 9)
        WSC.compute_cliques(labels)
        true
    end

    @test begin
        "compute_quiver from labels & whiteCliques"

        labels = check_labels(4, 9)
        W, _ = WSC.compute_cliques(labels)
        WSC.compute_quiver(9, labels, W)

        true
    end

    @test begin
        "compute_cliques from labels and quiver"

        labels = check_labels(4, 9)
        W, _ = WSC.compute_cliques(labels)
        quiver = WSC.compute_quiver(9, labels, W)
        WSC.compute_cliques(labels, quiver)

        true
    end

    
    @test begin
        "compute_cliques using quiver vs only labels"

        check = check_collection(4, 9)
        labels = check.labels
        quiver = check.quiver
        W, B = WSC.compute_cliques(labels, quiver)
        W2, B2 = WSC.compute_cliques(labels)


        flag1 = issetequal(keys(W), keys(W2))
        if flag1
            for K in keys(W)
                if !issetequal(W[K], W2[K])
                    flag1 = false
                end
            end
        end

        flag2 = issetequal(keys(B), keys(B2))
        if flag2
            for L in keys(B)
                if !issetequal(B[L], B2[L])
                    flag2 = false
                end
            end
        end

        flag1 && flag2 
    end

    
    @test begin
        "WSCollection constructors from labels"

        labels = check_labels(4, 9)
        WSCollection(4, 9, labels)
        WSCollection(4, 9, labels; keepCliques =  false)

        true
    end

    
    @test begin
        "WSCollection constructor using quiver"

        labels = check_collection(4, 9).labels
        quiver = check_collection(4, 9).quiver
        WSCollection(4, 9, labels, quiver)
        WSCollection(4, 9, labels, quiver; keepCliques =  false)

        true
    end

    
    @test begin
        "check_collection"

        check_collection(4, 9)
        true
    end

    
    @test begin
        "rec_collection"

        rec_collection(4, 9)
        true
    end

    
    @test begin
        "drec_collection"
        
        drec1 = drec_collection(4, 9)
        drec2 = complements(rec_collection(5, 9))

        drec1 == drec2
    end

    
    @test begin
        "dcheck_collection"

        dcheck1 = dcheck_collection(4, 9)
        dcheck2 = complements(check_collection(5, 9))

        dcheck1 == dcheck2
    end

    
    @test begin
        "isequal, false example"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)

        isequal(check, rec) == false
    end
    

    @test begin
        "isequal, true example"

        check = check_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = check_collection(4, 9)

        isequal(check, check2) 
    end

    
    @test begin
        "overload Base.:(==) , false example"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)

        (check == rec) == false
    end


    @test begin
        "overload Base.:(==) , true example"

        check = check_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = check_collection(4, 9)

        check == check2
    end

    
    @test begin
        "overload Base.:(!=) , true example"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)

        check != rec
    end


    @test begin
        "overload Base.:(!=) , false example"

        check = check_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = check_collection(4, 9)

        (check != check2) == false
    end


    @test begin
        "getindex: collection"

        check = check_collection(4, 9)
        check[10] == check.labels[10]
    end


    @test begin
        "label in collection, true example"

        check = check_collection(4, 9)
        check[10] in check
    end


    @test begin
        "label in collection, false example"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)
        !(check[10] in rec)
    end

    
    @test begin
        "length: collection"

        check = check_collection(4, 9)
        length(check) == 21
    end


    @test begin
        "cliques_init, true example"

        check = check_collection(4, 9, keepCliques = false)
        cliques_init(check)
    end


    @test begin
        "cliques_init, false example"

        check = check_collection(4, 9)
        !cliques_init(check)
    end


    @test begin
        "intersect: collection"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)
        
        intersect(check, rec)
        true
    end


    @test begin
        "setdiff: collection"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)
        
        setdiff(check, rec)
        true
    end


    @test begin
        "union: collection"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)
        
        union(check, rec)
        true
    end


    @test begin
        "is_frozen"

        check = check_collection(4, 9)
        is_frozen(check, 1) && is_frozen(check, 9) && !is_frozen(check, 10)
    end

    
    @test begin
        "is_mutable"

        rec = rec_collection(4, 9)
        !is_mutable(rec, 1) && is_mutable(rec, 10) && !is_mutable(rec, 11)
    end


    @test begin
        "get_mutables"

        check = check_collection(4, 9)
        get_mutables(check) == collect(10:21)
    end

    # TODO get_mutables!(C::WSCollection, preloaded)
    @test begin
        "get_mutables"

        check = check_collection(4, 9)
        get_mutables(check) == collect(10:21)
    end

    
    @test begin
        "mutate! and mutate"

        check = check_collection(4, 9)
        mutate!(check, 10)
        mutate(check, 13)
        true
    end

    
    @test begin
        "rotate"

        rec = rec_collection(4, 9)
        rotate!(rec, 1)
        rotate(rec, 5)
        true
    end

    
    @test begin
        "mirror"

        rec = rec_collection(4, 9)
        mirror!(rec, 1)
        mirror(rec, 4)
        true
    end

    
    @test begin
        "complements"

        rec = rec_collection(4, 9)
        complements!(rec)
        complements(rec)
        true
    end

    
    @test begin 
        "swap_colors"

        rec = rec_collection(4, 9)
        swap_colors(rec)
        swap_colors!(rec)
        true
    end


    # TODO hier weiter machen
    @test begin 
        "extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{Int}})"

        label = [3,5,6]
        extend_weakly_separated!(3, 6, [label])
        true
    end


    @test begin 
        "extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})"

        label = [3,5,6]
        rec_labels = rec_labels(3, 6)
        extend_weakly_separated!(3, 6, [label], rec_labels)
        true
    end

    
    @test begin 
        "extend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)"

        label = [3,5,6]
        rec = rec_collection(3, 6)
        extend_weakly_separated!([label], rec)
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
        rec_labels = rec_labels(3, 6)
        extend_to_collection(3, 6, [label], rec_labels)
        true
    end


    @test begin 
        "extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})"

        label = [3,5,6]
        rec_labels = rec_labels(3, 6)
        extend_to_collection(3, 6, [label], rec_labels)
        true
    end
    

    @test begin 
        "extend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)"

        label = [3,5,6]
        rec = rec_collection(3, 6)
        extend_to_collection([label], rec)
        true
    end


    ######## Searching ########

    @test begin 
        "BFS"

        check = check_collection(3, 6)
        rec = rec_collection(3, 6)
        seq = BFS(check, rec)

        for m in seq
            mutate!(check, m)
        end

        check == rec
    end


    @test begin 
        "BFS with limited search space"

        check = check_collection(3, 6)
        rec = rec_collection(3, 6)
        seq = BFS(check, rec, limitSearchSpace = true)
        
        for m in seq
            mutate!(check, m)
        end

        check == rec
    end


    @test begin 
        "DFS"

        check = check_collection(3, 6)
        rec = rec_collection(3, 6)
        seq = DFS(check, rec)
        
        for m in seq
            mutate!(check, m)
        end

        check == rec
    end


    @test begin 
        "DFS with limited search space"

        check = check_collection(3, 6)
        rec = rec_collection(3, 6)
        seq = DFS(check, rec, limitSearchSpace = true)
        
        for m in seq
            mutate!(check, m)
        end

        check == rec
    end
    

    @test begin 
        "generalized_associahedron"

        check = check_collection(3, 6)
        generalized_associahedron(check)
        generalized_associahedron(3, 6)
        
        true
    end


    @test begin 
        "setdiff_length"

        function old_diff_len(w, x)
            d = 0
    
            for a in w
                d = d + !(a in x)
            end

            return d
        end

        w = [24,625,3,21,76,34,76,2,1,8]
        x = [4,38,76,2,9,0,1,12,3,22,14]

        WSC.setdiff_length(w, x) == old_diff_len(w, x)
    end


    @test begin 
        "number_wrong_labels"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)

        number_wrong_labels(check, rec)
        true
    end


    @test begin 
        "min_label_dist(collection::WSCollection, target::WSCollection)"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)

        min_label_dist(check, rec)
        true
    end


    @test begin 
        "min_label_dist_experimental(collection::WSCollection, target::WSCollection)"

        check = check_collection(4, 9)
        rec = rec_collection(4, 9)

        min_label_dist_experimental(check, rec)
        true
    end


    @test begin 
        "Astar"

        check = check_collection(3, 7)
        rec = rec_collection(3, 7)
        seq = Astar(check, rec)

        for m in seq
            mutate!(check, m)
        end

        check == rec
    end


    @test begin 
        "find_label"

        check = check_collection(4, 9)
        label = WSC.super_potential_label(4, 9, 3)
        seq = find_label(check, label)

        for m in seq
            mutate!(check, m)
        end

        check[seq[end]] == label
    end
    

    ######## Oscar ########

    using Oscar

    @test begin 
        "Seed: constructors"

        Q = rec_collection(4, 9).quiver 
        R, _ = polynomial_ring(ZZ, 21)
        S = fraction_field(R)
        Seed(9, gens(S), Q)
        
        Q = rec_collection(4, 9).quiver 
        Seed(21, 9, Q)
        
        Seed(rec_collection(4, 9)) 

        true
    end


    @test begin 
        "Seed: getindex"

        s = Seed(rec_collection(4, 9)) 
        s[10] == s.variables[10]
    end


    @test begin 
        "Seed: setindex!"

        s = Seed(rec_collection(4, 9)) 
        s[10] = s[11]

        s[10] == s[11]
    end


    @test begin 
        "Seed: is_frozen, true example"

        s = Seed(rec_collection(4, 9)) 
        is_frozen(s, 1)
    end


    @test begin 
        "Seed: is_frozen, false example"

        s = Seed(rec_collection(4, 9)) 
        !is_frozen(s, 11)
    end


    @test begin 
        "Seed: length"

        s = Seed(rec_collection(4, 9)) 
        length(s) == 21
    end


    @test begin 
        "grid_seed"

        Q = rec_collection(4, 9).quiver
        grid_seed(9, 5, 4, Q)
        grid_seed(rec_collection(4, 9))
        grid_seed(rec_collection(4, 9), 4, 5) 

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
        "checkboard_potential_terms"

        seed, _ = extended_checkboard_seed(3, 6)
        T1 = get_superpotential_terms(check_collection(3, 6), seed)
        T2 = checkboard_potential_terms(3, 6)
        T1 == T2
    end


    @test begin 
        "newton_okounkov_inequalities"

        newton_okounkov_inequalities(check_collection(3, 6))
        true
    end


    @test begin 
        "checkboard_inequalities"

        A1, b1 = newton_okounkov_inequalities(check_collection(3, 6))
        A2, b2 = checkboard_inequalities(3, 6)

        (A1 == A2) && (b1 == b2)
    end


    @test begin 
        "newton_okounkov_body"

        newton_okounkov_body(check_collection(3, 6))
        true
    end


    @test begin 
        "checkboard_body"

        N1 = newton_okounkov_body(check_collection(3, 6))
        N2 = checkboard_body(3, 6)
        N1 == N2
    end

    ######## Action of D_n ########

    @test begin
        "dihedral_perm_group"

        WSC.dihedral_perm_group(5)
        true
    end


    @test begin
        "cyclic_perm_group"

        WSC.cyclic_perm_group(5)
        true
    end


    @test begin
        "Base.:^"

        s, t = gens(WSC.dihedral_perm_group(6))
        check = check_collection(3, 6)

        (check^s)^t == check^(s*t)
    end

    @test begin
        "gset"

        D = WSC.dihedral_perm_group(6)
        check = check_collection(3, 6)

        gset(D, [check])
        true
    end


    @test begin
        "orbit"

        D = WSC.dihedral_perm_group(6)
        check = check_collection(3, 6)

        M = gset(D, [check])
        
        ( collect(orbit(M, check)) == collect(orbit(D, check)) ) && ( collect(orbit(M, check)) == collect(orbit(check)) )
    end


    @test begin
        "stabilizer"

        D = WSC.dihedral_perm_group(6)
        check = check_collection(3, 6)

        (stabilizer(D, check) == stabilizer(check) )
    end

    ######## Plotting ########

    import Luxor
    
    @test begin # drawTiling
        G = check_collection(4, 9)
        drawTiling(G, "test_1.png", 500, 500)
        true
    end

    
    @test begin # drawPLG_poly
        G = check_collection(4, 9)
        drawPLG(G, "test_2.png", 500, 500; drawmode = "polygonal")
        true
    end

    
    @test begin # drawPLG_straight
        G = check_collection(4, 9)
        drawPLG(G, "test_3.png", 500, 500; drawmode = "straight")
        true
    end

    
    @test begin # drawPLG_smooth
        G = check_collection(4, 9)
        drawPLG(G, "test_4.png", 500, 500; drawmode = "smooth")
        true
    end

    
    @test begin # backgroundColor via named colors
        G = check_collection(4, 9)
        drawPLG(G, "test_5.png", 500, 500; backgroundColor = "purple")
        true
    end

     
    using Colors 
    @test begin # backgroundColor via RGBA value. fails without using Colors
        G = check_collection(4, 9)
        drawPLG(G, "test_6.png", 500, 500; backgroundColor = RGBA(1.0, 1.0, 1.0, 0.4))
        true
    end

    ######## Gui ########

    # using Mousetrap

    # @test begin
    #     check = check_collection(4, 9)
    #     visualizer!(check)
    #     true
    # end

end

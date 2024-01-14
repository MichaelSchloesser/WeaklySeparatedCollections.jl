using WeaklySeparatedCollections
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
        WeaklySeparatedCollections.compute_cliques(4, labels)
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
        W2, B2 = WeaklySeparatedCollections.compute_cliques(4, labels)

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

    ######## Plotting ########

    using Luxor
    
    @test begin # drawTiling
        G = checkboard_collection(4, 9)
        drawTiling(G, "test_1.png", 500, 500)
        true
    end

    
    @test begin # drawPLG_poly
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_2.png", 500, 500, drawmode = "polygonal")
        true
    end

    
    @test begin # drawPLG_straight
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_3.png", 500, 500, drawmode = "straight")
        true
    end

    
    @test begin # drawPLG_smooth
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_4.png", 500, 500, drawmode = "smooth")
        true
    end

    
    @test begin # backgroundColor via named colors
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_5.png", 500, 500, backgroundColor = "purple")
        true
    end

     
    using Colors 
    @test begin # backgroundColor via RGBA value. fails without using Colors
        G = checkboard_collection(4, 9)
        drawPLG(G, "test_6.png", 500, 500, backgroundColor = RGBA(1.0, 1.0, 1.0, 0.4))
        true
    end

    ######## Gui ########

    # using Mousetrap

    # @test begin
    #     check = checkboard_collection(4, 9)
    #     visualizer(check)
    #     true
    # end

end

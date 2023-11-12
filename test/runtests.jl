using WeaklySeparatedCollections
using Test

@testset "WeaklySeparatedCollections.jl" begin

    #### Combinatorics ####

    # is_weakly_separated(n, v, w)
    @test begin 
        v = [1,2,3,5,6,9]
        w = [1,2,4,5,7,8]
        is_weakly_separated(9, v, w) == false
    end

    @test begin 
        v = [1,2,3,5,6,9]
        w = [1,2,3,5,7,8]
        is_weakly_separated(9, v, w) == true
    end

    # checkboard_labels retuen type
    @test begin
        labels = checkboard_labels(4, 9)
        typeof(labels) == Vector{Vector{Int}}
    end

    # is_weakly_separated(n, collection)
    @test begin
        labels = checkboard_labels(4, 9)
        is_weakly_separated(9, labels) == true
    end

    # compute_cliques
    @test begin
        labels = checkboard_labels(4, 9)
        compute_cliques(4, labels)
        true
    end

    # compute_adjacencies
    @test begin
        labels = checkboard_labels(4, 9)
        compute_adjacencies(4, 9, labels)
        true
    end

    # WSCollection constructors
    @test begin
        labels = checkboard_labels(4, 9)
        WSCollection(4, 9, labels)
        WSCollection(4, 9, labels, false)

        true
    end

    # checkboard_collection
    @test begin
        checkboard_collection(4, 9)
        true
    end

    # rectangle_collection
    @test begin
        rectangle_collection(4, 9)
        true
    end

    # isequal
    @test begin
        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        isequal(check, rec) == false
    end


    @test begin
        check = checkboard_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = checkboard_collection(4, 9)

        isequal(check, check2) 
    end

    # overload Base.:(==)
    @test begin
        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        (check == rec) == false
    end


    @test begin
        check = checkboard_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = checkboard_collection(4, 9)

        check == check2
    end

    # overload Base.:(!=)
    @test begin
        check = checkboard_collection(4, 9)
        rec = rectangle_collection(4, 9)

        check != rec
    end


    @test begin
        check = checkboard_collection(4, 9)
        (check.labels[10], check.labels[11]) = (check.labels[11], check.labels[10])
        check2 = checkboard_collection(4, 9)

        (check != check2) == false
    end

    # is_frozen
    @test begin
        check = checkboard_collection(4, 9)
        is_frozen(check, 1) && is_frozen(check, 9) && !is_frozen(check, 10)
    end

    # is_mutable
    @test begin
        rec = rectangle_collection(4, 9)
        !is_mutable(rec, 1) && is_mutable(rec, 10) && !is_mutable(rec, 11)
    end

    # mutate! and mutate
    @test begin
        check = checkboard_collection(4, 9)
        mutate!(check, 10)
        mutate(check, 13)
        true
    end

    # rotate_collection
    @test begin
        rec = rectangle_collection(4, 9)
        rotate_collection(rec, 1)
        rotate_collection(rec, 5)
        true
    end

    # reflect_collection
    @test begin
        rec = rectangle_collection(4, 9)
        reflect_collection(rec, 1)
        reflect_collection(rec, 4)
        true
    end

    # complement_collection
    @test begin
        rec = rectangle_collection(4, 9)
        complement_collection(rec)
        true
    end

    # swaped_colors_collection
    @test begin
        rec = rectangle_collection(4, 9)
        swaped_colors_collection(rec)
        true
    end

    # dual_rectangle_collection
    @test begin
        dual_rectangle_collection(4, 9)
        true
    end

    # dual_checkboard_collection
    @test begin
        dual_checkboard_collection(4, 9)
        true
    end

    #### Plotting ####
    
    # drawTiling
    @test begin
        G = checkboard_collection(4, 9)
        drawTiling(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_1.png", 500, 500)
        true
    end

    # drawPLG_poly
    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_poly(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_2.png", 500, 500)
        true
    end

    # drawPLG_straight
    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_straight(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_3.png", 500, 500)
        true
    end

    # drawPLG_smooth
    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_smooth(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_4.png", 500, 500)
        true
    end

    # backgroundColor via named colors
    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_poly(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_5.png", 500, 500, backgroundColor = "purple")
        true
    end

    # backgroundColor via RGBA value. fails without using Colors 
    using Colors 
    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_poly(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_6.png", 500, 500, backgroundColor = RGBA(1.0, 1.0, 1.0, 0.4))
        true
    end

    #### Gui ####

    # @test begin
    #     check = checkboard_collection(4, 9)
    #     visualizer(check)
    #     true
    # end

end

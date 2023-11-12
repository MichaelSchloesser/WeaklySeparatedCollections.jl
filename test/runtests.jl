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

    # TODO 
    # WSCollection, is_frozen, 
    # is_mutable, mutate!, mutate, checkboard_collection, rectangle_collection, rotate_collection,
    # reflect_collection, complement_collection, swaped_colors_collection, dual_checkboard_collection, 
    # dual_rectangle_collection, compute_cliques, compute_adjacencies

    #### Plotting ####
    
    @test begin
        G = checkboard_collection(4, 9)
        drawTiling(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_1.png", 500, 500)
        true
    end


    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_poly(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_2.png", 500, 500)
        true
    end


    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_straight(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_3.png", 500, 500)
        true
    end


    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_smooth(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_4.png", 500, 500)
        true
    end


    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_poly(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_5.png", 500, 500, backgroundColor = "purple")
        true
    end

    using Colors # fails without using Colors 
    @test begin
        G = checkboard_collection(4, 9)
        drawPLG_poly(G, "C:\\Users\\Micha\\Desktop\\plotting_tests\\test_6.png", 500, 500, backgroundColor = RGBA(1.0, 1.0, 1.0, 0.4))
        true
    end

    #### Gui ####

    # TODO 
    # visualizer

end

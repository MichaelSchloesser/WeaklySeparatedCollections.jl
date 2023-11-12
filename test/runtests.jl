using WeaklySeparatedCollections
using Test

@testset "WeaklySeparatedCollections.jl" begin

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

    
    



end

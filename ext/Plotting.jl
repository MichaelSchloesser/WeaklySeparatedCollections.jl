
module Plotting

using WeaklySeparatedCollections, Luxor
using Colors
import Graphs: all_neighbors, outneighbors
import WeaklySeparatedCollections as WSC
using StaticArrays

LPoint = Luxor.Point
function P(v::SVector{2, T}) where T <: AbstractFloat
    return LPoint(v[1], v[2])
end

function norm(P::LPoint)
    res = P.x*P.x + P.y*P.y
    return sqrt(res)
end

function norm(v::SVector{2, T}) where T <: AbstractFloat
    res = v[1]*v[1] + v[2]*v[2]
    return sqrt(res)
end

intersect_neighbors! = WSC.intersect_neighbors!
combine_neighbors! = WSC.combine_neighbors!
complement = WSC.complement

# TODO add support for non maximal wscs

# sadly we cant really optimize these functions much. The drawing itself takes orders of magnitude longer than anyting else.

function embedding_data(C::WSCollection, width::Int, height::Int, topLabel::AbstractFloat = -1.0)
    k, n = C.k, C.n
    W, B = C.whiteCliques, C.blackCliques
    
    R_poly = Vector{SVector{2, Float64}}(undef, n)
    for i in 0:n-1
        @fastmath @inbounds R_poly[i+1] = SVector{2, Float64}(sin(i*2*pi/n), -cos(i*2*pi/n))
    end

    # autoselect scale such that plabic tiling fits into window
    v = sum( @view R_poly[1:k])
    r = norm(v)
    # scale_factor = 2.4
    s = min(width, height)/(2.4*r)

    if topLabel > 0
        @fastmath @views new_angle = acos( -v[2]/r ) - (k - topLabel + 0.5)*2.0*pi/n 

        for i in 0:n-1
            @fastmath @inbounds R_poly[i+1] = SVector{2, Float64}( sin(i*2*pi/n - new_angle), -cos(i*2*pi/n - new_angle))
        end
    end

    tau = i -> P(s*sum( @view R_poly[C[i]] ))

    return n, k, W, B, r, s, R_poly, tau
end

function WSC.drawTiling(C::WSCollection, title::String, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "", drawLabels::Bool = true, 
    highlightMutables::Bool = false, labelDirection = "left") 

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end

    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)
    N = length(C)
    
    Drawing(width, height, title)
        origin()

        if backgroundColor != ""
            background(backgroundColor)
        end
        
        # draw faces
        sethue("white")
        for w in values(W)
            poly(tau.(w), :fill)
        end
        sethue("black")
        for b in values(B)
            poly(tau.(b), :fill)
        end

        for i = 1:n
            line(tau(i), tau(mod1(i+1, n)), :stroke)
        end
        
        # draw vertices + labels
        if drawLabels
            fontsize( div(s*fontScale, 6))
            for i in 1:N
                pos = tau(i)

                label = ""

                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                len = length(label)

                if is_mutable(C, i) && highlightMutables
                    sethue("orange")
                else
                    sethue("white")
                end

                ellipse(pos, s/8*(len+1), s/4, :fill)
                sethue("black")
                ellipse(pos, s/8*(len+1), s/4, :stroke)
                text(label, pos, halign=:center, valign=:middle)
            end
        else
            for i = 1:length(C)
                pos = tau(i)

                if is_mutable(C, i) && highlightMutables
                    sethue("orange")
                    circle(pos, s/8, :fill)
                    sethue("black")
                    circle(pos, s/8, :stroke)
                else
                    sethue("white")
                    circle(pos, s/16, :fill)
                    sethue("black")
                    circle(pos, s/16, :stroke)
                end
            end
        end

    finish()
end


function drawPLG_poly(C::WSCollection{T}, title::String, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "", drawLabels::Bool = false, 
    labelDirection = "left") where T <:Integer

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end
    
    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)

    Drawing(width, height, title)
        origin()
        
        if backgroundColor != ""
            background(backgroundColor)
        end
        
        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))
        frozen_tau = i -> P(s*sum( @view R_poly[frozen_label(k, n, i)] ))

        for i = 1:n 
            p1, p2 = frozen_tau(i), frozen_tau(mod1(i+1, n))
            r2 = norm(p1 + p2)
            line((p1 + p2)/2, r*s*(p1 + p2)/r2, :stroke)
            
            text( "$(mod1(i+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
        end

        circle(LPoint(0, 0), s*r, :stroke)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            w = tau.(w)
            len_w = length(w)
            c = sum(w)/len_w # Point in face. 
            
            for i = 1:len_w # draw lines from c to edge midPoints
                line(c, (w[i] + w[mod1(i+1, len_w)])/2,  :stroke)
            end

            sethue("white") # draw white vertex
            circle(c, s/8, :fill)
            sethue("black")
            circle(c, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            c = sum(b)/len_b # Point in face. 

            for i = 1:len_b # draw lines from c to edge midPoints
                line(c, (b[i] + b[mod1(i+1, len_b)])/2,  :stroke)
            end

            circle(c, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels.
        if drawLabels
            fontsize( div(s*fontScale, 6))

            K = Vector{T}(undef, k-1)
            L = Vector{T}(undef, k+1)

            # frozen labels
            for i = 1:n
                label = ""

                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_all = all_neighbors(C.quiver, i)
                dual_vertices = Set{LPoint}()

                for j in N_all
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            # non frozen labels
            for i = n+1:length(C)
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_out = outneighbors(C.quiver, i)
                
                dual_vertices = Vector{LPoint}()
                for j in N_out
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)

                text(label, c, halign=:center, valign=:middle)
            end
        end
    finish()
end


function drawPLG_straight(C::WSCollection{T}, title::String, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "", drawLabels::Bool = false, 
    highlightMutables::Bool = false, highlight::Int, labelDirection = "left") where T <: Integer

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end

    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)
    
    Drawing(width, height, title)
        origin()
        
        if backgroundColor != ""
            background(backgroundColor)
        end
        
        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))
        frozen_tau = l -> P(s*sum( @view R_poly[l] ))
        
        K = Vector{T}(undef, k-1)
        L = Vector{T}(undef, k+1)

        for i = 1:n 
            l1, l2 = frozen_label(k, n, i), frozen_label(k, n, mod1(i+1, n))
            p1, p2 = frozen_tau(l1), frozen_tau(l2)
            r2 = norm(p1 + p2)

            adj = intersect_neighbors!(K, l1, l2)
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p3 = sum(tau.(w))/len_w
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            else
                adj = combine_neighbors!(L, l1, l2)
                b = B[adj]
                len_b = length(b)
                p3 = sum(tau.(b))/len_b
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            end
            
            text( "$(mod1(i+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle )
        end

        circle(LPoint(0, 0), s*r, :stroke)

        # highlight mutable faces
        if highlightMutables 
            for i = n+1:length(C)
                if is_mutable(C, i)
                    
                    N_out = outneighbors(C.quiver, i)

                    function arith_mean(x)
                        len_x = length(x)
                        return sum(tau.(x))/len_x
                    end

                    p1 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[1]]) ])
                    p2 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[1]]) ])
                    p3 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[2]]) ])
                    p4 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[2]]) ])
                    
                    sethue("orange")
                    setopacity(0.5)
                    poly([p1, p2, p3, p4], :fill, close = true)
                end
            end
        end
        #highligt select label
        if !isnothing(highlight)
            is_mutable(highlight) || break

            i = highlight
            N_out = outneighbors(C.quiver, i)

            function arith_mean(x)
                len_x = length(x)
                return sum(tau.(x))/len_x
            end

            p1 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[1]]) ])
            p2 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[1]]) ])
            p3 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[2]]) ])
            p4 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[2]]) ])
            
            sethue("orange")
            setopacity(0.5)
            poly([p1, p2, p3, p4], :fill, close = true)
        end
        setopacity(1)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau.(w))/len_w # Point in face. 
            
            for i = 1:len_w 
                opp = combine_neighbors!(L, C[w[i]], C[w[mod1(i+1,len_w)]])
                if haskey(B, opp)
                    b = B[opp]
                    len_b = length(b)
                    p2 = sum(tau.(b))/len_b
                    line(p1, p2,  :stroke)
                end
            end

            sethue("white") # draw white vertex
            circle(p1, s/8, :fill)
            sethue("black")
            circle(p1, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            p1 = sum(b)/len_b # Point in face. 

            circle(p1, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels
        if drawLabels
            fontsize( div(s*fontScale ,6))
            for i = 1:n
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_all = all_neighbors(C.quiver, i)
                dual_vertices = Set{LPoint}()

                for j in N_all
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            for i = n+1:length(C)
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_out = outneighbors(C.quiver, i)
                
                dual_vertices = Vector{LPoint}()
                for j in N_out
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)

                text(label, c, halign=:center, valign=:middle)
            end
        end

    finish()
end


function drawPLG_smooth(C::WSCollection{T}, title::String, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "", drawLabels::Bool = false, 
    labelDirection = "left") where T <: Integer

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end

    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)
    
    Drawing(width, height, title)
        origin()
        
        if backgroundColor != ""
            background(backgroundColor)
        end

        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))
        frozen_tau = l -> P(s*sum( @view R_poly[l] ))
        
        K = Vector{T}(undef, k-1)
        L = Vector{T}(undef, k+1)

        for i = 1:n 
            l1, l2 = frozen_label(k, n, i), frozen_label(k, n, mod1(i+1, n))
            p1, p2 = frozen_tau(l1), frozen_tau(l2)
            p3 = midpoint(p1, p2)
            r2 = norm(p1 + p2)

            adj = intersect_neighbors!(K, l1, l2)
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p4 = sum(tau.(w))/len_w

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4)
                strokepath()
            else
                adj = combine_neighbors!(L, l1, l2)
                b = B[adj]
                len_b = length(b)
                p4 = sum(tau.(b))/len_b

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4)
                strokepath()
            end
            
            text( "$(mod1(i+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
        end

        circle(LPoint(0,0), s*r, :stroke)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau.(w))/len_w # Point in face. 
            
            for i = 1:len_w 
                opp = combine_neighbors!(L, C[w[i]], C[w[mod1(i+1,len_w)]])
                if haskey(B, opp)
                    p2 = midpoint(tau(w[i]), tau(w[mod1(i+1,len_w)]) )
                    b = B[opp]
                    len_b = length(b)
                    p3 = sum(tau.(b))/len_b

                    move(p1)
                    curve(p1, p2, p3) 
                    strokepath()
                end
            end

            sethue("white") # draw white vertex
            circle(p1, s/8, :fill)
            sethue("black")
            circle(p1, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            p1 = sum(b)/len_b # Point in face. 

            circle(p1, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels. 
        if drawLabels
            fontsize( div(s*fontScale ,6))
            for i = 1:n
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_all = all_neighbors(C.quiver, i)
                dual_vertices = Set{LPoint}()

                for j in N_all
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            for i = n+1:length(C)
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_out = outneighbors(C.quiver, i)
                
                dual_vertices = Vector{LPoint}()
                for j in N_out
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)
                text(label, c, halign=:center, valign=:middle)
            end
        end
        
    finish()
end


function WSC.drawPLG(C::WSCollection, title::String, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    drawmode::String = "straight", backgroundColor::Union{String, ColorTypes.Colorant} = "", drawLabels::Bool = false, 
    highlightMutables::Bool = false, labelDirection = "left")

    if drawmode == "straight"

        drawPLG_straight(C, title, width, height; topLabel, fontScale, backgroundColor, drawLabels,
        highlightMutables, labelDirection)

    elseif drawmode == "smooth"

        drawPLG_smooth(C, title, width, height; topLabel, fontScale, backgroundColor, drawLabels, labelDirection)

    elseif drawmode == "polygonal"

        drawPLG_poly(C, title, width, height; topLabel, fontScale, backgroundColor, drawLabels, labelDirection)

    else 
        error("invalid drawmode: $drawmode")
    end

end


########################################################################
#####          Versions that dont save the image as file           #####
########################################################################


function WSC.drawTiling(C::WSCollection, surfacetype::Symbol, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "lightblue4", drawLabels::Bool = true, 
    highlightMutables::Bool = false, labelDirection = "left") 

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end

    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)
    N = length(C)

    Drawing(width, height, surfacetype)
        origin()

        if backgroundColor != ""
            background(backgroundColor)
        end
        
        # draw faces
        sethue("white")
        for w in values(W)
            poly(tau.(w), :fill)
        end
        sethue("black")
        for b in values(B)
            poly(tau.(b), :fill)
        end

        for i = 1:n
            line(tau(i), tau(mod1(i+1, n)), :stroke)
        end
        
        # draw vertices + labels
        if drawLabels
            fontsize( div(s*fontScale, 6))
            for i in 1:N
                pos = tau(i)

                label = ""

                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                len = length(label)

                if is_mutable(C, i) && highlightMutables
                    sethue("orange")
                else
                    sethue("white")
                end

                ellipse(pos, s/8*(len+1), s/4, :fill)
                sethue("black")
                ellipse(pos, s/8*(len+1), s/4, :stroke)
                text(label, pos, halign=:center, valign=:middle)
            end
        else
            for i = 1:length(C)
                pos = tau(i)

                if is_mutable(C, i) && highlightMutables
                    sethue("orange")
                    circle(pos, s/8, :fill)
                    sethue("black")
                    circle(pos, s/8, :stroke)
                else
                    sethue("white")
                    circle(pos, s/16, :fill)
                    sethue("black")
                    circle(pos, s/16, :stroke)
                end
            end
        end

    finish()

end


function drawPLG_poly(C::WSCollection, surfacetype::Symbol, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "lightblue4", drawLabels::Bool = false, 
    labelDirection = "left") 

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end
    
    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)

    Drawing(width, height, surfacetype)
        origin()
        
        if backgroundColor != ""
            background(backgroundColor)
        end
        
        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))
        frozen_tau = i -> P(s*sum( @view R_poly[frozen_label(k, n, i)] ))

        for i = 1:n 
            p1, p2 = frozen_tau(i), frozen_tau(mod1(i+1, n))
            r2 = norm(p1 + p2)
            line((p1 + p2)/2, r*s*(p1 + p2)/r2, :stroke)
            
            text( "$(mod1(i+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
        end

        circle(LPoint(0, 0), s*r, :stroke)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            w = tau.(w)
            len_w = length(w)
            c = sum(w)/len_w # Point in face. 
            
            for i = 1:len_w # draw lines from c to edge midPoints
                line(c, (w[i] + w[mod1(i+1, len_w)])/2,  :stroke)
            end

            sethue("white") # draw white vertex
            circle(c, s/8, :fill)
            sethue("black")
            circle(c, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            c = sum(b)/len_b # Point in face. 

            for i = 1:len_b # draw lines from c to edge midPoints
                line(c, (b[i] + b[mod1(i+1, len_b)])/2,  :stroke)
            end

            circle(c, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels.
        if drawLabels
            fontsize( div(s*fontScale, 6))

            K = Vector{T}(undef, k-1)
            L = Vector{T}(undef, k+1)

            # frozen labels
            for i = 1:n
                label = ""

                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_all = all_neighbors(C.quiver, i)
                dual_vertices = Set{LPoint}()

                for j in N_all
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            # non frozen labels
            for i = n+1:length(C)
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_out = outneighbors(C.quiver, i)
                
                dual_vertices = Vector{LPoint}()
                for j in N_out
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)

                text(label, c, halign=:center, valign=:middle)
            end
        end
    finish()
end


function drawPLG_straight(C::WSCollection{T}, surfacetype::Symbol, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "", drawLabels::Bool = false, 
    highlightMutables::Bool = false, highlight::Int, labelDirection = "left") where T <: Integer

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end

    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)
    
    Drawing(width, height, surfacetype)
        origin()
        
        if backgroundColor != ""
            background(backgroundColor)
        end
        
        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))
        frozen_tau = l -> P(s*sum( @view R_poly[l] ))
        
        K = Vector{T}(undef, k-1)
        L = Vector{T}(undef, k+1)

        for i = 1:n 
            l1, l2 = frozen_label(k, n, i), frozen_label(k, n, mod1(i+1, n))
            p1, p2 = frozen_tau(l1), frozen_tau(l2)
            r2 = norm(p1 + p2)

            adj = intersect_neighbors!(K, l1, l2)
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p3 = sum(tau.(w))/len_w
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            else
                adj = combine_neighbors!(L, l1, l2)
                b = B[adj]
                len_b = length(b)
                p3 = sum(tau.(b))/len_b
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            end
            
            text( "$(mod1(i+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle )
        end

        circle(LPoint(0, 0), s*r, :stroke)

        # highlight mutable faces
        if highlightMutables 
            for i = n+1:length(C)
                if is_mutable(C, i)
                    
                    N_out = outneighbors(C.quiver, i)

                    function arith_mean(x)
                        len_x = length(x)
                        return sum(tau.(x))/len_x
                    end

                    p1 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[1]]) ])
                    p2 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[1]]) ])
                    p3 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[2]]) ])
                    p4 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[2]]) ])
                    
                    sethue("orange")
                    setopacity(0.5)
                    poly([p1, p2, p3, p4], :fill, close = true)
                end
            end
        end

        #highligt select label
        if !isnothing(highlight)
            is_mutable(highlight) || break

            i = highlight
            N_out = outneighbors(C.quiver, i)

            function arith_mean(x)
                len_x = length(x)
                return sum(tau.(x))/len_x
            end

            p1 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[1]]) ])
            p2 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[1]]) ])
            p3 = arith_mean(W[ intersect_neighbors!(K, C[i], C[N_out[2]]) ])
            p4 = arith_mean(B[ combine_neighbors!(L, C[i], C[N_out[2]]) ])
            
            sethue("orange")
            setopacity(0.5)
            poly([p1, p2, p3, p4], :fill, close = true)
        end
        setopacity(1)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau.(w))/len_w # Point in face. 
            
            for i = 1:len_w 
                opp = combine_neighbors!(L, C[w[i]], C[w[mod1(i+1,len_w)]])
                if haskey(B, opp)
                    b = B[opp]
                    len_b = length(b)
                    p2 = sum(tau.(b))/len_b
                    line(p1, p2,  :stroke)
                end
            end

            sethue("white") # draw white vertex
            circle(p1, s/8, :fill)
            sethue("black")
            circle(p1, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            p1 = sum(b)/len_b # Point in face. 

            circle(p1, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels
        if drawLabels
            fontsize( div(s*fontScale ,6))
            for i = 1:n
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_all = all_neighbors(C.quiver, i)
                dual_vertices = Set{LPoint}()

                for j in N_all
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            for i = n+1:length(C)
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_out = outneighbors(C.quiver, i)
                
                dual_vertices = Vector{LPoint}()
                for j in N_out
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)

                text(label, c, halign=:center, valign=:middle)
            end
        end

    finish()
end


function drawPLG_smooth(C::WSCollection{T}, surfacetype::Symbol, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "lightblue4", drawLabels::Bool = false, 
    labelDirection = "left") where T <: Integer

    if cliques_empty(C)
        error("cliques needed for drawing are empty!")
    end

    n, k, W, B, r, s, R_poly, tau = embedding_data(C, width, height, topLabel)
    
    Drawing(width, height, surfacetype)
        origin()
        
        if backgroundColor != ""
            background(backgroundColor)
        end

        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))
        frozen_tau = l -> P(s*sum( @view R_poly[l] ))
        
        K = Vector{T}(undef, k-1)
        L = Vector{T}(undef, k+1)

        for i = 1:n 
            l1, l2 = frozen_label(k, n, i), frozen_label(k, n, mod1(i+1, n))
            p1, p2 = frozen_tau(l1), frozen_tau(l2)
            p3 = midpoint(p1, p2)
            r2 = norm(p1 + p2)

            adj = intersect_neighbors!(K, l1, l2)
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p4 = sum(tau.(w))/len_w

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4)
                strokepath()
            else
                adj = combine_neighbors!(L, l1, l2)
                b = B[adj]
                len_b = length(b)
                p4 = sum(tau.(b))/len_b

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4)
                strokepath()
            end
            
            text( "$(mod1(i+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
        end

        circle(LPoint(0,0), s*r, :stroke)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau.(w))/len_w # Point in face. 
            
            for i = 1:len_w 
                opp = combine_neighbors!(L, C[w[i]], C[w[mod1(i+1,len_w)]])
                if haskey(B, opp)
                    p2 = midpoint(tau(w[i]), tau(w[mod1(i+1,len_w)]) )
                    b = B[opp]
                    len_b = length(b)
                    p3 = sum(tau.(b))/len_b

                    move(p1)
                    curve(p1, p2, p3) 
                    strokepath()
                end
            end

            sethue("white") # draw white vertex
            circle(p1, s/8, :fill)
            sethue("black")
            circle(p1, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            p1 = sum(b)/len_b # Point in face. 

            circle(p1, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels. 
        if drawLabels
            fontsize( div(s*fontScale ,6))
            for i = 1:n
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_all = all_neighbors(C.quiver, i)
                dual_vertices = Set{LPoint}()

                for j in N_all
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            for i = n+1:length(C)
                label = ""
                
                if labelDirection == "left"
                    label = join(C[i])
                elseif labelDirection == "right"
                    label = join( complement(C[i], n))
                end

                N_out = outneighbors(C.quiver, i)
                
                dual_vertices = Vector{LPoint}()
                for j in N_out
                    intersect_neighbors!(K, C[i], C[j])
                    combine_neighbors!(L, C[i], C[j])
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)
                text(label, c, halign=:center, valign=:middle)
            end
        end
        
    finish()
end

function WSC.drawPLG(C::WSCollection, surfacetype::Symbol = :svg, width::Int = 500, height::Int = 500; topLabel::AbstractFloat = -1.0, fontScale = 1.0,
    drawmode::String = "straight", backgroundColor::Union{String, ColorTypes.Colorant} = "lightblue4", drawLabels::Bool = false, 
    highlightMutables::Bool = false, highlight::Int, labelDirection = "left")

    if drawmode == "straight"

        drawPLG_straight(C, surfacetype, width, height; topLabel, fontScale, backgroundColor, drawLabels, 
        highlightMutables, highlight, labelDirection)

    elseif drawmode == "smooth"

        drawPLG_smooth(C, surfacetype, width, height; topLabel, fontScale, backgroundColor, drawLabels, labelDirection)

    elseif drawmode == "polygonal"

        drawPLG_poly(C, surfacetype, width, height; topLabel, fontScale, backgroundColor, drawLabels, 
        labelDirection = "left")

    else 
        error("invalid drawmode: $drawmode")
    end

end

end
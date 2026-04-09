
module Plotting

using WeaklySeparatedCollections, Luxor
import WeaklySeparatedCollections as WSC
using Colors
import Graphs: all_neighbors, outneighbors
using StaticArrays

const LPoint = Luxor.Point


# adjusted from https://github.com/JuliaGraphics/Luxor.jl/blob/master/src/polygons.jl 
function Luxor.poly(pointlist::NTuple{N,Point} where {N};
    action = :none,
    close = false,
    reversepath = false)
    if action != :path
        newpath()
    end
    if reversepath == true
        pointlist = reverse(pointlist)
    end
    move(pointlist[1].x, pointlist[1].y)
    @inbounds for p in pointlist[2:end]
        line(p.x, p.y)
    end
    if close == true
        closepath()
    end
    do_action(action)
    return pointlist
end

Luxor.poly(pointlist::NTuple{N,Point} where {N}, a::Symbol;
    action = a,
    close = false,
    reversepath = false) = poly(pointlist, action = action, close = close, reversepath = reversepath)

function Luxor.poly(input_array,
    tau::Function; # must output Points
    action = :none,
    close = false,
    reversepath = false)
    if action != :path
        newpath()
    end
    if reversepath == true
        reverse!(input_array)
    end
    @inbounds move(tau(input_array[1]))
    @inbounds @views for i in input_array[2:end]
        line(tau(i))
    end
    if close == true
        closepath()
    end
    do_action(action)
    return input_array
end

Luxor.poly(input_array,
    tau::Function, 
    a::Symbol;
    action = a,
    close = false,
    reversepath = false) = poly(input_array, tau, action = action, close = close, reversepath = reversepath)


function norm(p::LPoint)
    res = p.x*p.x + p.y*p.y
    return @fastmath sqrt(res)
end

# TODO add support for non maximal wscs

# sadly we cant really optimize these functions much. The drawing itself takes orders of magnitude longer than anyting else.
function embedding_data(C::WSCollection, width::Int, height::Int, topLabel::T = -1.0) where T <: AbstractFloat
    k, n = C.k, C.n
    
    R_poly = Vector{LPoint}(undef, n)
    for i in 0:n-1
        @fastmath @inbounds R_poly[i+1] = LPoint(sin(i*2*pi/n), -cos(i*2*pi/n))
    end

    # autoselect appropiate scale
    @inbounds @views v = sum(R_poly[1:k])
    r = norm(v)
    # scale_factor = 2.4
    s = min(width, height)/(2.4*r)

    if topLabel > 0
        @fastmath @inbounds new_angle = acos( -v[2]/r ) - (k - topLabel + 0.5)*2.0*pi/n 

        for i in 0:n-1
            @fastmath @inbounds R_poly[i+1] = LPoint( sin(i*2*pi/n - new_angle), -cos(i*2*pi/n - new_angle))
        end
    end

    return r, s, R_poly
end

function label_emb(label, R_poly, n::Int, s)
    res = LPoint(0, 0)

    for j in 0:n-1
        @inbounds (label >>> j) & 1 == 1 && (res += R_poly[j+1])
    end
    return s*res
end

function label_emb(i, R_poly, C::WSCollection, s) 
    @inbounds label_emb(C[i], R_poly, C.n, s) 
end

function drawTiling(C::WSCollection, 
    title::Union{Symbol, String} = :svg, 
    width::Int = 500, height::Int = 500; 
    topLabel::AbstractFloat = -1.0, 
    fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "",
    drawLabels::Bool = true, 
    highlightMutables::Bool = false, 
    labelDirection = "left") 

    cliques_init(C) || (C = WSCollection(C, keepCliques = true))

    n, k = C.n, C.k
    W, B = C.whiteCliques, C.blackCliques
    r, s, R_poly = embedding_data(C, width, height, topLabel)
    tau = i -> label_emb(i, R_poly, C, s)
    N = length(C)

    Drawing(width, height, title)
        origin()

        backgroundColor != "" && background(backgroundColor)
        
        # draw faces
        sethue("white")
        for w in values(W)
            poly(w, tau, :fill)
        end
        sethue("black")
        for b in values(B)
            poly(b, tau, :fill)
        end

        for i = 1:n
            line(tau(i), tau(mod1(i+1, n)), :stroke)
        end
        
        # draw vertices + labels
        if drawLabels
            fontsize( div(s*fontScale, 6))
            for i in 1:N
                pos = tau(i)

                if labelDirection == "left"
                    label = label_to_string(C[i], n)
                elseif labelDirection == "right"
                    label = label_to_string( complement(C[i], n), n)
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

function add_dual_vertices!(dual_vertices, i, list, C, tau)
    for j in list
        @inbounds K = C[i] & C[j]
        @inbounds L = C[i] | C[j]
        p_w = sum(tau, C.whiteCliques[K])/length(C.whiteCliques[K])
        p_b = sum(tau, C.blackCliques[L])/length(C.blackCliques[L])
        push!(dual_vertices, p_w)
        push!(dual_vertices, p_b)
    end
end

function drawPLG_straight(C::WSCollection, 
    title::Union{Symbol, String} = :svg, 
    width::Int = 500, 
    height::Int = 500; 
    topLabel::AbstractFloat = -1.0, 
    fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "", 
    drawLabels::Bool = false, 
    highlightMutables::Bool = false, 
    highlight::Int = 0, 
    labelDirection = "left")

    cliques_init(C) || (C = WSCollection(C, keepCliques = true))

    n, k = C.n, C.k
    W, B = C.whiteCliques, C.blackCliques
    r, s, R_poly = embedding_data(C, width, height, topLabel)
    tau = i -> label_emb(i, R_poly, C, s)
    tau_direct = l -> label_emb(l, R_poly, n, s)
    N = length(C)
    
    Drawing(width, height, title)
        origin()
        
        backgroundColor != "" && background(backgroundColor)
        
        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))

        for i = 1:n 
            l1, l2 = frozen_label(k, n, i), frozen_label(k, n, mod1(i+1, n))
            p1, p2 = tau_direct(l1), tau_direct(l2)
            r2 = norm(p1 + p2)

            adj = l1 & l2
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p3 = sum(tau, w)/len_w
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            else
                adj = l1 | l2
                b = B[adj]
                len_b = length(b)
                p3 = sum(tau, b)/len_b
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            end
            
            text( "$(mod1(i+k+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle )
        end

        circle(LPoint(0, 0), s*r, :stroke)

        function arith_mean(x)
            len_x = length(x)
            return sum(tau, x)/len_x
        end

        # highlight mutable faces
        if highlightMutables 
            for i = n+1:length(C)
                if is_mutable(C, i)
                    
                    N_out = outneighbors(C.quiver, i)

                    p1 = arith_mean(W[ C[i] & C[N_out[1]] ])
                    p2 = arith_mean(B[ C[i] | C[N_out[1]] ])
                    p3 = arith_mean(W[ C[i] & C[N_out[2]] ])
                    p4 = arith_mean(B[ C[i] | C[N_out[2]] ])
                    
                    sethue("orange")
                    setopacity(0.5)
                    poly((p1, p2, p3, p4), :fill, close = true)
                end
            end
        end
        #highligt selected label
        if highlight > 0 && is_mutable(C, highlight)

            i = highlight
            N_out = outneighbors(C.quiver, i)

            p1 = arith_mean(W[ C[i] & C[N_out[1]] ])
            p2 = arith_mean(B[ C[i] | C[N_out[1]] ])
            p3 = arith_mean(W[ C[i] & C[N_out[2]] ])
            p4 = arith_mean(B[ C[i] | C[N_out[2]] ])
            
            sethue("orange")
            setopacity(0.5)
            poly((p1, p2, p3, p4), :fill, close = true)
        end
        setopacity(1)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau, w)/len_w # Point in face. 
            
            for i = 1:len_w 
                opp = C[w[i]] | C[w[mod1(i+1,len_w)]]
                if haskey(B, opp)
                    b = B[opp]
                    len_b = length(b)
                    p2 = sum(tau, b)/len_b
                    line(p1, p2,  :stroke)
                end
            end

            sethue("white") # draw white vertex
            circle(p1, s/8, :fill)
            sethue("black")
            circle(p1, s/8, :stroke)
        end

        for b in values(B)
            p1 = sum(tau, b)/length(b) # Point in face. 

            circle(p1, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels
        if drawLabels
            fontsize( div(s*fontScale, 6))
            dual_vertices = Vector{LPoint}()

            for i = 1:n
        
                if labelDirection == "left"
                    label = label_to_string(C[i], n)
                elseif labelDirection == "right"
                    label = label_to_string( complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, inneighbors(C.quiver, i), C, tau)
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end

            for i = n+1:length(C)
                
                if labelDirection == "left"
                    label = label_to_string(C[i], n)
                elseif labelDirection == "right"
                    label = label_to_string( complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                c = sum(dual_vertices)/length(dual_vertices)
                text(label, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end
        end

    finish()
end


function drawPLG_smooth(C::WSCollection, 
    title::Union{Symbol, String} = :svg, 
    width::Int = 500, 
    height::Int = 500; 
    topLabel::AbstractFloat = -1.0, 
    fontScale = 1.0,
    backgroundColor::Union{String, ColorTypes.Colorant} = "", 
    drawLabels::Bool = false, 
    labelDirection = "left")

    cliques_init(C) || (C = WSCollection(C, keepCliques = true))

    n, k = C.n, C.k
    W, B = C.whiteCliques, C.blackCliques
    r, s, R_poly = embedding_data(C, width, height, topLabel)
    tau = i -> label_emb(i, R_poly, C, s)
    tau_direct = l -> label_emb(l, R_poly, n, s)
    N = length(C)
    
    Drawing(width, height, title)
        origin()
        
        backgroundColor != "" && background(backgroundColor)

        # outer edges and boundary vertices
        fontsize( div(r*s*fontScale, 10))

        for i = 1:n 
            l1, l2 = frozen_label(k, n, i), frozen_label(k, n, mod1(i+1, n))
            p1, p2 = tau_direct(l1), tau_direct(l2)
            p3 = midpoint(p1, p2)
            r2 = norm(p1 + p2)

            adj = l1 & l2
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p4 = sum(tau, w)/len_w

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4)
                strokepath()
            else
                adj = l1 | l2
                b = B[adj]
                len_b = length(b)
                p4 = sum(tau, b)/len_b

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4)
                strokepath()
            end
            
            text( "$(mod1(i+k+1, n))", (1.1+fontScale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
        end

        circle(LPoint(0,0), s*r, :stroke)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau, w)/len_w # Point in face. 
            
            for i = 1:len_w 
                opp = C[w[i]] | C[w[mod1(i+1,len_w)]]
                if haskey(B, opp)
                    p2 = midpoint(tau(w[i]), tau(w[mod1(i+1,len_w)]) )
                    b = B[opp]
                    len_b = length(b)
                    p3 = sum(tau, b)/len_b

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
            p1 = sum(tau, b)/length(b) # Point in face. 

            circle(p1, s/8, :fill) # draw black vertex
            circle(p1, s/8, :stroke)
        end

        # draw face labels. 
        if drawLabels
            fontsize( div(s*fontScale ,6))
            dual_vertices = Set{LPoint}()

            for i = 1:n
                
                if labelDirection == "left"
                    label = label_to_string(C[i], n)
                elseif labelDirection == "right"
                    label = label_to_string( complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, inneighbors(C.quiver, i), C, tau)
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end

            for i = n+1:length(C)
                
                if labelDirection == "left"
                    label = label_to_string(C[i], n)
                elseif labelDirection == "right"
                    label = label_to_string( complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                c = sum(dual_vertices)/length(dual_vertices)
                text(label, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end
        end
        
    finish()
end


function drawPLG(C::WSCollection, 
    title::Union{Symbol, String} = :svg, 
    width::Int = 500, 
    height::Int = 500; 
    topLabel::AbstractFloat = -1.0, 
    fontScale = 1.0,
    drawmode::String = "straight", 
    backgroundColor::Union{String, ColorTypes.Colorant} = "", 
    drawLabels::Bool = true, 
    highlightMutables::Bool = false, 
    highlight::Int = 0, 
    labelDirection = "left")

    if drawmode == "straight"

        drawPLG_straight(C, title, width, height; topLabel, fontScale, backgroundColor, drawLabels,
        highlightMutables, highlight, labelDirection)

    elseif drawmode == "smooth"

        drawPLG_smooth(C, title, width, height; topLabel, fontScale, backgroundColor, drawLabels, labelDirection)
    else 
        error("invalid drawmode: $drawmode")
    end

end

end
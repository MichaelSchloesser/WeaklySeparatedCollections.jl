module Plotting

using WeaklySeparatedCollections, Luxor
import Luxor: Point as LPoint
import WeaklySeparatedCollections as WSC
using Colors
import Graphs: inneighbors, outneighbors


# adjusted from https://github.com/JuliaGraphics/Luxor.jl/blob/master/src/polygons.jl 
function myPoly(pointlist::NTuple{N,Point} where {N};
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

myPoly(pointlist::NTuple{N,Point} where {N}, a::Symbol;
    action = a,
    close = false,
    reversepath = false) = myPoly(pointlist, action = action, close = close, reversepath = reversepath)

function myPoly(input_array,
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

myPoly(input_array,
    tau::Function, 
    a::Symbol;
    action = a,
    close = false,
    reversepath = false) = myPoly(input_array, tau, action = action, close = close, reversepath = reversepath)


function norm(p::LPoint)
    res = p.x*p.x + p.y*p.y
    return @fastmath sqrt(res)
end

# TODO add support for non maximal wscs

# sadly we cant really optimize these functions much. The drawing itself takes orders of magnitude longer than anyting else.
function WSC.embedding_data(C::WSCollection, width::Int, height::Int, top_label::T = -1.0) where T <: AbstractFloat
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

    if top_label > 0
        @fastmath @inbounds new_angle = acos( -v[2]/r ) - (k - top_label + 0.5)*2.0*pi/n 

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

function WSC.drawTiling(C::WSCollection, 
    title::Union{Symbol, String} = :svg, 
    width::Int = 500, 
    height::Int = 500;
    top_label::AbstractFloat = -1.0, 
    font_scale = 1.0,
    background_color::Union{String, ColorTypes.Colorant} = "",
    draw_labels::Bool = true, 
    highlight_mutables::Bool = false, 
    label_direction::Symbol = :left) 

    cliques_init(C) || (C = WSCollection(C, keepCliques = true))

    n, k = C.n, C.k
    W, B = C.whiteCliques, C.blackCliques
    r, s, R_poly = embedding_data(C, width, height, top_label)
    tau = i -> label_emb(i, R_poly, C, s)
    N = length(C)

    drawing = Drawing(width, height, title)
        origin()

        background_color != "" && background(background_color)
        
        # draw faces
        sethue("white")
        for w in values(W)
            myPoly(w, tau, :fill)
        end
        sethue("black")
        for b in values(B)
            myPoly(b, tau, :fill)
        end

        for i = 1:n
            line(tau(i), tau(mod1(i+1, n)), :stroke)
        end
        
        # draw vertices + labels
        if draw_labels
            fontsize( div(s*font_scale, 6))
            for i in 1:N
                pos = tau(i)

                if label_direction == :left
                    L = label_to_string(C[i], n)
                else
                    L = label_to_string( WSC.complement(C[i], n), n)
                end

                len = length(L)

                if is_mutable(C, i) && highlight_mutables
                    sethue("orange")
                else
                    sethue("white")
                end

                ellipse(pos, s/8*(len+1), s/4, :fill)
                sethue("black")
                ellipse(pos, s/8*(len+1), s/4, :stroke)
                text(L, pos, halign=:center, valign=:middle)
            end
        else
            for i = 1:length(C)
                pos = tau(i)

                if is_mutable(C, i) && highlight_mutables
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

    return drawing
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

function WSC.drawPLG_straight(C::WSCollection, 
    title::Union{Symbol, String} = :svg, 
    width::Int = 500, 
    height::Int = 500; 
    top_label::AbstractFloat = -1.0, 
    font_scale = 1.0,
    background_color::Union{String, ColorTypes.Colorant} = "", 
    draw_labels::Bool = false, 
    highlight_mutables::Bool = false, 
    highlight::Int = 0, 
    label_direction::Symbol = :left)

    cliques_init(C) || (C = WSCollection(C, keepCliques = true))

    n, k = C.n, C.k
    W, B = C.whiteCliques, C.blackCliques
    r, s, R_poly = embedding_data(C, width, height, top_label)
    tau = i -> label_emb(i, R_poly, C, s)
    tau_direct = l -> label_emb(l, R_poly, n, s)
    N = length(C)
    
    drawing = Drawing(width, height, title)
        origin()
        
        background_color != "" && background(background_color)
        
        # outer edges and boundary vertices
        fontsize( div(r*s*font_scale, 10))

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
            
            text( "$(mod1(i+k+1, n))", (1.1+font_scale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle )
        end

        circle(LPoint(0, 0), s*r, :stroke)

        function arith_mean(x)
            len_x = length(x)
            return sum(tau, x)/len_x
        end

        # highlight mutable faces
        if highlight_mutables 
            for i = n+1:length(C)
                if is_mutable(C, i)
                    
                    N_out = outneighbors(C.quiver, i)

                    p1 = arith_mean(W[ C[i] & C[N_out[1]] ])
                    p2 = arith_mean(B[ C[i] | C[N_out[1]] ])
                    p3 = arith_mean(W[ C[i] & C[N_out[2]] ])
                    p4 = arith_mean(B[ C[i] | C[N_out[2]] ])
                    
                    sethue("orange")
                    setopacity(0.5)
                    myPoly((p1, p2, p3, p4), :fill, close = true)
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
            myPoly((p1, p2, p3, p4), :fill, close = true)
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
        if draw_labels
            fontsize( div(s*font_scale, 6))
            dual_vertices = Vector{LPoint}()

            for i = 1:n
        
                if label_direction == :left
                    L = label_to_string(C[i], n)
                else
                    L = label_to_string( WSC.complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, inneighbors(C.quiver, i), C, tau)
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(L, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end

            for i = n+1:length(C)
                
                if label_direction == :left
                    L = label_to_string(C[i], n)
                else
                    L = label_to_string( WSC.complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                c = sum(dual_vertices)/length(dual_vertices)
                text(L, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end
        end

    return drawing
end


function WSC.drawPLG_smooth(C::WSCollection, 
    title::Union{Symbol, String} = :svg, 
    width::Int = 500, 
    height::Int = 500; 
    top_label::AbstractFloat = -1.0, 
    font_scale = 1.0,
    background_color::Union{String, ColorTypes.Colorant} = "", 
    draw_labels::Bool = false, 
    label_direction::Symbol = :left)

    cliques_init(C) || (C = WSCollection(C, keepCliques = true))

    n, k = C.n, C.k
    W, B = C.whiteCliques, C.blackCliques
    r, s, R_poly = embedding_data(C, width, height, top_label)
    tau = i -> label_emb(i, R_poly, C, s)
    tau_direct = l -> label_emb(l, R_poly, n, s)
    N = length(C)
    
    drawing = Drawing(width, height, title)
        origin()
        
        background_color != "" && background(background_color)

        # outer edges and boundary vertices
        fontsize( div(r*s*font_scale, 10))

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
            
            text( "$(mod1(i+k+1, n))", (1.1+font_scale/50)*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
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
        if draw_labels
            fontsize( div(s*font_scale ,6))
            dual_vertices = Set{LPoint}()

            for i = 1:n
                
                if label_direction == :left
                    L = label_to_string(C[i], n)
                else
                    L = label_to_string( WSC.complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, inneighbors(C.quiver, i), C, tau)
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(L, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end

            for i = n+1:length(C)
                
                if label_direction == :left
                    L = label_to_string(C[i], n)
                else
                    L = label_to_string( WSC.complement(C[i], n), n)
                end
                
                add_dual_vertices!(dual_vertices, i, outneighbors(C.quiver, i), C, tau)

                c = sum(dual_vertices)/length(dual_vertices)
                text(L, c, halign=:center, valign=:middle)
                empty!(dual_vertices)
            end
        end
        
    return drawing
end


function WSC.draw(C::WSCollection, 
    title::Union{Symbol, String} = :svg,
    width::Int = 500, 
    height::Int = 500; 
    top_label::AbstractFloat = -1.0, 
    font_scale = 1.0,
    drawmode::Symbol = :straight, 
    background_color::Union{String, ColorTypes.Colorant} = "", 
    draw_labels::Bool = true, 
    highlight_mutables::Bool = false, 
    highlight::Int = 0, 
    label_direction::Symbol = :left)

    if drawmode == :tiling

        drawing = drawTiling(C, title, width, height; 
        top_label, 
        font_scale,
        background_color,
        draw_labels, 
        highlight_mutables, 
        label_direction) 

    elseif drawmode == :straight

        drawing = drawPLG_straight(C, title, width, height; 
        top_label, 
        font_scale,
        background_color, 
        draw_labels,
        highlight_mutables, 
        highlight, 
        label_direction)

    elseif drawmode == :smooth

        drawing = drawPLG_smooth(C, title, width, height; 
        top_label, 
        font_scale, 
        background_color, 
        draw_labels, 
        label_direction)
    else 
        error("invalid drawmode: $drawmode")
    end

    finish()
    return drawing
end

end
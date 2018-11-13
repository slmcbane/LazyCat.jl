module LazyCat

using RecursiveArrayTools
using Base: @propagate_inbounds

import Base: getindex, setindex!, size

export lazy_cat

function lazy_cat(arrs::AbstractArray{T, N}...; dim::Int=1) where {T, N}
    LazyCatArray{dim}(arrs...)
end

struct LazyCatArray{T, N, D, RANGES, ARR} <: AbstractArray{T, N}
    members::ARR

    function LazyCatArray{D}(members::AbstractArray{T,N}...) where {D, T, N}
        if !(D <= N && D > 0)
            throw(ErrorException("LazyCatArray{D}: Expect D to be a valid dimension for member arrays"))
        end
        
        members = [members...]
        sort!(members, by = t -> t[2][1])
        ranges = UnitRange[]
        
        for i ∈ 1:length(members)
            for d in 1:N
                if d != D
                    i != length(members) && (size(members[i], d) != size(members[i+1], d)) &&
                        throw(ErrorException("LazyCatArray{$D}: size in dimension $d does not match"))
                end
            end
            if isempty(ranges)
                push!(ranges, 1:size(members[i], D))
            else
                push!(ranges, ranges[end][end]+1:ranges[end][end]+size(members[i], D))
            end
        end

        arr = ArrayPartition(members...)
        new{T, N, D, (ranges...,), typeof(arr)}(arr)
    end
end

# Binary search for the proper array.
@propagate_inbounds function get_arrindex(ranges::NTuple{N, UnitRange},
                                          inds::NTuple{M, Int}, i) where {M, N}
    if M == 1
        i ∈ ranges[inds[1]] ? inds[1] : 0
    elseif M == 0
        0
    else
        half1, half2 = divide_inds(inds)
        if ranges[half2[1]][1] > i
            get_arrindex(ranges, half1, i)
        else
            get_arrindex(ranges, half2, i)
        end
    end
end

@generated function indrange(::Val{N}) where N
    exprs = [:($i) for i in 1:N]
    :(tuple($(exprs...)))
end

@propagate_inbounds function get_arrindex(ranges::NTuple{N, UnitRange}, i) where N
    get_arrindex(ranges, indrange(Val(N)), i)
end

@generated function divide_inds(INDS::NTuple{N, Int}) where N
    exprs1 = [:(INDS[$i]) for i in  1:N÷2]
    exprs2 = [:(INDS[$i]) for i in N÷2+1:N]
    quote
        tuple($(exprs1...)), tuple($(exprs2...))
    end
end

@generated function get_subarr_index(::LazyCatArray{T, N, D, RANGES}, I::NTuple{N, Int},
                                     arrindex) where {T, N, D, RANGES}
    sub_masks = ((
                 ((i == D ? RANGES[j][1] : 0 for i ∈ 1:N)...,)
                 for j ∈ 1:length(RANGES))...,
                )
    add_mask = ( (i == D ? 1 : 0 for i ∈ 1:N)..., )

    quote
        I .- $(sub_masks)[arrindex] .+ $add_mask
    end
end

@propagate_inbounds function getindex(A::LazyCatArray{T, N, D, RANGES}, 
                                      I::Vararg{Int, N}) where {T, N, D, RANGES}
    arrindex = get_arrindex(RANGES, I[D])
    
    @boundscheck begin
        if arrindex == 0
            throw(BoundsError(A, I))
        end
    end
    I = get_subarr_index(A, I, arrindex)
    A.members[arrindex, I...]
end

@propagate_inbounds function setindex!(A::LazyCatArray{T, N, D, RANGES}, v, 
                                       I::Vararg{Int, N}) where {T, N, D, RANGES}
    arrindex = get_arrindex(RANGES, I[D])
    @boundscheck begin
        if arrindex == 0
            throw(BoundsError(A, I))
        end
    end

    I = get_subarr_index(A, I, arrindex)
    A.members[arrindex, I...] = v
end

@generated function size(A::LazyCatArray{T, N, D, RANGES}) where {T, N, D, RANGES}
    mul_mask = ( (i == D ? 0 : 1 for i ∈ 1:N)..., )
    add_mask = ( (i == D ? sum(length.(RANGES)) : 0 for i ∈ 1:N)..., )
    :(size(A.members.x[1]) .* $mul_mask .+ $add_mask)
end

end #module

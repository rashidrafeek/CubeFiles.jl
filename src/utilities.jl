# ---------------------------
# Utilities specific to CubeSystem
# ---------------------------

"""
    value_at(cs::CubeSystem{3}, r::SVector{3,<:Real};
             mode::Symbol = :trilinear, outside::Symbol = :error)

`mode`:
- `:trilinear`  → trilinear interpolation (default)
- `:voxel`      → return value at the lower-corner grid node of the voxel containing `r`
- `:nearest`    → return value at the nearest grid node to `r`
"""
function value_at(cs::CubeSystem{3}, r::AbstractVector{<:Real};
                  mode::Symbol = :trilinear, outside::Symbol = :error)

    fld = cs.field
    A = SMatrix{3,3,Float64}(hcat(fld.axes...))
    ξ = A \ (SVector{3,Float64}(r) .- fld.origin)  # fractional indices (i,j,k)
    i, j, k = ξ
    nx, ny, nz = size(fld.values)

    inbounds = (0.0 ≤ i ≤ nx-1) & (0.0 ≤ j ≤ ny-1) & (0.0 ≤ k ≤ nz-1)
    if !inbounds
        if outside === :error
            throw(DomainError(r, "Point lies outside cube grid."))
        elseif outside === :NaN
            return NaN
        elseif outside === :clamp
            i = clamp(i, 0.0, nx-1); j = clamp(j, 0.0, ny-1); k = clamp(k, 0.0, nz-1)
        else
            throw(ArgumentError("unknown outside=:$(outside)"))
        end
    end

    if mode === :voxel
        # Lower-corner node of the containing voxel
        i0 = clamp(floor(Int, i), 0, nx-2)
        j0 = clamp(floor(Int, j), 0, ny-2)
        k0 = clamp(floor(Int, k), 0, nz-2)
        @inbounds return fld.values[i0+1, j0+1, k0+1]

    elseif mode === :nearest
        # Nearest grid node
        ii = clamp(round(Int, i), 0, nx-1)
        jj = clamp(round(Int, j), 0, ny-1)
        kk = clamp(round(Int, k), 0, nz-1)
        @inbounds return fld.values[ii+1, jj+1, kk+1]

    elseif mode === :trilinear
        i0 = clamp(floor(Int, i), 0, nx-2); di = i - i0
        j0 = clamp(floor(Int, j), 0, ny-2); dj = j - j0
        k0 = clamp(floor(Int, k), 0, nz-2); dk = k - k0

        V = fld.values
        @inbounds begin
            c000 = V[i0+1, j0+1, k0+1]
            c100 = V[i0+2, j0+1, k0+1]
            c010 = V[i0+1, j0+2, k0+1]
            c110 = V[i0+2, j0+2, k0+1]
            c001 = V[i0+1, j0+1, k0+2]
            c101 = V[i0+2, j0+1, k0+2]
            c011 = V[i0+1, j0+2, k0+2]
            c111 = V[i0+2, j0+2, k0+2]
        end

        c00 = (1-di)*c000 + di*c100
        c10 = (1-di)*c010 + di*c110
        c01 = (1-di)*c001 + di*c101
        c11 = (1-di)*c011 + di*c111
        c0  = (1-dj)*c00  + dj*c10
        c1  = (1-dj)*c01  + dj*c11
        return (1-dk)*c0 + dk*c1
    else
        throw(ArgumentError("unknown mode=:$(mode). Use :trilinear, :voxel, or :nearest"))
    end
end

# (x,y,z) convenience
value_at(cs::CubeSystem{3}, x::Real, y::Real, z::Real; kwargs...) =
    value_at(cs, SVector{3,Float64}(x, y, z); kwargs...)

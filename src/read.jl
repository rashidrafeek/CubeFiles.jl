# ---------------------------
# Cube reader (adapts your function)
# ---------------------------

"""
    readcube_field(filename; name=:ELF, metadata=(;))

Read a Gaussian-style .cube file and return a `CubeField{3,Float64}`.

Notes
- Uses **z-fastest, then y, then x** ordering (the standard in .cube files).
- Also parses origin and grid vectors from header lines.
- Atom block is parsed and stored in `metadata` for convenience.
"""
function readcube_field(filename::AbstractString; name::Symbol=:ELF, metadata::NamedTuple=(;))
    cubelines = readlines(filename)

    # Header (first 2 lines are comments)
    # Line 3: natoms, x0, y0, z0
    l3 = split(cubelines[3])
    natoms = parse(Int, l3[1])
    origin = SVector{3,Float64}(parse.(Float64, l3[2:4])...)

    # Line 4-6: nx, axx, axy, axz; ny, ayx, ayy, ayz; nz, azx, azy, azz
    function parse_axis(line)
        s = split(line)
        n = parse(Int, s[1])
        a = SVector{3,Float64}(parse.(Float64, s[2:4])...)
        return n, a
    end
    nx, ax = parse_axis(cubelines[4])
    ny, ay = parse_axis(cubelines[5])
    nz, az = parse_axis(cubelines[6])

    # Atom block: next natoms lines: Z charge x y z (format varies; we just store raw)
    atoms_raw = cubelines[7 : 6+natoms]

    # Data block: remaining lines are numbers; z fastest, then y, then x
    datalines = join(cubelines[6+natoms+1:end], " ")
    vals = parse.(Float64, split(datalines))

    # Fill values[ix,iy,iz] with correct linear index
    values = Array{Float64,3}(undef, nx, ny, nz)
    @inbounds begin
        l = 0
        for ix in 1:nx, iy in 1:ny, iz in 1:nz
            l += 1
            values[ix,iy,iz] = vals[l]
        end
    end
    # (equivalently: reshape(vals, (nz,ny,nx)) |> x->permutedims(x,(3,2,1)))

    meta = merge((; atoms_raw, natoms, nx, ny, nz, filename), metadata)
    return CubeField{3,Float64}(origin, (ax, ay, az), values, name, meta)
end

# Convenience constructors

"""
    CubeSystem(system::AtomsBase.AbstractSystem{3}, field::CubeField{3})

Attach a cube field to an existing 3D AtomsBase system.
"""
CubeSystem(system::AtomsBase.AbstractSystem{3}, field::CubeField{3}) =
    CubeSystem{3,typeof(system),typeof(field)}(system, field)

"""
    readcube_system(filename, system; name=:ELF, metadata=(;))

Read `filename` (.cube) and return `CubeSystem(system, field)`.
"""
function readcube_system(filename::AbstractString,
                         system::AtomsBase.AbstractSystem{3};
                         name::Symbol=:ELF,
                         metadata::NamedTuple=(;))
    fld = readcube_field(filename; name, metadata)
    return CubeSystem(system, fld)
end

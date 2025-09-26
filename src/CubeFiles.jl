module CubeFiles

using AtomsBase
using StaticArrays
import Unitful: ustrip

export CubeSystem, readcube_system

"""
    CubeField{T}

Minimal container for scalar-field data from a Gaussian .cube (or similar).

Fields:
- `origin::SVector{D,T}`: Cartesian origin of the grid (same units as positions)
- `axes::NTuple{D,SVector{D,T}}`: grid vectors a₁, a₂, ..., a_D (each length-D)
- `values::Array{T,3}`: 3D scalar field (Fortran-order typical of .cube)
- `name::Symbol`: identifier, e.g. :ELF, :density
- `metadata::NamedTuple`: free-form extras (units, comment, etc.)
"""
struct CubeField{D,T}
    origin::SVector{D,T}
    axes::NTuple{D,SVector{D,T}}
    values::Array{T,3}
    name::Symbol
    metadata::NamedTuple
end

"""
    CubeSystem{D,S,F} <: AtomsBase.AbstractSystem{D}

An `AtomsBase`-compatible system that packs an underlying `AbstractSystem`
together with a scalar field (e.g. ELF) read from a .cube file.
"""
struct CubeSystem{D,S<:AtomsBase.AbstractSystem{D},F} <: AtomsBase.AbstractSystem{D}
    system::S
    field::F
end

include("atomsbase.jl")
include("read.jl")
include("utilities.jl")


end

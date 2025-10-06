# AtomsBase interface

# Dimensions & basic system properties
AtomsBase.n_dimensions(::CubeSystem{D}) where {D} = D
AtomsBase.cell(sys::CubeSystem)                 = AtomsBase.cell(sys.system)
AtomsBase.cell_vectors(sys::CubeSystem)         = AtomsBase.cell_vectors(sys.system)
AtomsBase.periodicity(sys::CubeSystem)          = AtomsBase.periodicity(sys.system)
AtomsBase.set_cell!(sys::CubeSystem, c)         = (AtomsBase.set_cell!(sys.system, c); sys)
AtomsBase.set_cell_vectors!(sys::CubeSystem, bb)= (AtomsBase.set_cell_vectors!(sys.system, bb); sys)
AtomsBase.set_periodicity!(sys::CubeSystem, p)  = (AtomsBase.set_periodicity!(sys.system, p); sys)

# Atom-level getters / setters
Base.position(sys::CubeSystem, i)               = Base.position(sys.system, i)
AtomsBase.set_position!(sys::CubeSystem, i, x)  = (AtomsBase.set_position!(sys.system, i, x); sys)

AtomsBase.velocity(sys::CubeSystem, i)          = AtomsBase.velocity(sys.system, i)
AtomsBase.set_velocity!(sys::CubeSystem, i, v)  = (AtomsBase.set_velocity!(sys.system, i, v); sys)

AtomsBase.mass(sys::CubeSystem, i)              = AtomsBase.mass(sys.system, i)
AtomsBase.set_mass!(sys::CubeSystem, i, m)      = (AtomsBase.set_mass!(sys.system, i, m); sys)

AtomsBase.species(sys::CubeSystem, i)           = AtomsBase.species(sys.system, i)
AtomsBase.set_species!(sys::CubeSystem, i, s)   = (AtomsBase.set_species!(sys.system, i, s); sys)

AtomsBase.atomic_number(sys::CubeSystem, i)     = AtomsBase.atomic_number(sys.system, i)
AtomsBase.atomic_symbol(sys::CubeSystem, i)     = AtomsBase.atomic_symbol(sys.system, i)
AtomsBase.atom_name(sys::CubeSystem, i)         = AtomsBase.atom_name(sys.system, i)
AtomsBase.element(sys::CubeSystem, i)           = AtomsBase.element(sys.system, i)
AtomsBase.element_symbol(sys::CubeSystem, i)    = AtomsBase.element_symbol(sys.system, i)

# System-wide helpers
AtomsBase.chemical_formula(sys::CubeSystem)     = AtomsBase.chemical_formula(sys.system)
AtomsBase.visualize_ascii(sys::CubeSystem)      = AtomsBase.visualize_ascii(sys.system)

Base.length(sys::CubeSystem)                    = length(sys.system)

# System properties
function Base.keys(cs::CubeSystem)
    inner_keys = Base.keys(cs.system)
    cube_keys  = (:cube_name, :cube_origin, :cube_axes)
    # cube_keys  = (:cube_field, :cube_name, :cube_origin, :cube_axes, :cube_values)
    # meta_keys  = cs.field.metadata |> keys |> collect |> Tuple
    # return Tuple(unique!(collect(Iterators.flatten((inner_keys, cube_keys, meta_keys)))))
    return Tuple(unique!(collect(Iterators.flatten((inner_keys, cube_keys)))))
end

Base.haskey(cs::CubeSystem, k::Symbol) = (haskey(cs.system, k) || (k in keys(cs)))

function Base.getindex(cs::CubeSystem, k::Symbol)
    if haskey(cs.system, k)
        return cs.system[k]
    end
    return k === :cube_field  ? cs.field :
           k === :cube_name   ? cs.field.name :
           k === :cube_origin ? cs.field.origin :
           k === :cube_axes   ? cs.field.axes :
           k === :cube_values ? cs.field.values :
           (k in keys(cs.field.metadata)) ? cs.field.metadata[k] :
           throw(KeyError(k))
end
Base.getindex(cs::CubeSystem, i::Integer) = cs.system[i]

# Particle properties
AtomsBase.atomkeys(cs::CubeSystem)              = AtomsBase.atomkeys(cs.system)
AtomsBase.hasatomkey(cs::CubeSystem, k::Symbol) = AtomsBase.hasatomkey(cs.system, k)

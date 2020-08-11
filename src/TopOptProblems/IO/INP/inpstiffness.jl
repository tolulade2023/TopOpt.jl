"""
struct InpStiffness{dim, N, TF, TI, TBool, Tch <: ConstraintHandler, GO, TInds <: AbstractVector{TI}, TMeta<:Metadata} <: StiffnessTopOptProblem{dim, TF}
    inp_content::InpContent{dim, TF, N, TI}
    geom_order::Type{Val{GO}}
    ch::Tch
    black::TBool
    white::TBool
    varind::TInds
    metadata::TMeta
end

- `dim`: dimension of the problem
- `TF`: number type for computations and coordinates
- `N`: number of nodes in a cell of the grid
- `inp_content`: an instance of [`InpContent`](@ref) which stores all the information from the ``.inp` file.
- `geom_order`: a field equal to `Val{GO}` where `GO` is an integer representing the order of the finite elements. Linear elements have a `geom_order` of `Val{1}` and quadratic elements have a `geom_order` of `Val{2}`.
- `metadata`: Metadata having various cell-node-dof relationships
- `black`: a `BitVector` of length equal to the number of elements where `black[e]` is 1 iff the `e`^th element must be part of the final design
- `white`:  a `BitVector` of length equal to the number of elements where `white[e]` is 1 iff the `e`^th element must not be part of the final design
- `varind`: an `AbstractVector{Int}` of length equal to the number of elements where `varind[e]` gives the index of the decision variable corresponding to element `e`. Because some elements can be fixed to be black or white, not every element has a decision variable associated.
"""
struct InpStiffness{dim, N, TF, TI, TBool, Tch <: ConstraintHandler, GO, TInds <: AbstractVector{TI}, TMeta<:Metadata} <: StiffnessTopOptProblem{dim, TF}
    inp_content::InpContent{dim, TF, N, TI}
    geom_order::Type{Val{GO}}
    ch::Tch
    black::TBool
    white::TBool
    varind::TInds
    metadata::TMeta
end

"""
    InpStiffness(filepath::AbstractString; keep_load_cells = false)

Imports stiffness problem from a .inp file, e.g. `InpStiffness("example.inp")`. The `keep_load_cells` keyword argument will enforce that any cell with a load applied on it is to be part of the final optimal design generated by topology optimization algorithms.
"""
function InpStiffness(filepath_with_ext::AbstractString; keep_load_cells = false)
    problem = Parser.extract_inp(filepath_with_ext)
    return InpStiffness(problem; keep_load_cells = keep_load_cells)
end
function InpStiffness(problem::Parser.InpContent; keep_load_cells = false)
    ch = Parser.inp_to_juafem(problem)
    black, white = find_black_and_white(ch.dh)
    metadata = Metadata(ch.dh)
    geom_order = JuAFEM.getorder(ch.dh.field_interpolations[1])
    if keep_load_cells
        for k in keys(problem.cloads)
            for (c, f) in metadata.node_cells[k]
                black[c] = 1
            end
        end
    end
    varind = find_varind(black, white)
    return InpStiffness(problem, Val{geom_order}, ch, black, white, varind, metadata)
end

getE(p::InpStiffness) = p.inp_content.E
getν(p::InpStiffness) = p.inp_content.ν
nnodespercell(::InpStiffness{dim, N}) where {dim, N} = N
getgeomorder(p::InpStiffness{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, GO}) where {GO} = GO
getdensity(p::InpStiffness) = p.inp_content.density
getpressuredict(p::InpStiffness) = p.inp_content.dloads
getcloaddict(p::InpStiffness) = p.inp_content.cloads
getfacesets(p::InpStiffness) = p.inp_content.facesets

module Functions

using ..TopOpt: dim, whichdevice, CPU, GPU, TopOpt, PENALTY_BEFORE_INTERPOLATION
using ..TopOptProblems, ..FEA, ..CheqFilters
using ..Utilities, ForwardDiff, LinearAlgebra, Requires
using Parameters: @unpack
using TimerOutputs, Ferrite, StaticArrays
using StatsFuns, MappedArrays, LazyArrays
using ..TopOptProblems: getdh
using SparseArrays, Statistics, ChainRulesCore, Zygote
using Nonconvex: Nonconvex

export  Volume,
        Compliance,
        Displacement,
        MeanCompliance,
        BlockCompliance,
        AbstractFunction,
        getfevals,
        getmaxfevals,
        maxedfevals,
        MicroVonMisesStress,
        MacroVonMisesStress,
        project,
        generate_scenarios,
        hutch_rand!,
        hadamard!

const to = TimerOutput()

abstract type AbstractFunction{T} <: Nonconvex.AbstractFunction end

include("function_utils.jl")
include("compliance.jl")
include("displacement.jl")
include("volume.jl")
include("stress.jl")
include("trace.jl")
include("mean_compliance.jl")
include("block_compliance.jl")

end

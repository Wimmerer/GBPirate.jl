module GBPirate

import SparseArrays
using SuiteSparseGraphBLAS
import LinearAlgebra: mul!

function mul!(C::StridedVecOrMat{T}, A::SparseArrays.SparseMatrixCSC{T, Int64}, B::StridedVecOrMat{T}, α::Number, β::Number) where {T}
    Cgb = GBMatrix{T}(size(C))
    gbset(Cgb, :format, :bycol)
    gbset(Cgb, :sparsity_control, :full)
    Agb = GBMatrix{T}(size(A))
    SuiteSparseGraphBLAS._packcscmatrix!(Agb, A.colptr, A.rowval, A.nzval)
    SuiteSparseGraphBLAS._makeshallow!(Agb)
    
    Bgb = GBMatrix{T}(size(B))
    SuiteSparseGraphBLAS._packdensematrix!(Bgb, B)
    SuiteSparseGraphBLAS._makeshallow!(Bgb)

    mul!(Cgb, α .* Agb, Bgb; accum=+)
    Ctemp = SuiteSparseGraphBLAS._unpackdensematrix!(Cgb)
    copyto!(C, Ctemp)
    ccall(:jl_free, Cvoid, (Ptr{T},), pointer(Ctemp))
    return C
end
end

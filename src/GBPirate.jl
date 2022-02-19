module GBPirate

import SparseArrays
using SuiteSparseGraphBLAS
import LinearAlgebra: mul!

export gbmul!
function gbmul!(C::StridedVecOrMat{T}, A::SparseArrays.SparseMatrixCSC{T, Int64}, B::StridedVecOrMat{T}, α::Number, β::Number) where {T}
    
    Agb = GBMatrix{T}(size(A))
    SuiteSparseGraphBLAS._packcscmatrix!(Agb, A.colptr, A.rowval, A.nzval)
    SuiteSparseGraphBLAS._makeshallow!(Agb)
    
    Bgb = GBMatrix{T}(size(B))
    SuiteSparseGraphBLAS._packdensematrix!(Bgb, B)
    SuiteSparseGraphBLAS._makeshallow!(Bgb)
 
    Cgb = GBMatrix(size(C), convert(T, α))
    gbset(Cgb, :format, :bycol)
    gbset(Cgb, :sparsity_control, :full)
    mul!(Cgb, Agb, Bgb; accum=*)

    # Done with Agb and Bgb now.
    # They do not need to be unpacked since they're shallow.
    # But packing modified the index vectors of A.
    A.colptr .+= 1
    A.rowval .+= 1
    return Cgb
    Ctemp = SuiteSparseGraphBLAS._unpackdensematrix!(Cgb)

    if iszero(β)
        copyto!(C, Ctemp)
    else
        C .*= Ctemp
    end
    ccall(:jl_free, Cvoid, (Ptr{T},), pointer(Ctemp))
    return C
end
end

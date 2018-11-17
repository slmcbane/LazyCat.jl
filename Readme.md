LazyCat.jl
==========
This package provides a facility to concatenate arrays in a "lazy" manner (this is
somewhat of an abuse of terminology). `Base.cat` always allocates a new array to hold
the result; I wanted an array type that acted as a view of the parent arrays with them
joined into one whole, but shared the memory rather than allocating. This will be useful
when working with larger datasets (the motivation is postprocessing of global general
circulation model results).

Example
=======
```
julia> A = [1 2
       3 4]
2×2 Array{Int64,2}:
 1  2
 3  4

julia> B = [1 2
       3 4]
2×2 Array{Int64,2}:
 1  2
 3  4

julia> C = lazy_cat(A, B, dim=2)
2×4 LazyCat.LazyCatArray{Int64,2,2,(1:2, 3:4),RecursiveArrayTools.ArrayPartition{Int64,Tuple{Array{Int64,2},Array{Int64,2}}}}:
 1  2  1  2
 3  4  3  4

julia> C[1:2,1:2] .= 0
2×2 view(::LazyCat.LazyCatArray{Int64,2,2,(1:2, 3:4),RecursiveArrayTools.ArrayPartition{Int64,Tuple{Array{Int64,2},Array{Int64,2}}}}, 1:2, 1:2) with eltype Int64:
 0  0
 0  0

julia> A
2×2 Array{Int64,2}:
 0  0
 0  0

julia> C
2×4 LazyCat.LazyCatArray{Int64,2,2,(1:2, 3:4),RecursiveArrayTools.ArrayPartition{Int64,Tuple{Array{Int64,2},Array{Int64,2}}}}:
 0  0  1  2
 0  0  3  4
```

Copyright
=========
This package is Copyright 2018 Sean McBane, under the terms of the MIT License:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

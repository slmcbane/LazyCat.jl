LazyCat.jl
==========
This package provides a facility to concatenate arrays in a "lazy" manner (this is
somewhat of an abuse of terminology). `Base.cat` always allocates a new array to hold
the result; I wanted an array type that acted as a view of the parent arrays with them
joined into one whole, but shared the memory rather than allocating. This will be useful
when working with larger datasets (the motivation is postprocessing of global general
circulation model results).

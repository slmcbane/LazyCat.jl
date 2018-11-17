using LazyCat, Test

@testset "All tests" begin

    let A = [1 2
             3 4],
        B = [5 6
             7 8]

        @test lazy_cat(A, B) == [1 2
                                 3 4
                                 5 6
                                 7 8]
        @test lazy_cat(A, B, dim=2) == [1 2 5 6
                                        3 4 7 8]

        @test_throws LazyCat.NotImplementedError lazy_cat(A, B, dim=3)
    end

    let A = [1 2
             3 4],
        B = [5 6]

        @test lazy_cat(A, B) == [1 2
                                 3 4
                                 5 6]
        @test_throws ErrorException lazy_cat(A, B, dim=2)
    end

    let A = [1 2
             3 4],
        B = [5, 6]

        @test lazy_cat(A, B, dim=2) == [1 2 5
                                        3 4 6]
        @test_throws ErrorException lazy_cat(A, B)
    end

    let A = zeros(3, 3)
        B = zeros(3, 3, 2)

        @test_throws ErrorException lazy_cat(A, B, dim=1)
        C = lazy_cat(A, view(B, :, :, 1), dim=1)
        for i in 1:18 
            C[i] = i
        end

        @test A == [1 7 13
                    2 8 14
                    3 9 15]
        @test B == cat([4 10 16
                        5 11 17
                        6 12 18], zeros(3, 3), dims=(3,))
    end
end

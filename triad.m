function BbarN = triad(v1N, v2N, v1B, v2B)

    t1B = v1B;
    t2B = cross(v1B,v2B)/norm(cross(v1B,v2B));
    t3B = cross(t1B,t2B);

    t1N = v1N;
    t2N = cross(v1N,v2N)/norm(cross(v1N,v2N));
    t3N = cross(t1N,t2N);

    BbarT = [t1B t2B t3B];
    NT = [t1N t2N t3N];

    BbarN = BbarT*NT';

end
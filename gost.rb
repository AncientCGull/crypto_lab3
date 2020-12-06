require_relative 'point.rb'

class DSGOST

    attr_reader :q, :a, :m
    # m - int, EC module
    # a, b - int, EC coefficients
    # q - int, order of point P
    # x, y - int, point P coordinates
    def initialize(m, a, q, x, y)
        @point = Point.new(x, y, a, m)
        @q = q
        @a = a
        @m = m
    end

    # generate key pair
    def gen_keys()
        d = rand(1..@q - 1)
        q_point = @point * d
        return d, q_point
    end

    # sign message
    # message - int
    # private_key - int
    def sign(message, private_key, k=0)
        e = message % @q
        if e == 0
            e = 1
        end
        if k == 0
            k = rand(1..@q - 1)
        end
        r, s = 0, 0
        while r == 0 or s == 0
            c_point = @point * k
            r = c_point.x % @q
            s = (r * private_key + k * e) % @q
        end
        return r, s
    end

    # verify signed message
    # message - int
    # sign - tuple
    # public_key - ECPoint
    def verify(message, sign, public_key)
        e = message % @q
        if e == 0
            e = 1
        end
        nu = public_key.reverse(e, @q)
        z1 = (sign[1] * nu) % @q
        z2 = (-sign[0] * nu) % @q
        c_point = @point * z1 + public_key * z2
        r = c_point.x % @q
        if r == sign[0]
            return true
        end
        return false
    end
end
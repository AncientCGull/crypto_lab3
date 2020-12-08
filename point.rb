class Point
	require_relative 'curve.rb'
	include Curve
	attr_reader :x, :y, :a, :m

	def initialize(x, y, a, m)
		@x = x
		@y = y
		@a = a
		@m = m
	end

	def reverse (arg, mod)
		a, b = arg % mod, mod
	    u, uu = 1, 0
	    while b>0
	        q = a / b
	        a, b = b, a % b
	        u, uu = uu, u - uu*q
		end
	    if u < 0
	        u += mod * ((u.abs / mod) + 1)
		end
	    return u
	end

	def write()
		return "(#{x}, #{y})"
	end

	def +(point_Q)
		point_Q == INF ? (return self) : {}

		self == INF ? (return point_Q) : {}

		if @x == point_Q.x
			(@y + point_Q.y) % @m == 0 ? (return INF) : (return self.double)
		end

		l = ((@y - point_Q.y) * reverse(@x - point_Q.x, m)) % m
		c = (@y - l * @x) % @m
		qPx = (l * l - @x - point_Q.x) % m
		qPy = (- (l * qPx + c)) % m
		return Point.new(qPx, qPy, a, m)
	end

	def double()
		l = ((3 * @x * @x + @a) * reverse(2*@y, @m)) % @m
		x2 = (l * l - 2 * @x) % @m
		y2 = (l * (@x - x2) - @y) % @m
		return Point.new(x2, y2, a, m)
	end

	def *(other)
		p_result = Point.new(@x, @y, @a, @m)
        temp = Point.new(@x, @y, @a, @m)
        x = other - 1
        while x != 0 do
            if x % 2 != 0
                p_result += temp
				x -= 1
			end
            x /= 2
			temp = temp + temp
		end
		return p_result
	end

	def pi()
		return @x.to_s(2)
	end

	def isBelong()
		return @y.pow(2, m) == ((@x**3 + a*@x + Curve::B) % m)
	end
end

Inf = Float::INFINITY
INF = Point.new(Inf, Inf, Inf, Inf)
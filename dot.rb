class Dot
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

	def +(dotQ)
		dotQ == INF ? (return self) : {}

		self == INF ? (return dotQ) : {}

		if @x == dotQ.x
			(@y + dotQ.y) % @m == 0 ? (return INF) : (return self.double)
		end

		l = ((@y - dotQ.y) * reverse(@x - dotQ.x, m)) % m
		c = (@y - l * @x) % @m
		qPx = (l * l - @x - dotQ.x) % m
		qPy = (- (l * qPx + c)) % m
		return Dot.new(qPx, qPy, a, m)
	end

	def double()
		l = ((3 * @x * @x + @a) * reverse(2*@y, @m)) % @m
		x2 = (l * l - 2 * @x) % @m
		y2 = (l * (@x - x2) - @y) % @m
		return Dot.new(x2, y2, a, m)
	end

	def *(q)
		q = q.to_s(2).reverse
		temp = self
		res = 0
		i = q.length - 1
		while i >= 0 do
			if q[i] == "1"
				for j in (1..i)
					temp = temp.double
				end
				res == 0 ? res = temp : res = res + temp
				temp = self
			end
			i -= 1
		end
		return res
	end

	def pi()
		return @x.to_s(2)
	end

	def isBelong()
		return @y.pow(2, m) == ((@x**3 + a*@x + Curve::B) % m) ? true : false
	end
end

Inf = Float::INFINITY
INF = Dot.new(Inf, Inf, Inf, Inf)
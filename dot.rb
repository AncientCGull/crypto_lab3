class Dot
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

	def sumEC (qx, qy, mod)
		temp = reverse(@x - qx, m)
		l = ((@y - qy) * temp) % m
		c = (@y - l * @x) % m
		qPx = (l * l - @x - qx) % m
		qPy = (-1 * (l * qPx + c)) % m
		return Dot.new(qPx, qPy, m)
	end

	def +(dotQ)
		temp = reverse(@x - dotQ.x, m)
		l = ((@y - dotQ.y) * temp) % m
		c = (@y - l * @x) % m
		qPx = (l * l - @x - dotQ.x) % m
		qPy = (-1 * (l * qPx + c)) % m
		return Dot.new(qPx, qPy, a, m)
	end

	def double()
		temp = reverse(2*@y, @m)
		l = ((3 * @x * @x + @a) * temp) % @m
		c = (@y - l * @x) % @m
		x2 = (l * l - 2 * @x) % @m
		y2 = (-(l * x2 + c)) % @m
		return Dot.new(x2, y2, a, m)
	end
end
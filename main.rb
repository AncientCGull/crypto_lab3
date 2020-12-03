require 'benchmark'
require_relative 'dot.rb'
require_relative 'curve.rb'
include Curve

def gcd(a, b)
	a, b = b, a % b until b.zero?
	a.abs
end

def isPrimeLog(x)
	seed = Random.new_seed
	for i in 0..100
		a = (rand(seed) % (x - 2)) + 2
		if gcd(a, x) != 1
			return false
		end
		if (a.pow(x-1, x) != 1)
			return false
		end
	end
	return true
end

def getPrimeBase(bits)
	prime = rand(2**(bits-1)..2**bits-1)
	if prime % 2 == 0
		prime += 1
	end
	while (not isPrimeLog(prime))
		prime += 2
		if (prime > 2**bits-1)
			return getPrimeBase(bits)
		end
	end
	return prime
end

def reverse (a, mod)
	i = 0
	begin
		rev = a ** i % mod
		i+=1
	end while not (rev * a % mod).equal?(1)
	return rev
end

def Lejandr(a, q)
	if a == 1
		return 1
	end

	if a % 2 == 1
		return (-1)**((q-1)*(a-1)/4) * (q%a)/a
	end

	return (-1)**((q**2-1)/8) * (a/2)/q
end


#dotP = Dot.new(Curve::X, Curve::Y, Curve::A, Curve::M)
#puts "#{dotP.write()} + #{dotP.write()} = #{(dotP+dotP).write()}"
#puts "#{dotP.write()} * 2 = #{dotP.double().write()}"

#puts (dotP + dotP).write() == dotP.double().write()

#dotP.doubleEC(Curve::X, Curve::Y, Curve::A, Curve::M)

dot = Dot.new(19, 11, 26, 31)
puts (Dot.new(10, 11, 15, 23) + Dot.new(14, 4, 15, 23)).write
puts (dot + dot).write()
puts dot.double().write()


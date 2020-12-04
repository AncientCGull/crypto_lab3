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

def Lejandr(a, q)
	a == 1 ? (return 1) : {}

	puts a
	puts q

	return a.odd? ? ((-1)**((q-1)*(a-1)/4) * (q%a)/a) : ((-1)**((q**2-1)/8) * (a/2)/q)
end


dot = Dot.new(Curve::X, Curve::Y, Curve::A, Curve::M)

k = rand(Curve::M-1)
puts k.to_s(2).length()

#bench = Benchmark.measure { puts (dot * k).write()}
#puts bench.real()

lej = Lejandr(Curve::Q, Curve::M)
puts lej

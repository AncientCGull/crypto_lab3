require 'benchmark'
require 'digest'
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

def idGen()
	return (getPrimeBase(64)).to_s(2)
end

def check(id, dotK)
	return (dotK.isBelong() and (dotK * Curve::H != 0))
end


dotP = Dot.new(Curve::X, Curve::Y, Curve::A, Curve::M)

kA = rand(Curve::M-1)
dotKa = dotP * kA
puts "kA = #{kA}, KA = #{dotKa.write()}" # 1)

idA = idGen() # 2)
puts "Отправляем (idA, KA)"

printf "Проверяем... " # 3)
puts check(idA, dotKa) ? "выполнено" : return

kB = rand(Curve::M-1)
dotKb = dotP * kB # 4)
puts "kB = #{kB}, KA = #{dotKb.write()}"

dotQab = dotKb * Curve::H # 5)
puts "QAB = #{dotQab.write()}"

idB = idGen()
str = dotQab.pi + idA + idB
tAB = (Digest::SHA512.hexdigest str).to_i(16).to_s(2) # 6)
puts "TAB = #{tAB}"

kAB = tAB.slice(0..255)
mAB = tAB.slice(256..511) #7)
puts kAB.length() == mAB.length()

#bench = Benchmark.measure { puts (dot * k).write()}
#puts bench.real()

#lej = Lejandr(Curve::Q, Curve::M)
#puts lej

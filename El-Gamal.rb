require 'benchmark'
require 'digest'

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

def gcd(a, b)
	a, b = b, a % b until b.zero?
	a.abs
end

def findRootV2(m, b)
	g = 1
	while g == 1
		g = rand(2..m - 1).pow((m - 1) / b, m)
	end
	return g;
end

def getK(p)
	k = rand(p-3) + 2
	if gcd(k, p-1) == 1
		return k
	else
		return getK(p)
	end
end

def inverse_modulo(arg, mod)
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

module ElGamal
	class Sign
		attr_accessor :r, :s, :prime, :g, :b, :m, :y
	
		def initialize(r, s, prime, g, b, text, y)
			@r, @s = r, s
			@prime, @g = prime, g
			@b, m = @b, (Digest::SHA1.hexdigest text).to_i(16) % prime
			@y = y
		end
	end

	def sign(text)
		bitsGlobal = 512
		prime  = 10
		i = 0
		dega = 0
		degb = 0
		degc = 0
		while (not isPrimeLog(prime) and 
			not (2**(bitsGlobal-1) <= prime and 
				prime <= 2**bitsGlobal-1)) do
			dega = 0
			degb = 0
			degc = 0
	
			bits = bitsGlobal
			bitsA = 2
			bitsB = bitsGlobal / 10
			while (bits > bitsGlobal/2) do
				bits -= bitsB
				degb += 1
			end
	
			bitsC = (bitsGlobal - bits) / 50
			if (bitsC % 2 != bitsGlobal % 2)
				bitsC -=1
			end
			while (bits > 2)
				bits -= bitsC
				degc += 1
			end
			bits += bitsC
			degc -= 1
	
			while (bits > 0)
				bits -= 2
				dega += 1
			end
	
			a = 2
			b = getPrimeBase(bitsB)
			c = getPrimeBase(bitsC)
		
			prime = a**dega * b**degb * c**degc + 1
			bits = bitsGlobal
			i += 1
		end
		if (isPrimeLog(prime) == false)
			return sign(text)
		end
	
		g = findRootV2(prime, b)
		x = getK(prime)
		y = g.pow(x, prime)
		k = getK(prime)
		m = (Digest::SHA1.hexdigest text).to_i(16) % prime
		r = g.pow(k, prime) % b
		s = ((m - x*r) * inverse_modulo(k, b)) % (b)
	
		return Sign.new(r, s, prime, g, b, text, y)
	end
	
	def checkSign(sign)
		inverse_s = inverse_modulo(sign.s, sign.b)
		lhs = (sign.g.pow(sign.m * inverse_s, sign.prime) * 
			inverse_modulo(sign.y.pow(sign.r * inverse_s, sign.prime), sign.prime)) % sign.prime % sign.b
		if sign.r == lhs
			puts "Подпись верна"
			return true
		else
			puts "Ошибка подписи"
			return false
		end
	end
end

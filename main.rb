require 'benchmark'
require 'digest'
require 'OpenSSL'
require_relative 'dot.rb'
require_relative 'curve.rb'
require_relative 'El-Gamal.rb'
include Curve
include ElGamal

def idGen()
	bits = 64
	return rand(2**(bits-1)..2**bits-1).to_s(2)
end

def check(id, dotK)
	return (dotK.isBelong and (dotK * Curve::H != 0))
end


dotP = Dot.new(Curve::X, Curve::Y, Curve::A, Curve::M)

puts "Step 1"
kA = rand(Curve::M-1)
dotKa = dotP * kA
puts "kA = #{kA}" # 1)
puts "K_A = #{dotKa.write}"
puts

puts "Step 2"
idA = idGen # 2)
puts "Отправляем (idA, KA)"
puts

puts "Step 3"
printf "Проверяем... " # 3)
puts check(idA, dotKa) ? "выполнено" : return
puts

puts "Step 4"
kB = rand(Curve::M-1)
dotKb = dotP * kB # 4)
puts "kB = #{kB}"
puts "K_A = #{dotKb.write}"
puts

puts "Step 5"
dotQab = dotKa * kB # 5)
dotQab = dotQab * Curve::H
puts "Q_AB = #{dotQab.write}"
puts

puts "Step 6"
idB = idGen
str = dotQab.pi + idA + idB
tAB = (Digest::SHA512.hexdigest str).to_i(16).to_s(2)
puts "T_AB = #{tAB}" # 6)
puts tAB.length
puts

puts "Step 7"
kAB = tAB.slice(0..255)
mAB = tAB.slice(256..511) #7)
puts "K_AB = #{kAB}"
puts "M_AB = #{mAB}"
puts

puts "Step 8"
str = dotKb.pi + dotKa.pi + idA
aut = ElGamal::sign(str)
puts "Подпись -- пара (#{aut.r}, #{aut.s})"
str = dotKb.pi + dotKa.pi + idB + idA
tag = OpenSSL::HMAC.hexdigest("SHA512", mAB, str)
puts "tag = #{tag}"

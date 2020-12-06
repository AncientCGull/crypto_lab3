require 'benchmark'
require 'digest'
require 'OpenSSL'
require_relative 'point.rb'
require_relative 'curve.rb'
require_relative 'El-Gamal.rb'
require_relative 'gost.rb'
include Curve
include ElGamal

def idGen()
	bits = 64
	return rand(2**(bits-1)..2**bits-1).to_s(2)
end

def check(point_K)
	return (point_K.isBelong and (point_K * Curve::H != 0))
end


point_P = Point.new(Curve::X, Curve::Y, Curve::A, Curve::M)

puts "Step 1"
kA = rand(Curve::M-1)
point_Ka = point_P * kA
puts "kA = #{kA}" # 1)
puts "K_A = #{point_Ka.write}"
puts

puts "Step 2"
idA = idGen # 2)
puts "Отправляем (idA, KA)"
puts

puts "Step 3"
printf "Проверяем... " # 3)
puts check(point_Ka) ? "выполнено" : return
puts

puts "Step 4"
kB = rand(Curve::M-1)
point_Kb = point_P * kB # 4)
puts "kB = #{kB}"
puts "K_A = #{point_Kb.write}"
puts

puts "Step 5"
point_Qab = point_Ka * kB # 5)
point_Qab = point_Qab * Curve::H
puts "Q_AB = #{point_Qab.write}"
puts

puts "Step 6"
idB = idGen
str = point_Qab.pi + idA + idB
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
str = point_Kb.pi + point_Ka.pi + idA
gost = DSGOST.new(Curve::M, Curve::A, Curve::Q, Curve::X, Curve::Y)
d, publicPoint = gost.gen_keys
aut = gost.sign(str.to_i(2), d)
#aut = ElGamal::sign(str)
puts "Подпись -- пара (#{aut[0]}, #{aut[1]})"
str = point_Kb.pi + point_Ka.pi + idB + idA
tag = OpenSSL::HMAC.hexdigest("SHA512", mAB, str)
puts "tag = #{tag}"
puts

puts "Step 11"
str = point_Kb.pi + point_Ka.pi + idA
printf "Проверяем... "
puts gost.verify(str.to_i(2), aut, publicPoint) ? "подпись верна" : return
puts 

puts "Step 12"
printf "Проверяем... "
puts check(point_Kb) ? "выполнено" : return
puts

puts "Step 13"
point_Qba = point_Kb * Curve::H * kA
puts "Q_BA = #{point_Qba.write}"
puts
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
h2 = idGen
h3 = idGen

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
str = h2 + point_Kb.pi + point_Ka.pi + idB + idA
tagB = OpenSSL::HMAC.hexdigest("SHA512", mAB, str)
puts "tagB = #{tagB}"
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

puts "Step 14"
str = point_Qba.pi + idA + idB
tBA = (Digest::SHA512.hexdigest str).to_i(16).to_s(2)
puts "T_BA = #{tBA}"
puts

puts "Step 15"
kBA = tBA.slice(0..255)
mBA = tBA.slice(256..511)
puts "K_AB = #{kBA}"
puts "M_AB = #{mBA}"
puts

puts "Step 16"
str = h2 + point_Kb.pi + point_Ka.pi + idB + idA
tag_B = OpenSSL::HMAC.hexdigest("SHA512", mBA, str)
puts "tag_ = #{tag_B}"
printf "Метки подтверждения ключа... "
puts tagB == tag_B ? "совпадают" : return
puts

puts "Step 17"
str = h3 + point_Ka.pi + point_Kb.pi + idA + idB
tagA = OpenSSL::HMAC.hexdigest("SHA512", mBA, str)
puts "tagA = #{tagA}"
puts

puts "Step 19"
str = h3 + point_Ka.pi + point_Kb.pi + idA + idB
tag_A = OpenSSL::HMAC.hexdigest("SHA512", mAB, str)
puts "tag_A = #{tag_A}"
printf "Метки подтверждения ключа... "
puts tagA == tag_A ? "совпадают" : return
puts 

puts "Выработанный общий ключ:"
puts kAB == kBA ? kAB : return

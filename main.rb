require 'benchmark'
require_relative 'point.rb'
require_relative 'curve.rb'
require_relative 'gost.rb'
require_relative 'alice.rb'
require_relative 'bob.rb'
include Curve

def idGen()
	bits = 64
	return rand(2**(bits-1)..2**bits-1).to_s(2)
end

def check(point_K)
	return (point_K.isBelong and (point_K * Curve::H != 0))
end


def main
	point_P = Point.new(Curve::X, Curve::Y, Curve::A, Curve::M)
	h2 = idGen
	h3 = idGen

	alice = Alice.new(point_P, h2, h3)
	bob = Bob.new(point_P, h2, h3)

	alice.step1
	idA, point_Ka = alice.step2_send

	bob.step3(idA, point_Ka)
	bob.step4
	bob.step5
	bob.step6
	bob.step7
	publicPoint = bob.step8
	idB, cert, point_Kb, aut, tagB = bob.step9_send

	alice.step10(idB, cert, point_Kb, aut, tagB)
	alice.step11(publicPoint)
	alice.step12
	alice.step13
	alice.step14
	alice.step15
	alice.step16
	alice.step17
	tagA = alice.step18_send

	bob.step19(tagA)
	bob.step20
	alice.step20

	alice.getKey == bob.getKey ? (puts "Выработанный общий ключ: #{alice.getKey}") : (abort "Ошибка нахождения общего ключа")
end

bench = Benchmark::measure {main}
puts bench.real
require 'digest'
require 'OpenSSL'
require_relative 'point.rb'
require_relative 'curve.rb'
require_relative 'gost.rb'
include Curve

class Alice
    attr_reader :point_P, :point_Ka, :point_Kb, :point_Qba
    attr_reader :kA, :kBA, :mBA, :aut
    attr_reader :tagA, :tag_, :tag_B, :tagB 
    attr_reader :tBA, :h2, :h3
    attr_reader :idA, :idB

    def initialize(point_P, h2, h3)
        @point_P = point_P
        @h2, @h3 = h2, h3
    end

    def idGen()
        bits = 64
        return rand(2**(bits-1)..2**bits-1).to_s(2)
    end

    def step1()
        puts "Step 1 (Alice)"
        @kA = rand(Curve::M-1)
        @point_Ka = @point_P * @kA
        puts "kA = #{kA}"
        puts "K_A = #{point_Ka.write}"
        puts    
    end

    def step2_send()
        puts "Step 2 (Alice)"
        @idA = idGen
        puts "Отправляем (idA, KA)"
        puts
        return @idA, @point_Ka
    end

    def checkSert(cert)
        return cert
    end

    def step10(idB, cert, point_Kb, aut, tagB)
        @idB = idB
        @point_Kb = point_Kb
        @aut = aut
        @tagB = tagB
        checkSert(cert) ? (puts "Сертификат валиден (Alice)") : (abort "Ошибка валидности сертификата")
        puts
    end

    def step11(publicPoint)
        puts "Step 11 (Alice)"
        str = @point_Kb.pi + @point_Ka.pi + @idA
        printf "Проверяем... "
        gost = DSGOST.new(Curve::M, Curve::A, Curve::Q, Curve::X, Curve::Y)
        puts gost.verify(str.to_i(2), @aut, publicPoint) ? "подпись верна" : (abort "подпись недействительно")
        puts 
    end

    def step12()
        puts "Step 12 (Alice)"
        printf "Проверяем... "
        puts check(@point_Kb) ? "выполнено" : (abort "не выполнено")
        puts
    end

    def step13()
        puts "Step 13 (Alice)"
        @point_Qba = @point_Kb * Curve::H * @kA
        puts "Q_BA = #{@point_Qba.write}"
        puts
    end

    def step14()
        puts "Step 14 (Alice)"
        str = @point_Qba.pi + @idA + @idB
        @tBA = (Digest::SHA512.hexdigest str).to_i(16).to_s(2).rjust(512, '0')
        puts "T_BA = #{@tBA}"
        puts
    end

    def step15()
        puts "Step 15 (Alice)"
        @kBA = @tBA.slice(0..255)
        @mBA = @tBA.slice(256..511)
        puts "K_AB = #{@kBA}"
        puts "M_AB = #{@mBA}"
        puts
    end

    def step16 ()
        puts "Step 16 (Alice)"
        str = @h2 + @point_Kb.pi + @point_Ka.pi + @idB + @idA
        @tag_B = OpenSSL::HMAC.hexdigest("SHA512", @mBA, str)
        puts "tag_ = #{tag_B}"
        printf "Метки подтверждения ключа... "
        puts @tagB == @tag_B ? "совпадают" : (abort "не сходятся")
        puts
    end

    def step17()
        puts "Step 17 (Alice)"
        str = @h3 + @point_Ka.pi + @point_Kb.pi + @idA + @idB
        @tagA = OpenSSL::HMAC.hexdigest("SHA512", @mBA, str)
        puts "tagA = #{@tagA}"
        puts
    end

    def step18_send()
        return @tagA
    end

    def step20()
        puts "Step 20 (Alice)"
        puts "Удаление M_BA"
        @mBA.clear
    end

    def getKey()
        return @kBA
    end
end
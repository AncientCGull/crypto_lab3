class Bob
    attr_reader :point_P, :point_Ka, :point_Kb, :point_Qab
    attr_reader :kB, :kAB, :mAB, :aut
    attr_reader :tag_A, :tagA, :tag_B, :tagB 
    attr_reader :tAB, :h2, :h3, :d
    attr_reader :idA, :idB

    def initialize(point_P, h2, h3)
        @point_P = point_P
        @h2, @h3 = h2, h3
    end

    def check(point_K)
        return (point_K.isBelong and (point_K * Curve::H != 0))
    end

    def step3(idA, point_Ka)
        @idA, @point_Ka = idA, point_Ka
        puts "Step 3 (Bob)"
        printf "Проверяем... " 
        puts check(@point_Ka) ? "выполнено" : (abort "не выполнено")
        puts
    end

    def step4()
        puts "Step 4 (Bob)"
        @kB = rand(Curve::M-1)
        @point_Kb = @point_P * kB # 4)
        puts "kB = #{@kB}"
        puts "K_A = #{@point_Kb.write}"
        puts
    end

    def step5()
        puts "Step 5 (Bob)"
        @point_Qab = @point_Ka * @kB # 5)
        @point_Qab = @point_Qab * Curve::H
        puts "Q_AB = #{@point_Qab.write}"
        puts
    end

    def step6()
        puts "Step 6 (Bob)"
        @idB = idGen
        str = @point_Qab.pi + @idA + @idB
        @tAB = (Digest::SHA512.hexdigest str).to_i(16).to_s(2).rjust(512, '0')
        puts "T_AB = #{@tAB}" # 6)
        puts
    end

    def step7()
        puts "Step 7 (Bob)"
        @kAB = @tAB.slice(0..255)
        @mAB = @tAB.slice(256..511) #7)
        puts "K_AB = #{@kAB}"
        puts "M_AB = #{@mAB}"
        puts
    end

    def step8()
        puts "Step 8 (Bob)"
        str = @point_Kb.pi + @point_Ka.pi + @idA
        gost = DSGOST.new(Curve::M, Curve::A, Curve::Q, Curve::X, Curve::Y)
        @d, @publicPoint = gost.gen_keys
        @aut = gost.sign(str.to_i(2), d)
        #aut = ElGamal::sign(str)
        puts "Подпись -- пара (#{aut[0]}, #{aut[1]})"
        str = @h2 + @point_Kb.pi + @point_Ka.pi + @idB + @idA
        @tagB = OpenSSL::HMAC.hexdigest("SHA512", @mAB, str)
        puts "tagB = #{@tagB}"
        puts
        return @publicPoint
    end

    def step9_send()
        puts "Step 9"
        puts "Передача параметров"
        puts
        @cert = true
        return @idB, @cert, @point_Kb, @aut, @tagB
    end

    def step19(tagA)
        puts "Step 19 (Bob)"
        str = @h3 + @point_Ka.pi + @point_Kb.pi + @idA + @idB
        @tag_A = OpenSSL::HMAC.hexdigest("SHA512", @mAB, str)
        puts "tag_A = #{@tag_A}"
        printf "Метки подтверждения ключа... "
        puts tagA == @tag_A ? "совпадают" : (abort "не сходятся")
        puts 
    end

    def step20()
        puts "Step 20 (Bob)"
        puts "Удаление M_AB"
        @mAB.clear
    end

    def getKey()
        return @kAB
    end
end
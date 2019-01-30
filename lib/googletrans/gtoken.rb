require "http"

module Googletrans
  class Token
    @@tkks = {}

    def initialize query,service_url
      @service_url = service_url
      @query = query
      if config
        @persistent = config.first || persistent
      else
        @persistent = persistent
      end
      init
    end

    def token
      {token:acquire,persistent:@persistent}
    end

    private
    def init
      if config and config.last.split('.').first == now
        return @tkk = config.last
      end
      @tkk = tkk
      @@tkks[@service_url] = [@persistent,@tkk]
    end

    def tkk
      @persistent.get("/").to_s.match(%r{tkk:'\d+.\d+'}).to_s.split("'")[1]
    end

    def config
      @@tkks[@service_url]
    end

    def now
      (Time.now.to_f / 3600).to_i.to_s
    end

    def acquire
      ints = @query.split('').map { |e| e.ord }
      t = @tkk.split('.').map { |e| e.to_i }
      a = t.first
      add(ints).each do |i|
        a = xr(a + i,'+-a^+6')
      end
      a = xr(a,'+-3^+b+-f')
      a ^= t.last
      a = (a & 2147483647) + 2147483648 if a < 0
      a %= 1000000
      "#{a}.#{a ^ t.first}"
    end

    def persistent
      HTTP.follow.persistent @service_url
    end

    def add arr
      result = []
      while (g ||= 0) < arr.size
        l = arr[g]
        if l < 128
          result << l
        else
          if l < 2048
            result << (l >> 6 | 192)
          else
            if (l & 64512) == 55296 and arr.last != l and arr[g + 1] & 64512 == 56320
              g += 1
              l = 65536 + ((l & 1023) << 10) + (arr[g] & 1023)
              result << (l >> 18 | 240)
              result << (l >> 12 & 63 | 128)
            else
              result << (l >> 12 | 224)
            end
            result << (l >> 6 & 63 | 128)
          end
          result << (l & 63 | 128)
        end
        g += 1
      end
      result
    end

    def rshift val,n
      (val % 0x100000000) >> n
    end

    def xr a,b
      while (c ||= 0 ) < b.size - 2
        d = b[c + 2]
        d = 'a' <= d ? d[0].ord - 87 : d.to_i
        d = '+' == b[c + 1] ? rshift(a, d) : a << d
        a = '+' == b[c] ? a + d & 4294967295 : a ^ d
        c += 3
      end
      a
    end
  end
end

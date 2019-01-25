require "googletrans/version"
require "googletrans/translator"
require "googletrans/gtoken"

module Googletrans
  class Error < StandardError; end
  class << self
    def translator query,dest,src="auto",params={}
      build(params).translator query,src,dest
    end
    private
    def build params={}
      Googletrans::Translator.new params
    end
  end
end

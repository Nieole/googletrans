require 'json'
require "googletrans/gtoken"

module Googletrans
  class Translator
    LANGUAGES = ['af','sq','am','ar','hy','az','eu','be','bn','bs','bg','ca','ceb','ny','zh-cn','zh-tw','co','hr','cs','da','nl','en','eo','et','tl','fi','fr','fy','gl','ka','de','el','gu','ht','ha','haw','iw','hi','hmn','hu','is','ig','id','ga','it','ja','jw','kn','kk','km','ko','ku','ky','lo','la','lv','lt','lb','mk','mg','ms','ml','mt','mi','mr','mn','my','ne','no','ps','fa','pl','pt','pa','ro','ru','sm','gd','sr','st','sn','sd','si','sk','sl','so','es','su','sw','sv','tg','ta','te','th','tr','uk','ur','uz','vi','cy','xh','yi','yo','zu','fil','he','auto']
    HTTP_OR_HTTPS_RE = %r{^https?://}i

    def initialize(argument = {})
      @service_urls = argument[:service_urls] ||= ['translate.google.cn']
      @user_agent = argument[:user_agent] ||= 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
      @service_urls.map! { |e| (e =~ HTTP_OR_HTTPS_RE) ? e : "https://#{e}" }
    end

    def translator query,src='auto',dest
      raise "src is wrong" unless LANGUAGES.include? src
      raise "dest is wrong" unless LANGUAGES.include? dest
      return query.map { |e| translator e,src,dest } if query.class == Array
      url = service_url
      token = Token.new(query,url).token
      response = token[:persistent].get "/translate_a/single",:params => build_params(query:query,src:src,dest:dest,token:token[:token])
      raise "request failed" unless response.status.success?
      json = JSON.parse response.body.to_s
      translated = json&.first&.map { |e| e&.first }.join
      {query:query,translated:translated,src:json[2],dest:dest}
    end

    private
    def service_url
      @service_urls.sample
    end

    def build_params params = {}
      {
        'client': 'webapp',
        'sl': params[:src],
        'tl': params[:dest],
        'hl': params[:dest],
        'dt': ['at', 'bd', 'ex', 'ld', 'md', 'qca', 'rw', 'rm', 'ss', 't'],
        'ie': 'UTF-8',
        'oe': 'UTF-8',
        'otf': 1,
        'ssel': 0,
        'tsel': 0,
        'tk': params[:token],
        'q': params[:query],
      }
    end

  end
end

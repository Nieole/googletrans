RSpec.describe Googletrans do
  it "has a version number" do
    expect(Googletrans::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(true).to eq(true)
  end

  it "it's worked" do
    translated = Googletrans::Translator.new.translator(source = "hello",dest = 'zh-cn')
    expect(translated).not_to be nil
  end

  it "translate english to chinese" do
    translated = Googletrans::Translator.new.translator(source = "hello",dest = 'zh-cn')
    expect(translated[:translated]).to eq("你好")
  end

  it "it's can translator array" do
    source = ['hello','world']
    translated = Googletrans::Translator.new.translator(source=source,dest='zh-cn')
    expect(translated.class).to eq(Array)
  end
end

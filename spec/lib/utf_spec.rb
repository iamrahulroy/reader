require 'spec_helper'
describe "utf crashyness" do

  let(:body) { File.open("#{Rails.root}/spec/support/fixtures/bad-encoding.xml", "r", :encoding => "UTF-8").read }

  it "shouldn't crash" do
    (/\<rss|\<rdf/ =~ body) && (/feedburner/ =~ body)
    parsed_feed = Feedzirra::Feed.parse(body)
    ap parsed_feed
  end
end
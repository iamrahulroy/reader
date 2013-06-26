require "spec_helper"


describe Entry do


  end
  # let :entry do
  #   attributes = {
  #     guid: "123",
  #     url: "http://www.example.com/",
  #     source_id: feed.id,
  #     source_type: 'Feed',
  #     published_at: Date.current
  #   }

  #   Entry.new(attributes)
  # end

  # let :feed do
  #   attributes = {
  #     name: "Feed 1",
  #     feed_url: "http://boingboing.net/foo.rss",
  #     site_url: "http://boingboing.net/"
  #   }
  #   Feed.create!(attributes)
  # end


#   describe "#sanitize_content" do
#     it "should fix img srcs" do
#       entry.content = <<END
# <img class="img-rounded" src="/assets/pages/2662/michael_tubbs_truman_scholar_2011.jpg" alt="michael_tubbs_truman_scholar_2011.jpg" width="200">

# <img src="http://boingboing.net/wp-content/uploads/2013/01/Is3uy1.jpg" alt="" title="lockdown" class="size-full wp-image-138212">
# END

#       entry.save!
#       entry.content.should include 'src="http://boingboing.net/assets'
#     end
#   end

#   describe "#save" do
#     it "creates an entry guid model and updates the reference" do
#       entry.save!
#       entry.reload.entry_guid.should_not be_nil
#       entry_guid = EntryGuid.last
#       entry.reload.entry_guid.should == entry_guid
#       entry_guid.destroy
#       entry.reload.entry_guid.should == nil
#       entry.ensure_entry_guid_exists
#       entry_guid = EntryGuid.last
#       entry.reload.entry_guid.should == entry_guid
#     end
#   end

end

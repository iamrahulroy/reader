class Growler
  def self.log(msg, sticky=false)
    GNTP.notify(
      :app_name => "Reader",
      :title    => "Reader",
      :text     => msg,
      :icon  => "http://1kpl.us/favicon.png",
    )
  end
end
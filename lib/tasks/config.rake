namespace :config do
  desc "Copy all of the template files"
  task :copy do
    puts "Starting task"
    Dir["**/*.template"].each do |path|
      puts "Reading #{path}"
      content = File.read(path)
      puts "Rendering #{path}"
      rendered = ERB.new(content).result(binding)
      puts "Copying #{filename_from(path)} to #{real_filename(path)}..."
      File.open path.gsub('.template', ''), 'w' do |file|
        file.write rendered
      end
    end
  end

  def ask_for(variable)
    puts "What is your #{variable}? (Enter to skip)"
    STDIN.gets.chomp!
  end

  def secret_token
    SecureRandom.hex(64)
  end

  def filename_from(path)
    path.split("/").last
  end

  def real_filename(path)
    filename_without_template filename_from path
  end

  def filename_without_template(name)
    name.gsub('.template', '')
  end
end

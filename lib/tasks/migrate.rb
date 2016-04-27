Dir.glob(Rakuda.root.join("lib").join("migrate").join("*.rb")).each do |file|
  require file
end

puts "[start migrate]=============#{Time.now}"

Migrates.each do |k, v|
  puts "#{k} -> #{v}"
end
puts "maintenance"

puts "[finish migrate]=============#{Time.now}"

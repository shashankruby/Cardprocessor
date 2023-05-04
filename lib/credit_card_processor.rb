require "luhn"
require "pry"

class CreditCardProcessor
  def initialize(file)
    @file = file
  end

  def process
    output = []
    file = File.open(@file, "r")
    file.each_line do |line|
      data = line.split(' ')
      case data[0]
      when 'Add'
        output << add_card(data)
      when 'Charge'
        charge(data, output)
      when 'Credit'
        credit(data, output)
      end
    end
    # binding.pry
    # puts output
    file.close
    result(output)
  end
  
  private
  
  def add_card(data)
    add_data = { name: data[1], type: data[2], balance: 0, cc_num: data[3], limit: data[4].delete('$').to_i }
    add_data[:balance] = 'error' unless Luhn.valid?(data[3])
    add_data
  end
  
  def charge(data, output)
    user = output.select {|f| f[:name] == data[1]}
    user_type = user.detect {|f| f[:type] == data[2]}
    return if user_type[:balance] == 'error'
    amount = data[3].delete('$').to_i
    user_type[:balance] += amount if (user_type[:balance] + amount) <= user_type[:limit]
  end
  
  def credit(data, output)
    user = output.select {|f| f[:name] == data[1]}
    user_type = user.detect {|f| f[:type] == data[2]}
    return if user_type[:balance] =='error'
    amount = data[3].delete('$').to_i
    user_type[:balance] -= amount
  end
  
  def result(output)
    result_hash = {}
    output_hash = {}
    output.each do |record|
      if result_hash.has_key?(record[:name])
        result_hash[record[:name]] << [record[:type], record[:balance]]
      else
        result_hash.merge!({ record[:name] => [[record[:type], record[:balance]]]})
     end
    end
    binding.pry
    result_hash.each do |key, value|
      str = ''
      value.each do |val|
        str = "(#{val[0]}) #{val[1]}"
        output_hash.has_key?(key) ? output_hash[key] += str : output_hash.merge!({key => "#{str}"})
      end
    end
    output_hash.each do |key, val|
      puts "#{key}: #{val}"
    end
  end
end

#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'active_support/inflector'

ActiveSupport::Inflector.inflections do |inflect| #纠正ActiveSupport单复数错误
  inflect.irregular 'foot', 'feet'
end

File.open('output.txt', 'w') do |write_file|
  puts "输出邮箱chengwei.zang.1985@gmail.com\n===================开始获取比例列表\n\n"
  write_file.puts "chengwei.zang.1985@gmail.com\n\n"

  File.open('input.txt') do |read_file|
    rate = { 'm' => 1.0 }
    loop do
      break if read_file.eof?    #读到行尾跳出循环
      line = read_file.readline
      break if line.strip.empty? #读到空行跳出循环
      puts "读取到行#{line}"
      splited_words = line.split
      puts "切分单词#{splited_words}"
      src_value, src_unit, equ_operator, target_value, target_unit = splited_words
      src_value                                                    = src_value.to_f
      target_value                                                 = target_value.to_f
      if equ_operator != '='
        puts '解析有误，找不到='
        next
      end
      if target_unit != 'm'
        puts '解析有误，目标单位不是m'
        next
      end
      if src_unit.strip.empty?
        puts '源单位为空'
        next
      end
      rate[src_unit] = target_value / src_value
      puts "成功解析单位#{src_unit}, 1#{src_unit}=#{rate[src_unit]}#{target_unit}\n\n"
    end
    puts "**获得单位比例表#{rate}**"

    puts "===================\n开始计算算式\n\n"
    loop do
      break if read_file.eof?
      line = read_file.readline
      next if line.strip.empty? #读到空行跳过，读下一行
      puts "读取到行#{line}"
      splited_words = line.split
      puts "切分单词#{splited_words}"
      eval_string = ""
      enum = splited_words.enum_for
      begin
        loop do
          next_part = enum.next #取到下一个部分
          if %(+ - * /).include? next_part
            # 是一个运算符
            eval_string << next_part
          else
            value = next_part.to_f
            unit = enum.next
            eval_string << "#{value * rate[unit.singularize]}"
          end
        end
      end
      puts "算式#{eval_string}值#{eval eval_string} m\n\n"
      write_file.puts '%0.2f m' % eval(eval_string)
    end
  end

end

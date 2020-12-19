# frozen_string_literal: true

# require 'faraday'
# require 'faraday_middleware'
require 'mediawiki_api'

## General client for medical procedures
class MedicalProceduresClient
  CLIENT = MediawikiApi::Client.new(
    'https://en.wikipedia.org/w/api.php'
  ).freeze


  def query
    wiki_lines = CLIENT.get_wikitext('Medical procedure').body.lines
    ## We can use `drop_while` here, but I see no sense
    ## Such approach with strict indexes can raise explicit exceptions
    procedures_begin_index = wiki_lines.index("==List of medical procedures==\n").succ
    procedures_lines = wiki_lines[procedures_begin_index..]
    procedures_end_index = procedures_lines.index { |line| line.match?(/^==[^=]/) }.pred
    procedures_lines = procedures_lines[..procedures_end_index]
    result = {}
    result_endpoint_path = []
    procedures_lines.each do |line|
      line.chomp!

      if line.start_with?('===')
        ## Not `delete` or `tr` for saving `=` inside text
        category = line.match(/^={3}(.+)={3}$/)[1]
        result[category] = {}
        result_endpoint_path = [category]
        next
      end

      next unless (list_line_match = line.match(/^(?<indentation>(?:\*\s*)+)(?<text>[^*].+)$/))

      list_indentation_level = list_line_match[:indentation].count('*').pred
      line_text = list_line_match[:text]

      result_endpoint = result.dig(*result_endpoint_path)

      ## Exclude level of categories
      current_list_indentation_level = result_endpoint_path.size.pred

      # binding.pry

      if list_indentation_level == current_list_indentation_level
        puts "result = #{result}, result_endpoint_path = #{result_endpoint_path}"
        result_endpoint[line_text] = {}
        result_endpoint_path.push line_text
      elsif list_indentation_level > current_list_indentation_level
        # result_endpoint line_text => {}
        # result_endpoint_path.push line_text
        raise 'Unexpected jump over list nesting level'
      elsif list_indentation_level < current_list_indentation_level
        result_endpoint_path.pop
        result_endpoint[line_text] = {}
      end
    end
  end
end

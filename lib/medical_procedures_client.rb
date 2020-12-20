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

    result_endpoint_path = []
    current_list_indentation_level = 1

    procedures_lines.each_with_object({}) do |line, result|
      line.chomp!

      if line.start_with?('===')
        ## Not `delete` or `tr` for saving `=` inside text
        category = line.match(/^={3}(.+)={3}$/)[1]
        result[category] = []
        result_endpoint_path = [category]
        next
      end

      next unless (list_line_match = line.match(/^(?<indentation>(?:\*\s*)+)(?<text>[^*].+)$/))

      list_indentation_level = list_line_match[:indentation].count('*')
      line_text = list_line_match[:text]

      result_endpoint = result.dig(*result_endpoint_path)

      if list_indentation_level == current_list_indentation_level
        result_endpoint.push line_text
      elsif list_indentation_level > current_list_indentation_level
        ## Not `result_endpoint_path.size` because nested Hashes requires two additions:
        ## Array index and Hash key
        current_list_indentation_level += 1

        unless result_endpoint.last.is_a?(Hash)
          root_of_sublist = result_endpoint.pop
          ## `.size` without `- 1` because element already popped
          result_endpoint_path.push result_endpoint.size, root_of_sublist
          result_endpoint.push(root_of_sublist => [])
          result_endpoint = result.dig(*result_endpoint_path)
        end
        result_endpoint.push line_text

      elsif list_indentation_level < current_list_indentation_level
        ## 2 times because there are Array index and Hash key
        2.times { result_endpoint_path.pop }
        ## But we count it like one indentation level
        current_list_indentation_level -= 1

        result_endpoint = result.dig(*result_endpoint_path)
        result_endpoint.push line_text
      end
    end
  end
end

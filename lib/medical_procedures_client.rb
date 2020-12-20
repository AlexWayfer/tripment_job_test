# frozen_string_literal: true

require 'mediawiktory'

## General client for medical procedures
class MedicalProceduresClient
  API = MediaWiktory::Wikipedia::Api.new.freeze

  def query
    html = query_and_parse_wiki_html

    list_header_element = html.at_css('h2 > span#List_of_medical_procedures').parent

    ProceduresListParser.new(list_header_element).parse!
  end

  private

  def query_and_parse_wiki_html
    response = API.query.titles('Medical procedure').prop(:extracts).response
    Oga.parse_html response['pages'].first.last['extract']
  end

  ## Private helper class for parsing HTML list
  class ProceduresListParser
    def initialize(list_header_element)
      @current_element = list_header_element
      @result = {}
      @current_category_array = nil
    end

    def parse!
      loop do
        break unless (@current_element = @current_element.next_element)

        case @current_element.name
        when 'h3' then @current_category_array = @result[@current_element.text] = []
        when 'ul' then parse_list @current_element, @current_category_array
        when 'h2' then break
        end
      end

      @result
    end

    private

    def parse_list(ul_element, array_element)
      ul_element.children.each do |item|
        # next if item.text.chomp.empty?
        next unless (text_child = item.children.first)

        ## Cut off Wiki notes that this is about medicine
        name = text_child.text.chomp.gsub(/ \(medicine\)$/, '')

        next array_element.push(name) unless (nested_ul = item.children[1])

        array_element.push name => (nested_array = [])
        send __method__, nested_ul, nested_array
      end
    end
  end
  private_constant :ProceduresListParser
end

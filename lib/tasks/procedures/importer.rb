# frozen_string_literal: true

class ProceduresImporter
  def initialize(procedures_names, parent:)
    ## `uniq` to avoid duplicate names error, Wiki has such
    @procedures_names = procedures_names.uniq
    @parent = parent
  end

  def import
    @procedures_names.each do |procedure_name|
      case procedure_name
      when String then create_procedure procedure_name
      when Hash then import_from_hash procedure_name
      else raise 'Unexpected type of procedure'
      end
    end
  end

  private

  def import_from_hash(hash)
    raise 'Unexpected more than 1 element in Hash with procedures' if hash.size > 1

    procedure_name, sub_procedures = hash.first

    procedure = create_procedure procedure_name

    self.class.new(sub_procedures, parent: procedure).import
  end

  def create_procedure(name)
    Procedure.create(name: name, parent: @parent)
  end
end

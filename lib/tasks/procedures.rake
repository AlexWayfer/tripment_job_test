# frozen_string_literal: true

namespace :procedures do
  desc 'Fetch medical procedures from Wikipedia and create DB entries'
  task fetch: :environment do
    Rake::Task['procedures:erase'].invoke

    require_relative '../medical_procedures_client'
    require_relative 'procedures/importer'

    raw_procedures = MedicalProceduresClient.new.query

    raw_procedures.each do |category_name, procedures_names|
      category = Category.create name: category_name

      ProceduresImporter.new(procedures_names, parent: category).import
    end
  end

  desc 'Erase all existing procedures and categories'
  task erase: :environment do
    Procedure.delete_all
    Category.delete_all
  end
end

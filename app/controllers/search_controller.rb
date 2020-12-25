# frozen_string_literal: true

## Controller for search
class SearchController < ApplicationController
  def index
    ## Solution #1
    # union_query =
    #   procedures_db_query("#{query_param}%", priority: 1)
    #     .union(
    #       procedures_db_query("%#{query_param}%", priority: 2)
    #     )
    #
    # grouped_query =
    #   Procedure.select('id, min(priority) as min_priority').from(union_query, :unioned)
    #     .group(:id)
    #     .order(:min_priority)
    #
    # found_procedures =
    #   Procedure.select('*').from(grouped_query, :grouped)
    #     .joins('INNER JOIN procedures original ON original.id = grouped.id')
    #     .order(:min_priority)
    #     .includes(:parent)
    #     .all

    ## Solution #2
    # found_procedures =
    #   procedures_db_query("#{query_param}%", priority: 1)
    #     .union(
    #       procedures_db_query("_%#{query_param}%", priority: 2)
    #     )
    #     .order(:priority)
    #     .includes(:parent)
    #     .all

    ## Solution #3
    found_procedures =
      Procedure
        .select(
          Procedure.arel_table[Arel.star],
          "case position('#{query_param}' in name) when 0 then 1 else 2 end as priority"
        )
        .where(Procedure.arel_table[:name].matches("%#{query_param}%"))
        .order(:priority)
        .includes(:parent)
        .all

    render json: found_procedures, include: :parent
  end

  private

  def query_param
    params.require(:query)
  end

  ## For solution #1
  # def procedures_db_query(name_matches, priority:)
  #   Procedure
  #     .where(Procedure.arel_table[:name].matches(name_matches))
  #     .select("id, #{priority} as priority")
  # end

  ## For solution #2
  # def procedures_db_query(name_matches, priority:)
  #   Procedure
  #     .where(Procedure.arel_table[:name].matches(name_matches))
  #     .select(Procedure.arel_table[Arel.star], "#{priority} as priority")
  # end
end

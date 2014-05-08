module Spree
  module Api
    class ClassificationsController < Spree::Api::BaseController
      def update
        authorize! :update, Product
        authorize! :update, Taxon
        classification = Spree::Classification.where(
          :product_id => params[:product_id],
          :taxon_id => params[:taxon_id]
        ).limit(1).first
        # Because position we get back is 0-indexed.
        # acts_as_list is 1-indexed.
        classification.insert_at(params[:position].to_i + 1)
        head :ok
      end
    end
  end
end
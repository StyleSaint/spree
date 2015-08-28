module Spree
  module Admin
    class OrdersController < Spree::Admin::BaseController
      require 'spree/core/gateway_error'
      before_filter :initialize_order_events
      before_filter :load_order, :only => [:show, :edit, :update, :fire, :resend]

      respond_to :html
      
      def show
        respond_with(@order)
      end

      def new
        @order = Order.create
        respond_with(@order)
      end

      def edit
        respond_with(@order)
      end

      def update
        return_path = nil
        if @order.update_attributes(params[:order]) && @order.line_items.present?
          @order.update!
          unless @order.complete?
            # Jump to next step if order is not complete.
            return_path = admin_order_customer_path(@order)
          else
            # Otherwise, go back to first page since all necessary information has been filled out.
            return_path = admin_order_path(@order)
          end
        else
          @order.errors.add(:line_items, t('errors.messages.blank')) if @order.line_items.empty?
        end

        respond_with(@order) do |format|
          format.html do
            if return_path
              redirect_to return_path
            else
              render :action => :edit
            end
          end
        end
      end

      def fire
        # TODO - possible security check here but right now any admin can before any transition (and the state machine
        # itself will make sure transitions are not applied in the wrong state)
        event = params[:e]
        if @order.send("#{event}")
          flash[:success] = t(:order_updated)
        else
          flash[:error] = t(:cannot_perform_operation)
        end
      rescue Spree::Core::GatewayError => ge
        flash[:error] = "#{ge.message}"
      ensure
        respond_with(@order) { |format| format.html { redirect_to :back } }
      end

      def resend
        OrderMailer.confirm_email(@order.id, true).deliver
        flash[:success] = t(:order_email_resent)

        respond_with(@order) { |format| format.html { redirect_to :back } }
      end

      private

        def load_order
          @order = Order.find_by_number!(params[:id], :include => :adjustments) if params[:id]
          authorize! action, @order
        end

        # Used for extensions which need to provide their own custom event links on the order details view.
        def initialize_order_events
          @order_events = %w{cancel resume}
        end

        def model_class
          Spree::Order
        end
    end
  end
end

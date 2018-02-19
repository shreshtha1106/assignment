module OrderAssignmentHelper

	# include OrderAssignment
	def assign_orders(order_assignment_infos)
		return fasle if order_assignment_infos[:orders].blank? || order_assignment_infos[:delivery_executives].blank?
		Order.fetch_scores_for_order_delay_time(params[:orders])
		DeliveryExecutive.fetch_scores_for_de_wait_time(params[:delivery_executives])
		return true
	end
end

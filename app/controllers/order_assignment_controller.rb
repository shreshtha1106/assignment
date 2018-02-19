class OrderAssignmentController < ApplicationController
require File.expand_path("../swiggy/lib/order_assignment.rb")

	def assign_orders
		#validate input => return invalid input in all the invalid input cases.
		order_assigned = OrderAssignment.assign_orders(params)
		render json: {status: "Required input missing"} and return if order_assigned == false
		render json: {status: "working", info: order_assigned }
		# give score to each order index by id
		# give score to each DE index by id 
		# sort each order_info in descending order
		# calculate dist of orders from each delivery executive
		# give score to distances for each order
		#calculate mean of all scores
	end

	#Assumptions:
	#time: is in integer form
	#Assumed min and max time for order delay and DE wait time ->  5 minutes and  2 hours. 
	#Assumed min and max distance between DE and Order -> 2kms and 13 kms

end

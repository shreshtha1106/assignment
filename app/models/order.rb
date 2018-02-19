class Order < ActiveRecord::Base
	extend OrderAssignment

	def self.fetch_scores_for_order_delay_time(structurized_order_infos)
		delay_time_hash, current_time = {}, Time.now.to_i
		structurized_order_infos.each{|key,value| delay_time_hash[key] = current_time - value[:ordered_time]}
		order_delay_time_score = calculate_standard_scores(delay_time_hash, 300, 7200)
		#fetch z scores of each order info
	end

	def self.structurize_orders(order_infos)
		structurized_order = {}
		order_infos.each do |order|
			#validation if restaurant location is a string.
			order_location = order[:restaurant_location].split(",")
			structurized_order[order[:id].to_s] = {lat: order_location.first.to_f, lng: order_location.last.to_f, ordered_time: order[:ordered_time].to_i}
		end
		structurized_order
	end

end

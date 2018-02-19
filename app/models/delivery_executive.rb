class DeliveryExecutive < ActiveRecord::Base
	extend OrderAssignment

	def self.fetch_scores_for_de_wait_time(delivery_executive_infos)
		wait_time_hash, current_time = {}, Time.now.to_i
		delivery_executive_infos.each{|key,value| wait_time_hash[key] = value[:last_order_delivered_time]}
		de_wait_time_scores = calculate_standard_scores(wait_time_hash,300, 7200)
	end

	def self.structurize_de_infos(delivery_executive_infos)
		structurized_de_infos = {}
		delivery_executive_infos.each do |de_info|
			de_location = de_info[:current_location].split(",")
			structurized_de_infos[de_info[:id].to_s] = {lat: de_location.first.to_f, lng: de_location.last.to_f, last_order_delivered_time: de_info[:last_order_delivered_time].to_i}
		end
		structurized_de_infos
	end

end

module OrderAssignment

		def self.assign_orders(order_assignment_infos)
			return false if order_assignment_infos[:orders].blank? || order_assignment_infos[:delivery_executives].blank?
			structurized_order_infos = Order.structurize_orders(order_assignment_infos[:orders])
			order_delay_scores = Order.fetch_scores_for_order_delay_time(structurized_order_infos)
			structurized_de_infos = DeliveryExecutive.structurize_de_infos(order_assignment_infos[:delivery_executives])
			de_wait_time_scores = DeliveryExecutive.fetch_scores_for_de_wait_time(structurized_de_infos)
			distance_scores = calculate_distance_score_from_des(structurized_order_infos, structurized_de_infos)
			factor_score_list = {order_delay_scores: {factor: 1, scores: order_delay_scores}, de_wait_time_scores: {factor: 1, scores: de_wait_time_scores}, distance_scores: {factor: 1, scores: distance_scores}}
			composite_score_infos = fetch_composite_scores(factor_score_list)
			order_de_mapping = map_orders_to_des(composite_score_infos)
		end

		def self.map_orders_to_des(composite_score_infos)
			assigned_orders, assigned_des, order_de_mapping = [], [], []
			#sort in descending order
			composite_score_infos = composite_score_infos.sort_by{ |composite_score_info| composite_score_info[:composite_score] }.reverse!
			composite_score_infos.each do |composite_score_info|	
				next if assigned_orders.include?(composite_score_info[:order_info_id]) || assigned_des.include?(composite_score_info[:de_info_id])
				order_de_mapping << {order_id: composite_score_info[:order_info_id], de_id: composite_score_info[:de_info_id]}
				assigned_orders << composite_score_info[:order_info_id]
				assigned_des << composite_score_info[:de_info_id]
			end	
			order_de_mapping
		end


		def self.fetch_composite_scores(factor_score_list)
			distance_factor_scores = factor_score_list[:distance_scores]
			scores_with_factors, composite_scores = [], []
			distance_factor_scores[:scores].each do |distance_score|
				scores_with_factors <<  {factor: distance_factor_scores[:factor], score: distance_score[:dist_score]}
				scores_with_factors <<	{factor: factor_score_list[:de_wait_time_scores][:factor], score: factor_score_list[:de_wait_time_scores][:scores][distance_score[:de_info_id]]}
				scores_with_factors <<  {factor: factor_score_list[:order_delay_scores][:factor], score: factor_score_list[:order_delay_scores][:scores][distance_score[:order_info_id]]}	
				composite_score = calculate_composite_score(scores_with_factors)
				composite_scores << {de_info_id: distance_score[:de_info_id], order_info_id: distance_score[:order_info_id], composite_score: composite_score}
			end
			composite_scores
		end

		def self.calculate_distance(start_point, end_point)
			#can validate for lat and lng
	    return if start_point[:lat].blank? || start_point[:lng].blank? || end_point[:lat].blank? || end_point[:lng].blank?
	    start_location = Geokit::LatLng.new(start_point[:lat],start_point[:lng])
	    end_location = Geokit::LatLng.new(end_point[:lat],end_point[:lng])
	    distance = end_location.distance_to(start_location, :units => :kms) * 1000
		end

		#calculates weighted average
		def self.calculate_composite_score(factor_scores)
			sum = factor_scores.inject(0){|sum, factor_score| sum += factor_score[:factor]*factor_score[:score]}
			composite_score = sum / factor_scores.count 
		end

		# def self.calculate_standard_scores(indexed_data_set)
		# 	return if indexed_data_set.blank? || indexed_data_set.values.blank?
		# 	data_set = indexed_data_set.values
		# 	data_set_avg = data_set.inject{|sum,data| sum+data} / data_set.length
		# 	sum_of_difference_squares = data_set.inject(0){|sum,data| sum + ((data-data_set_avg)**2)}
		# 	standard_deviation = Math.sqrt(sum_of_difference_squares/data_set.length.to_f)
		# 	standard_scores = indexed_data_set.each{|key,value| indexed_data_set[key] = (value - data_set_avg)/standard_deviation}
		# end

		def self.calculate_standard_distance_scores(indexed_data_set, assumed_min_val, assumed_max_val)
			total_diff = assumed_min_val - assumed_max_val
			indexed_data_set.each do |key,value| 
				if value < assumed_min_val
					indexed_data_set[key] = 100
				elsif value > assumed_max_val 
					indexed_data_set[key] = 1
				else
					indexed_data_set[key] = 100 - ((value-assumed_min_val)/totaldiff * 100)
				end
			end
			indexed_data_set
		end

		def calculate_standard_scores(indexed_data_set, assumed_min_val, assumed_max_val)
			total_diff = assumed_min_val - assumed_max_val
			indexed_data_set.each do |key,value| 
				if value < assumed_min_val
					indexed_data_set[key] = 1
				elsif value > assumed_max_val 
					indexed_data_set[key] = 100
				else
					indexed_data_set[key] = (value-assumed_min_val)/totaldiff * 100
				end
			end
			indexed_data_set
		end

		def self.calculate_distance_score_from_des(structurized_order_infos, structurized_de_infos)
	  distance_scores_for_des, distance_from_des = [] , {}
		structurized_de_infos.each do |structurized_de_info_id, structurized_de_info|
			structurized_order_infos.each do |structurized_order_info_id, structurized_order_info|
				distance_from_des[structurized_order_info_id] = OrderAssignment.calculate_distance({lat: structurized_order_info[:lat], lng: structurized_order_info[:lng]}, {lat: structurized_de_info[:lat], lng: structurized_de_info[:lng]})
			end
			distance_scores_for_des = fetch_distance_scores(distance_from_des, distance_scores_for_des, structurized_de_info_id)
		end
		return distance_scores_for_des
	end 

	private 

	def self.fetch_distance_scores(distance_from_des, distance_scores_for_des, structurized_de_info_id)
		standard_scores = calculate_standard_distance_scores(distance_from_des,2,13)
		standard_scores.each do |order_info_id, distance_score|
			distance_scores_for_des << {dist_score: distance_score, order_info_id: order_info_id, de_info_id: structurized_de_info_id}
		end
		distance_scores_for_des
	end

end
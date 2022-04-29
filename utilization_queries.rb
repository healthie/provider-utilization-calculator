require "graphql/client"
require "graphql/client/http"
require "active_support"
require 'active_support/time'

module HEALTHIE_API
 

  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new("https://staging-api.gethealthie.com/graphql") do
    def headers(context)
     api_key = nil
  	 raise "SET YOUR API KEY" unless api_key

      { "Authorization": "Basic #{api_key}", "AuthorizationSource": "API" }
    end
  end  

  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Client.load_schema(HTTP)

  # However, it's smart to dump this to a JSON file and load from disk
  #
  # Run it from a script or rake task
  #   GraphQL::Client.dump_schema(HEALTHIE_API::HTTP, "path/to/schema.json")
  #
  # Schema = GraphQL::Client.load_schema("path/to/schema.json")

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end

OrganizationAvailabilitiesQuery = HEALTHIE_API::Client.parse <<-'GRAPHQL'
 query($startDate: String, $endDate: String, $appointment_type_id: String) {
			availabilities (is_org: true, 
							is_repeating: true, 
							one_time: true,  
							startDate: $startDate, 
							endDate: $endDate, 
							appointment_type_id: $appointment_type_id
	) {
				user_id
				range_start
				range_end
		}
}
GRAPHQL

OrganizationAppointmentsQuery = HEALTHIE_API::Client.parse <<-'GRAPHQL'
 query($startDate: String, $endDate: String, $appointment_type_id: ID) {
			appointments (is_org: true, 
						  startDate: $startDate, 
						  endDate: $endDate, 
						  is_active: true, 
						  is_with_clients: true,
						  filter_by_appointment_type_id:  $appointment_type_id
	) {
			id
			start
			length
		}
}
GRAPHQL

start_date = "2022-05-01"
end_date = "2022-05-30"
appointment_type_id = nil # If you want to check utilization for a speicifc appointment type, set the ID of the appointment type here

raise "You need to set a start_date and end_date" unless start_date && end_date

result = HEALTHIE_API::Client.query(OrganizationAvailabilitiesQuery, 
									variables: {startDate: start_date, 
												endDate: end_date, 
												appointment_type_id: appointment_type_id})

total_available_hours = 0


availabilities = result.data.availabilities

availabilities.each do |avail|
	# get the length of the availability in minutes
	length_in_minutes = (avail.range_end.to_datetime.to_i - avail.range_start.to_datetime.to_i) / 60

	total_available_hours = total_available_hours + (length_in_minutes / 60.0)
end

puts "TOTAL INITIAL AVAILABILITY HOURS: #{total_available_hours}"

appt_result = HEALTHIE_API::Client.query(OrganizationAppointmentsQuery, variables: {startDate: start_date, endDate: end_date})

total_appointment_hours = 0


appointments = appt_result.data.appointments

appointments.each do |appt|
	# get the length of the availability in minutes
	total_appointment_hours = total_appointment_hours + (appt.length / 60.0)
end

puts "TOTAL APPOINTMENT HOURS: #{total_appointment_hours}"

# Utilization is calculated as total active appointment hours divided by total amount of availability.

utilization = total_appointment_hours / total_available_hours

puts "UTILIZATION PERCENTAGE: #{(utilization * 100.0).round(2)}%"



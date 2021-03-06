module VoipApi
  module API

    # Represents an API request for things relating to 911 Verification and Emergency Services
    class X911Request < ApiRequest
      
      # @attr [Constant] klass The class name to use for parsing the Savon response
      def initialize(klass=nil)
        self.klass ||= VoipApi::APIResponse::X911Response
      end

      # @return [Array] Returns a list of soap action keys which are used to make requests to their Sandbox API
      def self.sandbox_soap_action_keys
        []
      end

      # @return [Array] Returns a list of soap action keys which are used to make requests to their Production API
      def self.production_soap_action_keys
        [
          :add911_alert,
          :add_location,
          :audit911,
          :get_locations,
          :get_provisioning_history,
          :insert911,
          :provision_location,
          :query911,
          :query911_alert,
          :remove911,
          :remove911_alert,
          :remove_location,
          :update911,
          :validate911,
        ]
      end

      # This method returns the 911 information you have added/updated for all DIDs (including not currently owned a.k.a. off-net DIDs).
      def audit_911
        self.arguments = {}
        self.action = :audit911
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method gets all of the 911 locations associated with a DID. 
      # Records from both the 911 service provider and our database are returned. 
      # @param did [String] The telephone number to query
      def get_locations(did)
        raise ArgumentError unless did.is_a?(String)
        self.arguments = {did: did}
        self.action = :get_locations
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method returns the 911 information for the provisioned location of the specified DID.
      # @param did [String] The telephone number to query
      def query_911(did)
        raise ArgumentError unless did.is_a?(String)
        self.arguments = {did: did}
        self.action = :query911
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method checks the validity of an address to be used for 911.
      # @param address1 [String] The primary street address
      # @param address2 [String] The secondary street address
      # @param city [String] The city
      # @param state [String] The state
      # @param zip [String] The 5 digit ZIP Code
      # @param plus_four [String] The 4 digit ZIP Code extension
      # @param caller_name [String] The Caller Name
      # @note This method does not provision the location to the DID. It only checks the validity of the provided address.
      # @note Properties populated: responseCode, responseMessage. A 100,Success indicates a valid address. Whereas a 101, No Records Found indicates a failure.
      def validate_911(address1, address2, city, state, zip, plus_four, caller_name)
        self.arguments = {
          address1: address1, 
          address2: address2, 
          city: city,
          state: state,
          zip: zip,
          plus_four: plus_four,
          caller_name: caller_name,
        }
        self.action = :validate911
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method gets the provisioning history for a DID. The records returned are from the 911 service provider.
      # @param did [String] The telephone number to query
      def get_provisioning_history(did)
        raise ArgumentError unless did.is_a?(String)
        self.arguments = {did: did}
        self.action = :get_provisioning_history
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method returns DID and emails regarding the 911Alert being queried.
      # @param tn [String] The telephone number to query
      def query_911_alert(tn)
        raise ArgumentError unless tn.is_a?(String)
        self.arguments = {tn: tn}
        self.action = :query911_alert
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method provisions an already existing GEOCODED 911 location. INVALID locations cannot be provisioned.
      # @param did [String] The telephone number to remove the location from
      # @param location_id [String] The Location ID generated by the e911 service provider
      def provision_location(did, location_id)
        raise ArgumentError unless did.is_a?(String)
        raise ArgumentError unless location_id.is_a?(String)
        self.arguments = {did: did, location_id: location_id}
        self.action = :provision_location
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method adds a location to the 911 service provider as well as our database. 
      # @param did [String] The telephone number to remove the location from
      # @param address1 [String] The primary street address
      # @param address2 [String] The secondary street address
      # @param city [String] The city
      # @param state [String] The state
      # @param zip [String] The 5 digit ZIP Code
      # @param plus_four [String] The 4 digit ZIP Code extension
      # @param caller_name [String] The Caller Name
      # @note An invalid or 'cannot be geocoded' location will be added to the 911 service provider, but not our database Caller name for added location will overwrite the caller name on all other locations for the given DID.
      def add_location(did, address1, address2, city, state, zip, plus_four, caller_name)
        raise ArgumentError unless did.is_a?(String)
        raise ArgumentError unless address1.is_a?(String)
        raise ArgumentError unless address2.is_a?(String)
        raise ArgumentError unless city.is_a?(String)
        raise ArgumentError unless state.is_a?(String)
        raise ArgumentError unless zip.is_a?(String)
        raise ArgumentError unless plus_four.is_a?(String)
        raise ArgumentError unless caller_name.is_a?(String)
        self.arguments = {
          did: did,
          address1: address1, 
          address2: address2, 
          city: city,
          state: state,
          zip: zip,
          plus_four: plus_four,
          caller_name: caller_name,
        }
        self.action = :add_location
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method removes a GEOCODED or PROVISIONED 911 location. 
      # @param location_id [String] The Location ID generated by the e911 service provider
      # @param did [String] The telephone number to remove the location from
      # @note INVALID locations cannot be removed.
      def remove_location(location_id, did)
        raise ArgumentError unless location_id.is_a?(String)
        raise ArgumentError unless did.is_a?(String)
        self.arguments = {
          location_id: location_id,
          did: did,
        }
        self.action = :remove_location
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method updates the provisioned 911 location information for a DID that is currently registered with your account.
      # @param did [String] The telephone number to query
      # @param address1 [String] The primary street address
      # @param address2 [String] The secondary street address
      # @param city [String] The city
      # @param state [String] The state
      # @param zip [String] The 5 digit ZIP Code
      # @param plus_four [String] The 4 digit ZIP Code extension
      # @param caller_name [String] The Caller Name
      # @note An INVALID location information will result in no provisioned location for the specified DID.
      def update_911(did, address1, address2, city, state, zip, plus_four, caller_name)
        raise ArgumentError unless did.is_a?(String)
        raise ArgumentError unless address1.is_a?(String)
        raise ArgumentError unless address2.is_a?(String)
        raise ArgumentError unless city.is_a?(String)
        raise ArgumentError unless state.is_a?(String)
        raise ArgumentError unless zip.is_a?(String)
        raise ArgumentError unless plus_four.is_a?(String)
        raise ArgumentError unless caller_name.is_a?(String)
        self.arguments = {
          did: did,
          address1: address1, 
          address2: address2, 
          city: city,
          state: state,
          zip: zip,
          plus_four: plus_four,
          caller_name: caller_name,
        }
        self.action = :update911
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method adds and provisions a 911 location for a DID that is currently registered with your account.
      # @param did [String] The telephone number to insert 911 information for
      # @param address1 [String] The primary street address
      # @param address2 [String] The secondary street address
      # @param city [String] The city
      # @param state [String] The state
      # @param zip [String] The 5 digit ZIP Code
      # @param plus_four [String] The 4 digit ZIP Code extension
      # @param caller_name [String] The Caller Name
      def insert_911(did, address1, address2, city, state, zip, plus_four, caller_name)
        raise ArgumentError unless did.is_a?(String)
        raise ArgumentError unless address1.is_a?(String)
        raise ArgumentError unless address2.is_a?(String)
        raise ArgumentError unless city.is_a?(String)
        raise ArgumentError unless state.is_a?(String)
        raise ArgumentError unless zip.is_a?(String)
        raise ArgumentError unless plus_four.is_a?(String)
        raise ArgumentError unless caller_name.is_a?(String)
        self.arguments = {
          did: did,
          address1: address1, 
          address2: address2, 
          city: city,
          state: state,
          zip: zip,
          plus_four: plus_four,
          caller_name: caller_name,
        }
        self.action = :insert911
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method removes the 911 information associated with a DID
      # @param did [String] The telephone number to remove 911 services from
      def remove_911(did)
        raise ArgumentError unless did.is_a?(String)
        self.arguments = {did: did}
        self.action = :remove911
        self.response = VoipApi.account.request(self.action, self.klass, self.arguments)
        self
      end

      # This method removes the alert contact information from the DID.
      def remove_911_alert(tn, email)
        # :remove911_alert
        raise NotImplementedError
      end

      # Parsing and Chaining Operations

      # Returns a DIDList containing all the DID911s
      # @return [Object] Returns a DIDList which has a collection of DID911s
      # @!group Chaining
      def dids_911_list
        payload[:dids_911].nil? ? nil : payload[:dids_911]
      end

      # Returns the array of actual DID911s
      # @return [Array] Returns an array of the DID911's
      # @!group Chaining
      def dids_911
        dids_911_list ? dids_911_list.collection : []
      end

      # Returns a DIDList containing all the VILocations
      # @return [Object] Returns a DIDList which has a collection of VILocations
      # @!group Chaining
      def vi_locations_list
        payload[:vi_locations].nil? ? nil : payload[:vi_locations]
      end

      # Returns the array of actual VILocations
      # @return [Array] Returns an array of the VILocations
      # @!group Chaining
      def vi_locations
        vi_locations_list ? vi_locations_list.collection : []
      end

      # Returns a DIDList containing all the Status911s
      # @return [Object] Returns a DIDList which has a collection of Status911s
      # @!group Chaining
      def statuses_911_list
        payload[:statuses].nil? ? nil : payload[:statuses]
      end

      # Returns the array of actual Status911s
      # @return [Array] Returns an array of the Status911s
      # @!group Chaining
      def statuses_911
        statuses_911_list ? statuses_911_list.collection : []
      end

      # Returns a detailed status of the 911 Verification
      # @!group Chaining
      def x911_validation_status
        # Parse out the code I guess?
        if (self.action == :validate911)
          case voip_response_code.to_i
          when 100
            "Success - This address is valid and registered with 911."
          when 101
            "Failure - This address is not registered with 911"
          end
        else
          raise ArgumentError, "911 Validation can only be inferred by calling the validate_911 method!"
        end
      end

    end
    
  end
end

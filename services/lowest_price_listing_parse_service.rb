# frozen_string_literal: true

require 'json'
require 'active_support'
require_relative 'fetch_services/fetch_lowest_price_listing_service'
require_relative 'base_service'
require_relative '../modules/services_helper_methods'

# LowestPriceListingParseService
class LowestPriceListingParseService < BaseService
  include ServicesHelperMethods
  def initialize(entries, users)
    super()
    return if entries.blank?

    initialize_common(entries, THREAD_COUNT, users)
  end

  def send_fetch_and_process_request(user, retries, current_entries)
    merge_same_asin_hash(
      @result_array,
      FetchLowestPriceListingService.new(user, @users, current_entries).fetch_and_process_data(20)&.flatten
    )
  rescue StandardError => e
    exception_printer(e)
    retries += 1
    retry if retries <= 3
  end

  def remaining_data
    @search_key_semaphore.synchronize do
      puts "Remaining: FOR LowestPriceListingParseService #{@_cached_records.count}"
      return false if @_cached_records.blank?

      return @_cached_records.shift(20)
    end
  end
end

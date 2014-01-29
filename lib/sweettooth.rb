# Sweet Tooth Ruby bindings
# API spec at https://www.sweettoothrewards.com/api/docs
require 'cgi'
require 'set'
require 'openssl'
require 'rest_client'
require 'multi_json'
require 'base64'

# Version
require 'sweettooth/version'

# API operations
require 'sweettooth/api_operations/create'
require 'sweettooth/api_operations/update'
require 'sweettooth/api_operations/delete'
require 'sweettooth/api_operations/list'

# Resources
require 'sweettooth/util'
require 'sweettooth/json'
require 'sweettooth/sweettooth_object'
require 'sweettooth/api_resource'
require 'sweettooth/singleton_api_resource'
require 'sweettooth/collection_object'
require 'sweettooth/activity'
require 'sweettooth/customer'
require 'sweettooth/redemption'
require 'sweettooth/redemption_option'
require 'sweettooth/spending'
require 'sweettooth/spending_option'

# Errors
require 'sweettooth/errors/sweettooth_error'
require 'sweettooth/errors/api_error'
require 'sweettooth/errors/api_connection_error'
require 'sweettooth/errors/invalid_request_error'
require 'sweettooth/errors/authentication_error'

module SweetTooth
  # @api_base = 'https://api.sweettooth.io'
  @api_base = 'http://local-api.sweettooth.io:3000'

  @verify_ssl_certs = true

  class << self
    attr_accessor :api_key, :api_base, :verify_ssl_certs, :api_version
  end

  def self.api_url(url='')
    @api_base + url
  end

  def self.request(method, url, api_key, params={}, headers={})
    unless api_key ||= @api_key
      raise AuthenticationError.new('No API key provided. ' +
        'Set your API key using "SweetTooth.api_key = <API-KEY>". ' +
        'You can generate API keys from the Sweet Tooth web interface. ' +
        'See https://www.sweettoothrewards.com/api for details, or email support@sweettoothhq.com ' +
        'if you have any questions.')
    end

    if api_key =~ /\s/
      raise AuthenticationError.new('Your API key is invalid, as it contains ' +
        'whitespace. (HINT: You can double-check your API key from the ' +
        'Sweet Tooth web interface. See https://www.sweettoothrewards.com/api for details, or ' +
        'email support@sweettoothhq.com if you have any questions.)')
    end

    request_opts = { :verify_ssl => false }

    params = Util.objects_to_ids(params)
    url = api_url(url)

    case method.to_s.downcase.to_sym
    when :get, :head, :delete
      # Make params into GET parameters
      url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
      payload = nil
    else
      payload = uri_encode(params)
    end

    request_opts.update(:headers => request_headers(api_key).update(headers),
                        :method => method, :open_timeout => 30,
                        :payload => payload, :url => url, :timeout => 80)

    begin
      response = execute_request(request_opts)
    rescue SocketError => e
      handle_restclient_error(e)
    rescue NoMethodError => e
      # Work around RestClient bug
      if e.message =~ /\WRequestFailed\W/
        e = APIConnectionError.new('Unexpected HTTP response code')
        handle_restclient_error(e)
      else
        raise
      end
    rescue RestClient::ExceptionWithResponse => e
      if rcode = e.http_code and rbody = e.http_body
        handle_api_error(rcode, rbody)
      else
        handle_restclient_error(e)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      handle_restclient_error(e)
    end

    [parse(response), api_key]
  end

  private

  def self.user_agent
    @uname ||= get_uname
    lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

    {
      :bindings_version => SweetTooth::VERSION,
      :lang => 'ruby',
      :lang_version => lang_version,
      :platform => RUBY_PLATFORM,
      :publisher => 'sweettooth',
      :uname => @uname
    }

  end

  def self.get_uname
    `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
  rescue Errno::ENOMEM => ex # couldn't create subprocess
    "uname lookup failed"
  end

  def self.uri_encode(params)
    Util.flatten_params(params).
      map { |k,v| "#{k}=#{Util.url_encode(v)}" }.join('&')
  end

  def self.request_headers(api_key)
    headers = {
      :user_agent => "SweetTooth/v1 RubyBindings/#{SweetTooth::VERSION}",
      :authorization => "Basic " + Base64.encode64(api_key + ':'),
      :content_type => 'application/x-www-form-urlencoded'
    }

    headers[:sweettooth_version] = api_version if api_version

    begin
      headers.update(:x_sweettooth_client_user_agent => SweetTooth::JSON.dump(user_agent))
    rescue => e
      headers.update(:x_sweettooth_client_raw_user_agent => user_agent.inspect,
                     :error => "#{e} (#{e.class})")
    end
  end

  def self.execute_request(opts)
    RestClient::Request.execute(opts)
  end

  def self.parse(response)
    begin
      # Would use :symbolize_names => true, but apparently there is
      # some library out there that makes symbolize_names not work.
      response = SweetTooth::JSON.load(response.body)
    rescue MultiJson::DecodeError
      raise general_api_error(response.code, response.body)
    end

    Util.symbolize_names(response)
  end

  def self.general_api_error(rcode, rbody)
    APIError.new("Invalid response object from API: #{rbody.inspect} " +
                 "(HTTP response code was #{rcode})", rcode, rbody)
  end

  def self.handle_api_error(rcode, rbody)
    begin
      error_obj = SweetTooth::JSON.load(rbody)
      error_obj = Util.symbolize_names(error_obj)
      error = error_obj or raise SweetToothError.new # escape from parsing

    rescue MultiJson::DecodeError, SweetToothError
      raise general_api_error(rcode, rbody)
    end

    case rcode
    when 400, 404
      raise invalid_request_error error, rcode, rbody, error_obj
    when 401
      raise authentication_error error, rcode, rbody, error_obj
    else
      raise api_error error, rcode, rbody, error_obj
    end

  end

  def self.invalid_request_error(error, rcode, rbody, error_obj)
    InvalidRequestError.new(error[:message], error[:param], rcode,
                            rbody, error_obj)
  end

  def self.authentication_error(error, rcode, rbody, error_obj)
    AuthenticationError.new(error[:message], rcode, rbody, error_obj)
  end

  def self.api_error(error, rcode, rbody, error_obj)
    APIError.new(error[:message], rcode, rbody, error_obj)
  end

  def self.handle_restclient_error(e)
    case e
    when RestClient::ServerBrokeConnection, RestClient::RequestTimeout
      message = "Could not connect to Sweet Tooth (#{@api_base}). " +
        "Please check your internet connection and try again. " +
        "If this problem persists, you should check Sweet Tooth's service status at " +
        "https://twitter.com/sweettoothstatus, or let us know at support@sweettoothhq.com."

    when RestClient::SSLCertificateNotVerified
      message = "Could not verify Sweet Tooth's SSL certificate. " +
        "Please make sure that your network is not intercepting certificates. " +
        "(Try going to https://api.sweettooth.io/v1 in your browser.) " +
        "If this problem persists, let us know at support@sweettoothhq.com."

    when SocketError
      message = "Unexpected error communicating when trying to connect to Sweet Tooth. " +
        "You may be seeing this message because your DNS is not working. " +
        "To check, try running 'host sweettooth.io' from the command line."

    else
      message = "Unexpected error communicating with Sweet Tooth. " +
        "If this problem persists, let us know at support@sweettoothhq.com."

    end

    raise APIConnectionError.new(message + "\n\n(Network error: #{e.message})")
  end
end

class GoogleAuth

  require 'net/http'
  BASE_URL = 'https://www.googleapis.com/oauth2/v3/'

  def verify(id_token)
    url = BASE_URL + 'tokeninfo?id_token=' + id_token.to_s
    response = send_request(url)

    if response and response.code.to_s == '200' 
      body = JSON.parse(response.body)
      return {result: true, name: body['name'], email: body['email'], picture: body['picture'] }
    end 
      return {result: false}
    end

  def send_request(url)
     begin
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      resp = http.start {|http| http.request(req)}
      return resp
    rescue
      return nil
    end
  end

end
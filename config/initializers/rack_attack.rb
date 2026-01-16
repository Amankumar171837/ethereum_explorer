class Rack::Attack
  # Throttle all requests by IP (60 requests per minute)
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Throttle API requests specifically (higher limit for API consumers if needed)
  throttle('api/ip', limit: 300, period: 5.minutes) do |req|
    if req.path.start_with?('/api')
      req.ip
    end
  end

  # Block suspicious requests
  blocklist('fail2ban') do |req|
    # `filter` returns truthy value if request fails, or nil otherwise.
    # Fail2Ban.filter(req.ip, maxretry: 3, findtime: 10.minutes, bantime: 5.minutes) do
    #   # The count for the IP is incremented if the return value is truthy
    #   req.path == '/login' && req.post?
    # end
  end
end
